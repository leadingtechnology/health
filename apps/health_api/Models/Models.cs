using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace health_api.Models
{
    public enum Plan { Free, Standard, Pro }
    public enum ModelTier { Basic, Enhanced, Realtime }

    public class User
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        [EmailAddress] public string? Email { get; set; } // Optional, but either email or phone required
        public string Name { get; set; } = string.Empty; // Display name (optional)
        public string? PasswordHash { get; set; } // Deprecated - null for OTP accounts
        public string Role { get; set; } = "user"; // 'user' | 'admin'
        public Plan Plan { get; set; } = Plan.Free;
        public ModelTier ModelTier { get; set; } = ModelTier.Basic;
        public string TimeZone { get; set; } = "Asia/Tokyo";
        [Phone] public string? PhoneE164 { get; set; } // E.164 format phone number
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? DeletedAt { get; set; }
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

    public class Task
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid OwnerUserId { get; set; }
        public User? Owner { get; set; }
        public Guid? PatientId { get; set; }
        public Patient? Patient { get; set; }
        [Required] public string Title { get; set; } = default!;
        public DateTime DueAt { get; set; }
        public string? Notes { get; set; }
        public string? Category { get; set; } // 'medication' | 'exercise' | 'appointment' | 'safety' | 'other'
        public bool IsDone { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }

    public class PhoneOtp
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        [Required] public string PhoneE164 { get; set; } = default!;
        public string Purpose { get; set; } = "login"; // 'login' | 'bind' | 'reset'
        [Required] public byte[] CodeHash { get; set; } = default!;
        [Required] public byte[] CodeSalt { get; set; } = default!;
        public int Attempts { get; set; } = 0;
        public DateTime ExpiresAt { get; set; }
        public DateTime? ConsumedAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public string? CreatedIp { get; set; }
        public string? UserAgent { get; set; }
    }

    public class EmailOtp
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        [Required] public string Email { get; set; } = default!;
        public string Purpose { get; set; } = "login"; // 'login' | 'bind' | 'reset'
        [Required] public byte[] CodeHash { get; set; } = default!;
        [Required] public byte[] CodeSalt { get; set; } = default!;
        public int Attempts { get; set; } = 0;
        public DateTime ExpiresAt { get; set; }
        public DateTime? ConsumedAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public string? CreatedIp { get; set; }
        public string? UserAgent { get; set; }
    }
}
