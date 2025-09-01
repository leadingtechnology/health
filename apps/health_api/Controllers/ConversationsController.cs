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
    }
}
