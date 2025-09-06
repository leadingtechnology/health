using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using health_api.Data;
using health_api.Models;
using health_api.Services;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

namespace health_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MessagesController : ControllerBase
    {
        private readonly HealthDbContext _db;
        private readonly OpenAIService _openai;
        private readonly IWebHostEnvironment _env;
        private readonly IConfiguration _config;
        private const long MaxFileSize = 10 * 1024 * 1024; // 10MB
        private readonly string[] AllowedImageTypes = { "image/jpeg", "image/png", "image/gif", "image/webp" };
        private readonly string[] AllowedAudioTypes = { "audio/mpeg", "audio/wav", "audio/ogg", "audio/webm", "audio/mp4" };

        public MessagesController(HealthDbContext db, OpenAIService openai, IWebHostEnvironment env, IConfiguration config)
        {
            _db = db;
            _openai = openai;
            _env = env;
            _config = config;
        }

        private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!);

        // Send a message with optional attachments
        [HttpPost("send")]
        public async Task<IActionResult> SendMessage([FromForm] SendMessageRequest request)
        {
            // Validate conversation ownership
            var conversation = await _db.Conversations
                .Include(c => c.Messages)
                .FirstOrDefaultAsync(c => c.Id == request.ConversationId && c.OwnerUserId == UserId);
            
            if (conversation == null)
                return NotFound("Conversation not found or access denied");

            // Create message
            var message = new Message
            {
                ConversationId = request.ConversationId,
                UserId = UserId,
                Content = request.Content,
                Role = "user"
            };

            // Handle file attachments
            if (request.Attachments != null && request.Attachments.Any())
            {
                foreach (var file in request.Attachments)
                {
                    if (file.Length > MaxFileSize)
                        return BadRequest($"File {file.FileName} exceeds maximum size of 10MB");

                    var attachment = await ProcessAttachment(file, message.Id);
                    if (attachment != null)
                        message.Attachments.Add(attachment);
                }
            }

            _db.Messages.Add(message);
            await _db.SaveChangesAsync();

            // Process with OpenAI if needed
            if (request.RequestAIResponse)
            {
                var aiResponse = await GenerateAIResponse(message, conversation);
                if (aiResponse != null)
                {
                    _db.Messages.Add(aiResponse);
                    await _db.SaveChangesAsync();
                }
            }

            return Ok(new
            {
                message = FormatMessage(message),
                aiResponse = request.RequestAIResponse ? FormatMessage(await _db.Messages
                    .Include(m => m.Attachments)
                    .Where(m => m.ConversationId == request.ConversationId && m.Role == "assistant")
                    .OrderByDescending(m => m.CreatedAt)
                    .FirstOrDefaultAsync()) : null
            });
        }

        // Upload file attachment
        private async Task<MessageAttachment?> ProcessAttachment(IFormFile file, Guid messageId)
        {
            var contentType = file.ContentType.ToLower();
            var fileType = GetFileType(contentType);
            
            if (fileType == null)
                return null; // Unsupported file type

            // Generate unique file name
            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var uploadPath = Path.Combine(_env.WebRootPath ?? "wwwroot", "uploads", fileType, DateTime.Now.ToString("yyyy-MM"));
            Directory.CreateDirectory(uploadPath);
            var filePath = Path.Combine(uploadPath, fileName);

            // Save file
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var attachment = new MessageAttachment
            {
                MessageId = messageId,
                FileName = file.FileName,
                ContentType = contentType,
                FileType = fileType,
                StoragePath = $"/uploads/{fileType}/{DateTime.Now:yyyy-MM}/{fileName}",
                FileSize = file.Length
            };

            // Generate thumbnail for images
            if (fileType == "image")
            {
                var thumbnailPath = await GenerateThumbnail(filePath, uploadPath, fileName);
                if (thumbnailPath != null)
                    attachment.ThumbnailPath = $"/uploads/{fileType}/{DateTime.Now:yyyy-MM}/thumb_{fileName}";
            }

            // For audio files, you might want to get duration or transcribe
            if (fileType == "audio")
            {
                // TODO: Implement audio duration detection
                // TODO: Implement audio transcription using OpenAI Whisper API
            }

            return attachment;
        }

        private string? GetFileType(string contentType)
        {
            if (AllowedImageTypes.Contains(contentType))
                return "image";
            if (AllowedAudioTypes.Contains(contentType))
                return "audio";
            return null;
        }

        private async Task<string?> GenerateThumbnail(string originalPath, string uploadPath, string fileName)
        {
            try
            {
                using var image = await Image.LoadAsync(originalPath);
                image.Mutate(x => x.Resize(new ResizeOptions
                {
                    Size = new Size(200, 200),
                    Mode = ResizeMode.Max
                }));
                
                var thumbnailPath = Path.Combine(uploadPath, $"thumb_{fileName}");
                await image.SaveAsJpegAsync(thumbnailPath);
                return thumbnailPath;
            }
            catch
            {
                return null;
            }
        }

        private async Task<Message?> GenerateAIResponse(Message userMessage, Conversation conversation)
        {
            try
            {
                // Build context including attachments info
                var prompt = userMessage.Content;
                if (userMessage.Attachments.Any())
                {
                    var attachmentInfo = string.Join(", ", userMessage.Attachments.Select(a => 
                        a.FileType == "image" ? $"[Image: {a.FileName}]" :
                        a.FileType == "audio" ? $"[Audio: {a.FileName}{(a.TranscriptionText != null ? $" - Transcription: {a.TranscriptionText}" : "")}]" :
                        $"[File: {a.FileName}]"
                    ));
                    prompt = $"{attachmentInfo}\n\n{prompt}";
                }

                // Get recent conversation history for context
                var recentMessages = await _db.Messages
                    .Where(m => m.ConversationId == conversation.Id)
                    .OrderByDescending(m => m.CreatedAt)
                    .Take(10)
                    .OrderBy(m => m.CreatedAt)
                    .Select(m => new { m.Role, m.Content })
                    .ToListAsync();

                var contextPrompt = string.Join("\n", recentMessages.Select(m => $"{m.Role}: {m.Content}"));
                contextPrompt += $"\nuser: {prompt}\nassistant:";

                var (reply, model, inTokens, outTokens) = await _openai.AskAsync(UserId, contextPrompt);

                return new Message
                {
                    ConversationId = conversation.Id,
                    UserId = UserId,
                    Content = reply,
                    Role = "assistant"
                };
            }
            catch (Exception ex)
            {
                // Log error
                Console.WriteLine($"AI Response Error: {ex.Message}");
                return null;
            }
        }

        // Get messages for a conversation
        [HttpGet("conversation/{conversationId}")]
        public async Task<IActionResult> GetMessages(Guid conversationId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            var conversation = await _db.Conversations
                .FirstOrDefaultAsync(c => c.Id == conversationId && c.OwnerUserId == UserId);
            
            if (conversation == null)
                return NotFound("Conversation not found or access denied");

            var messages = await _db.Messages
                .Include(m => m.Attachments)
                .Include(m => m.User)
                .Where(m => m.ConversationId == conversationId)
                .OrderByDescending(m => m.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Ok(messages.Select(FormatMessage));
        }

        // Download attachment
        [HttpGet("attachment/{attachmentId}")]
        public async Task<IActionResult> DownloadAttachment(Guid attachmentId)
        {
            var attachment = await _db.MessageAttachments
                .Include(a => a.Message)
                    .ThenInclude(m => m.Conversation)
                .FirstOrDefaultAsync(a => a.Id == attachmentId);

            if (attachment == null || attachment.Message?.Conversation?.OwnerUserId != UserId)
                return NotFound("Attachment not found or access denied");

            var filePath = Path.Combine(_env.WebRootPath ?? "wwwroot", attachment.StoragePath.TrimStart('/'));
            if (!System.IO.File.Exists(filePath))
                return NotFound("File not found");

            var fileBytes = await System.IO.File.ReadAllBytesAsync(filePath);
            return File(fileBytes, attachment.ContentType, attachment.FileName);
        }

        private object FormatMessage(Message? message)
        {
            if (message == null) return null!;
            
            return new
            {
                id = message.Id,
                content = message.Content,
                role = message.Role,
                userId = message.UserId,
                userName = message.User?.Name,
                createdAt = message.CreatedAt,
                attachments = message.Attachments?.Select(a => new
                {
                    id = a.Id,
                    fileName = a.FileName,
                    fileType = a.FileType,
                    contentType = a.ContentType,
                    fileSize = a.FileSize,
                    url = a.StoragePath,
                    thumbnailUrl = a.ThumbnailPath,
                    duration = a.DurationSeconds,
                    transcription = a.TranscriptionText
                })
            };
        }
    }

    public class SendMessageRequest
    {
        public Guid ConversationId { get; set; }
        public string Content { get; set; } = string.Empty;
        public bool RequestAIResponse { get; set; } = true;
        public List<IFormFile>? Attachments { get; set; }
    }
}