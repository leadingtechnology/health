using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using health_api.Data;
using health_api.DTOs;
using health_api.Models;
using health_api.Services;
using System.Linq;

namespace health_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OpenAIController : ControllerBase
    {
        private readonly HealthDbContext _db;
        private readonly OpenAIService _svc;
        private readonly QuotaService _quota;
        public OpenAIController(HealthDbContext db, OpenAIService svc, QuotaService quota) { _db = db; _svc = svc; _quota = quota; }

        private Guid? TryGetUserId()
        {
            var sub = User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier)
                      ?? User.FindFirstValue("sub");
            return Guid.TryParse(sub, out var id) ? id : (Guid?)null;
        }

        [HttpPost("ask")]
        public async Task<ActionResult<OpenAIAskResponse>> Ask([FromBody] OpenAIAskRequest req)
        {
            var uid = TryGetUserId();
            if (uid is null) return Unauthorized("Invalid or missing user identity");
            var user = await _db.Users.FindAsync(uid.Value);
            if (user == null) return Unauthorized();
            // Enforce quota for Free plan BEFORE calling model (or do "after first token" on streaming)
            var ok = await _quota.TryConsumeAsync(user.Id, user.Plan, "ask");
            if (!ok) return StatusCode(429, "Daily free quota reached");

            // Get or create a default conversation for the user
            var conversation = await GetOrCreateDefaultConversation(user.Id);
            
            // Save user message to database
            var userMessage = new Message
            {
                Id = Guid.NewGuid(),
                ConversationId = conversation.Id,
                UserId = user.Id,
                Content = req.Prompt,
                Role = "user",
                CreatedAt = DateTime.UtcNow
            };
            _db.Messages.Add(userMessage);
            await _db.SaveChangesAsync();

            var (reply, model, inTok, outTok) = await _svc.AskAsync(user.Id, req.Prompt, req.Model);
            
            // Save AI response to database
            var aiMessage = new Message
            {
                Id = Guid.NewGuid(),
                ConversationId = conversation.Id,
                UserId = user.Id,
                Content = reply,
                Role = "assistant",
                CreatedAt = DateTime.UtcNow
            };
            _db.Messages.Add(aiMessage);
            await _db.SaveChangesAsync();
            
            return new OpenAIAskResponse(reply, model, inTok, outTok);
        }

        [HttpPost("ask-with-images")]
        public async Task<ActionResult<OpenAIAskResponse>> AskWithImages([FromBody] OpenAIAskWithImagesRequest req)
        {
            var uid = TryGetUserId();
            if (uid is null) return Unauthorized("Invalid or missing user identity");
            var user = await _db.Users.FindAsync(uid.Value);
            if (user == null) return Unauthorized();
            
            // Vision API requires at least Standard plan
            if (user.Plan == Plan.Free)
                return StatusCode(403, "Image analysis requires Standard plan or higher");
            
            // Enforce quota
            var ok = await _quota.TryConsumeAsync(user.Id, user.Plan, "ask-with-images");
            if (!ok) return StatusCode(429, "Monthly quota reached");

            // Get or create a default conversation for the user
            var conversation = await GetOrCreateDefaultConversation(user.Id);
            
            // Save user message with attachments info to database
            var userMessage = new Message
            {
                Id = Guid.NewGuid(),
                ConversationId = conversation.Id,
                UserId = user.Id,
                Content = req.Prompt + $"\n[Attached {req.Images.Count} image(s)]",
                Role = "user",
                CreatedAt = DateTime.UtcNow
            };
            _db.Messages.Add(userMessage);
            
            // Save attachment metadata
            int imageIndex = 0;
            foreach (var imageBase64 in req.Images)
            {
                var attachment = new MessageAttachment
                {
                    Id = Guid.NewGuid(),
                    MessageId = userMessage.Id,
                    FileName = $"image_{imageIndex++}.jpg",
                    ContentType = "image/jpeg",
                    FileType = "image",
                    StoragePath = "base64_embedded", // For now storing as base64
                    FileSize = imageBase64.Length,
                    CreatedAt = DateTime.UtcNow
                };
                _db.MessageAttachments.Add(attachment);
            }
            
            await _db.SaveChangesAsync();

            var (reply, model, inTok, outTok) = await _svc.AskWithImagesAsync(user.Id, req.Prompt, req.Images);
            
            // Save AI response to database
            var aiMessage = new Message
            {
                Id = Guid.NewGuid(),
                ConversationId = conversation.Id,
                UserId = user.Id,
                Content = reply,
                Role = "assistant",
                CreatedAt = DateTime.UtcNow
            };
            _db.Messages.Add(aiMessage);
            await _db.SaveChangesAsync();
            
            return new OpenAIAskResponse(reply, model, inTok, outTok);
        }
        
        private async Task<Conversation> GetOrCreateDefaultConversation(Guid userId)
        {
            // Try to find a default conversation for the user
            var conversation = await _db.Conversations
                .Where(c => c.OwnerUserId == userId && c.Title == "Health Assistant Chat")
                .OrderByDescending(c => c.CreatedAt)
                .FirstOrDefaultAsync();
            
            if (conversation == null)
            {
                // Get user's first care circle to get a patient
                var careCircle = await _db.CareCircles
                    .Include(c => c.Members)
                    .Where(c => c.OwnerUserId == userId)
                    .FirstOrDefaultAsync();
                
                Patient? patient = null;
                
                if (careCircle != null)
                {
                    // Try to get patient from care circle
                    patient = await _db.Patients
                        .Where(p => p.PrimaryCircleId == careCircle.Id)
                        .FirstOrDefaultAsync();
                }
                
                if (patient == null)
                {
                    // Create a default patient for the user
                    patient = new Patient
                    {
                        Id = Guid.NewGuid(),
                        Name = "Self",
                        PrimaryCircleId = careCircle?.Id
                    };
                    _db.Patients.Add(patient);
                    await _db.SaveChangesAsync();
                }
                
                // Create default conversation
                conversation = new Conversation
                {
                    Id = Guid.NewGuid(),
                    Title = "Health Assistant Chat",
                    PatientId = patient.Id,
                    OwnerUserId = userId,
                    SummaryText = "General health consultation and Q&A",
                    IsShared = false,
                    CreatedAt = DateTime.UtcNow
                };
                _db.Conversations.Add(conversation);
                await _db.SaveChangesAsync();
            }
            
            return conversation;
        }
    }
}
