using HealthApi.Models;

namespace HealthApi.DTOs
{
    public class ConsentSubmissionDto
    {
        public List<ConsentItemDto> Consents { get; set; } = new();
        public string? IpAddress { get; set; }
        public string? UserAgent { get; set; }
        public string Locale { get; set; } = "en";
    }

    public class ConsentItemDto
    {
        public ConsentType Type { get; set; }
        public string DocKey { get; set; } = string.Empty;
        public string DocVersion { get; set; } = string.Empty;
        public string ContentSha256 { get; set; } = string.Empty;
        public bool Accepted { get; set; }
        public string? Recipient { get; set; }
        public string? RecipientCountry { get; set; }
    }

    public class ConsentResponseDto
    {
        public Guid Id { get; set; }
        public ConsentType Type { get; set; }
        public string DocKey { get; set; } = string.Empty;
        public string DocVersion { get; set; } = string.Empty;
        public bool Accepted { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? RevokedAt { get; set; }
    }

    public class UserConsentStatusDto
    {
        public bool HasAgreedToTerms { get; set; }
        public bool HasAgreedToPrivacyPolicy { get; set; }
        public bool HasAgreedToDataProcessing { get; set; }
        public List<ConsentResponseDto> ActiveConsents { get; set; } = new();
        public DateTime? LastConsentDate { get; set; }
    }

    public class LegalDocumentDto
    {
        public string Key { get; set; } = string.Empty;
        public string Version { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string ContentSha256 { get; set; } = string.Empty;
        public string Locale { get; set; } = string.Empty;
        public DateTime EffectiveDate { get; set; }
    }
}