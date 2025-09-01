using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace health_api.Models
{
    public enum Plan { Free, Standard, Pro }
    public enum ModelTier { Basic, Enhanced, Realtime }

    public class User
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        [EmailAddress, Required] public string Email { get; set; } = default!;
        [Required] public string Name { get; set; } = default!;
        [Required] public string PasswordHash { get; set; } = default!;
        public string Role { get; set; } = "user"; // 'user' | 'admin'
        public Plan Plan { get; set; } = Plan.Free;
        public ModelTier ModelTier { get; set; } = ModelTier.Basic;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class CareCircle
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        [Required] public string Name { get; set; } = default!;
        public Guid OwnerUserId { get; set; }
        public User? Owner { get; set; }
        public List<CareCircleMember> Members { get; set; } = new();
    }

    public class CareCircleMember
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid CareCircleId { get; set; }
        public CareCircle? CareCircle { get; set; }
        public Guid UserId { get; set; }
        public User? User { get; set; }
        public string Role { get; set; } = "member"; // 'member' | 'caregiver' | 'doctor' | 'admin'
    }

    public class Patient
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        [Required] public string Name { get; set; } = default!;
        public DateOnly? BirthDate { get; set; }
        public string? Gender { get; set; }
        public string? Conditions { get; set; }
        public string? Allergies { get; set; }
        public string? EmergencyContact { get; set; }
        public Guid? PrimaryCircleId { get; set; }
        public CareCircle? PrimaryCircle { get; set; }
    }

    public class Conversation
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        [Required] public string Title { get; set; } = "会话";
        public Guid PatientId { get; set; }
        public Patient? Patient { get; set; }
        public Guid OwnerUserId { get; set; }
        public User? Owner { get; set; }
        public string SummaryText { get; set; } = string.Empty;
        public bool IsShared { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class ShareGrant
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid ConversationId { get; set; }
        public Guid? ToUserId { get; set; }
        public string? ToEmail { get; set; }
        public bool RedactPII { get; set; } = true;
        public DateTime? ExpiresAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? RevokedAt { get; set; }
    }

    public class QuotaUsage
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid UserId { get; set; }
        public DateOnly Date { get; set; }
        public int UsedCount { get; set; } = 0;
    }

    public class ApiKeySecret
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        [Required] public string Provider { get; set; } = "openai";
        [Required] public string Name { get; set; } = "default";
        [Required] public string EncryptedValue { get; set; } = default!; // AES-GCM blob (nonce:tag:cipher)
        public Guid CreatedByUserId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
