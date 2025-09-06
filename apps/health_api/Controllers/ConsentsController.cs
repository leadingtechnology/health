using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using health_api.Data;
using HealthApi.DTOs;
using HealthApi.Models;
using HealthApi.Services;
using System.Security.Claims;

namespace health_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ConsentsController : ControllerBase
    {
        private readonly HealthDbContext _context;
        private readonly ILegalDocumentService _legalDocumentService;
        private readonly ILogger<ConsentsController> _logger;

        public ConsentsController(
            HealthDbContext context,
            ILegalDocumentService legalDocumentService,
            ILogger<ConsentsController> logger)
        {
            _context = context;
            _legalDocumentService = legalDocumentService;
            _logger = logger;
        }

        /// <summary>
        /// Submit user consents (typically during first login)
        /// </summary>
        [HttpPost("submit")]
        public async Task<IActionResult> SubmitConsents([FromBody] ConsentSubmissionDto dto)
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!Guid.TryParse(userIdStr, out var userId))
            {
                return Unauthorized();
            }

            try
            {
                // Get IP address from request
                var ipAddressStr = dto.IpAddress ?? HttpContext.Connection.RemoteIpAddress?.ToString();
                System.Net.IPAddress? ipAddress = null;
                if (!string.IsNullOrEmpty(ipAddressStr))
                {
                    System.Net.IPAddress.TryParse(ipAddressStr, out ipAddress);
                }
                var userAgent = dto.UserAgent ?? Request.Headers["User-Agent"].ToString();

                var consentsToSave = new List<UserConsent>();

                foreach (var consentItem in dto.Consents)
                {
                    // Verify document hash if provided
                    if (!string.IsNullOrEmpty(consentItem.ContentSha256))
                    {
                        var doc = await _legalDocumentService.GetDocumentAsync(consentItem.DocKey, dto.Locale);
                        if (doc != null && doc.ContentSha256 != consentItem.ContentSha256)
                        {
                            _logger.LogWarning("Document hash mismatch for {DocKey}", consentItem.DocKey);
                            // Continue anyway but log the discrepancy
                        }
                    }

                    // Check if this consent type already exists and is active
                    var existingConsent = await _context.UserConsents
                        .Where(c => c.UserId == userId 
                            && c.Type == consentItem.Type 
                            && c.RevokedAt == null 
                            && c.Accepted)
                        .FirstOrDefaultAsync();

                    if (existingConsent != null)
                    {
                        // Revoke existing consent before adding new one
                        existingConsent.RevokedAt = DateTime.UtcNow;
                    }

                    var consent = new UserConsent
                    {
                        UserId = userId,
                        Type = consentItem.Type,
                        DocKey = consentItem.DocKey,
                        DocVersion = consentItem.DocVersion,
                        ContentSha256 = consentItem.ContentSha256,
                        Accepted = consentItem.Accepted,
                        Recipient = consentItem.Recipient,
                        RecipientCountry = consentItem.RecipientCountry,
                        IpAddress = ipAddress,
                        UserAgent = userAgent,
                        Locale = dto.Locale,
                        CreatedAt = DateTime.UtcNow
                    };

                    consentsToSave.Add(consent);

                    // Log third-party provision if applicable
                    if (!string.IsNullOrEmpty(consentItem.Recipient) && consentItem.Accepted)
                    {
                        var provisionLog = new ThirdPartyProvisionLog
                        {
                            UserId = userId,
                            RecipientName = consentItem.Recipient,
                            RecipientCountry = consentItem.RecipientCountry,
                            Categories = GetCategoriesForConsentType(consentItem.Type),
                            ProvidedAt = DateTime.UtcNow
                        };
                        _context.ThirdPartyProvisionLogs.Add(provisionLog);
                    }
                }

                _context.UserConsents.AddRange(consentsToSave);
                await _context.SaveChangesAsync();

                return Ok(new { success = true, message = "Consents recorded successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error submitting consents for user {UserId}", userId);
                return StatusCode(500, new { error = "Failed to record consents" });
            }
        }

        /// <summary>
        /// Get user's current consent status
        /// </summary>
        [HttpGet("status")]
        public async Task<ActionResult<UserConsentStatusDto>> GetConsentStatus()
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!Guid.TryParse(userIdStr, out var userId))
            {
                return Unauthorized();
            }

            var activeConsents = await _context.UserConsents
                .Where(c => c.UserId == userId && c.RevokedAt == null && c.Accepted)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();

            var status = new UserConsentStatusDto
            {
                HasAgreedToTerms = activeConsents.Any(c => c.Type == ConsentType.TermsAccept),
                HasAgreedToPrivacyPolicy = activeConsents.Any(c => c.Type == ConsentType.PrivacyNoticeAck),
                HasAgreedToDataProcessing = activeConsents.Any(c => c.Type == ConsentType.SensitiveProcessing),
                ActiveConsents = activeConsents.Select(c => new ConsentResponseDto
                {
                    Id = c.Id,
                    Type = c.Type,
                    DocKey = c.DocKey,
                    DocVersion = c.DocVersion,
                    Accepted = c.Accepted,
                    CreatedAt = c.CreatedAt,
                    RevokedAt = c.RevokedAt
                }).ToList(),
                LastConsentDate = activeConsents.OrderByDescending(c => c.CreatedAt).FirstOrDefault()?.CreatedAt
            };

            return Ok(status);
        }

        /// <summary>
        /// Revoke a specific consent
        /// </summary>
        [HttpPost("{consentId}/revoke")]
        public async Task<IActionResult> RevokeConsent(Guid consentId)
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!Guid.TryParse(userIdStr, out var userId))
            {
                return Unauthorized();
            }

            var consent = await _context.UserConsents
                .FirstOrDefaultAsync(c => c.Id == consentId && c.UserId == userId);

            if (consent == null)
            {
                return NotFound();
            }

            if (consent.RevokedAt != null)
            {
                return BadRequest(new { error = "Consent already revoked" });
            }

            consent.RevokedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Consent revoked successfully" });
        }

        /// <summary>
        /// Get legal documents for a specific locale
        /// </summary>
        [HttpGet("documents/{locale}")]
        [AllowAnonymous]
        public async Task<ActionResult<Dictionary<string, LegalDocumentDto>>> GetLegalDocuments(string locale)
        {
            var documents = await _legalDocumentService.GetAllDocumentsByLocaleAsync(locale);
            return Ok(documents);
        }

        /// <summary>
        /// Get a specific legal document
        /// </summary>
        [HttpGet("documents/{locale}/{docKey}")]
        [AllowAnonymous]
        public async Task<ActionResult<LegalDocumentDto>> GetLegalDocument(string locale, string docKey)
        {
            var document = await _legalDocumentService.GetDocumentAsync(docKey, locale);
            if (document == null)
            {
                return NotFound();
            }
            return Ok(document);
        }

        private string GetCategoriesForConsentType(ConsentType type)
        {
            return type switch
            {
                ConsentType.SensitiveProcessing => "Health data, medical history, symptoms",
                ConsentType.CrossBorderTransfer => "Personal data for AI processing",
                ConsentType.ThirdPartyShare => "User queries and responses",
                _ => "General personal information"
            };
        }
    }
}