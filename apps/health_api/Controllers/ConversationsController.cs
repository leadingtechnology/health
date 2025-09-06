using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using health_api.Data;
using health_api.DTOs;
using health_api.Models;

namespace health_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ConversationsController : ControllerBase
    {
        private readonly HealthDbContext _db;
        public ConversationsController(HealthDbContext db) { _db = db; }
        private Guid UserId => Guid.Parse(User.FindFirstValue("sub")!);

        [HttpGet]
        public async Task<IActionResult> List([FromQuery] Guid? patientId = null)
        {
            var q = _db.Conversations.AsQueryable();
            if (patientId.HasValue) q = q.Where(c => c.PatientId == patientId);
            var list = await q.OrderByDescending(c => c.CreatedAt).Take(200).ToListAsync();
            return Ok(list);
        }

        [HttpPost]
        public async Task<IActionResult> Upsert([FromBody] ConversationUpsertRequest req)
        {
            var c = new Conversation {
                Title = req.Title,
                PatientId = req.PatientId,
                OwnerUserId = UserId,
                SummaryText = req.SummaryText ?? string.Empty,
                IsShared = req.IsShared
            };
            _db.Conversations.Add(c);
            await _db.SaveChangesAsync();
            return Ok(c);
        }

        [HttpPost("share")]
        public async Task<IActionResult> Share([FromBody] ShareRequest req)
        {
            var conv = await _db.Conversations.FindAsync(req.ConversationId);
            if (conv == null) return NotFound();
            if (conv.OwnerUserId != UserId) return Forbid();

            var s = new ShareGrant {
                ConversationId = req.ConversationId,
                ToUserId = req.ToUserId,
                ToEmail = req.ToEmail?.Trim().ToLowerInvariant(),
                RedactPII = req.RedactPII,
                ExpiresAt = req.ExpiresAt
            };
            _db.ShareGrants.Add(s);
            conv.IsShared = true;
            await _db.SaveChangesAsync();
            return Ok(new { s.Id });
        }
        
        [HttpGet("{conversationId}/messages")]
        public async Task<IActionResult> GetMessages(Guid conversationId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            // Check if user has access to this conversation
            var conv = await _db.Conversations
                .Where(c => c.Id == conversationId && c.OwnerUserId == UserId)
                .FirstOrDefaultAsync();
                
            if (conv == null) return NotFound();
            
            // Get messages with attachments
            var messages = await _db.Messages
                .Include(m => m.Attachments)
                .Where(m => m.ConversationId == conversationId)
                .OrderByDescending(m => m.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(m => new
                {
                    m.Id,
                    m.Content,
                    m.Role,
                    m.CreatedAt,
                    Attachments = m.Attachments.Select(a => new
                    {
                        a.Id,
                        a.FileName,
                        a.ContentType,
                        a.FileType,
                        a.FileSize,
                        a.ThumbnailPath,
                        a.DurationSeconds,
                        a.TranscriptionText
                    })
                })
                .ToListAsync();
                
            var totalMessages = await _db.Messages.CountAsync(m => m.ConversationId == conversationId);
            
            return Ok(new
            {
                conversationId,
                messages = messages.AsEnumerable().Reverse(), // Return in chronological order
                totalMessages,
                currentPage = page,
                totalPages = (int)Math.Ceiling(totalMessages / (double)pageSize)
            });
        }
    }
}
