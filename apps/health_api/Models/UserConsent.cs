using System.ComponentModel.DataAnnotations;
using System.Net;
using health_api.Models;

namespace HealthApi.Models
{
    public enum ConsentType
    {
        PrivacyNoticeAck,
        SensitiveProcessing,
        CrossBorderTransfer,
        ThirdPartyShare,
        ExternalTransmissionAnalytics,
        ExternalTransmissionCrash,
        Marketing,
        TermsAccept,
        TokushoConfirm
    }

    public class UserConsent
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid UserId { get; set; }
        public User? User { get; set; }

        [Required]
        public ConsentType Type { get; set; }

        [Required]
        [MaxLength(100)]
        public string DocKey { get; set; } = string.Empty; // e.g., 'privacy_policy_ja'

        [Required]
        [MaxLength(50)]
        public string DocVersion { get; set; } = string.Empty; // e.g., '2025-09-06'

        [Required]
        [MaxLength(64)]
        public string ContentSha256 { get; set; } = string.Empty; // Document hash for proof

        [Required]
        public bool Accepted { get; set; }

        [Required]
        [MaxLength(50)]
        public string LegalBasis { get; set; } = "consent";

        [MaxLength(100)]
        public string? Recipient { get; set; } // For sharing/cross-border (e.g., 'OpenAI')

        [MaxLength(10)]
        public string? RecipientCountry { get; set; } // Recipient country (e.g., 'US')

        [Required]
        [MaxLength(50)]
        public string Method { get; set; } = "in_app_checkbox";

        public IPAddress? IpAddress { get; set; }

        [MaxLength(500)]
        public string? UserAgent { get; set; }

        [MaxLength(10)]
        public string? Locale { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? RevokedAt { get; set; }
    }

    public class ThirdPartyProvisionLog
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid UserId { get; set; }
        public User? User { get; set; }

        [Required]
        [MaxLength(200)]
        public string RecipientName { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? RecipientAddress { get; set; }

        [MaxLength(10)]
        public string? RecipientCountry { get; set; }

        [Required]
        public string Categories { get; set; } = string.Empty; // Information categories provided

        [Required]
        [MaxLength(50)]
        public string Method { get; set; } = "electronic";

        public DateTime ProvidedAt { get; set; } = DateTime.UtcNow;
    }
}