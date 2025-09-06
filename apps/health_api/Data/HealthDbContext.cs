using Microsoft.EntityFrameworkCore;
using health_api.Models;
using HealthApi.Models;

namespace health_api.Data
{
    public class HealthDbContext : DbContext
    {
        public HealthDbContext(DbContextOptions<HealthDbContext> options) : base(options) { }

        public DbSet<User> Users => Set<User>();
        public DbSet<CareCircle> CareCircles => Set<CareCircle>();
        public DbSet<CareCircleMember> CareCircleMembers => Set<CareCircleMember>();
        public DbSet<Patient> Patients => Set<Patient>();
        public DbSet<Conversation> Conversations => Set<Conversation>();
        public DbSet<Message> Messages => Set<Message>();
        public DbSet<MessageAttachment> MessageAttachments => Set<MessageAttachment>();
        public DbSet<ShareGrant> ShareGrants => Set<ShareGrant>();
        public DbSet<QuotaUsage> QuotaUsages => Set<QuotaUsage>();
        public DbSet<ApiKeySecret> ApiKeys => Set<ApiKeySecret>();
        public DbSet<Models.Task> Tasks => Set<Models.Task>();
        public DbSet<PhoneOtp> PhoneOtps => Set<PhoneOtp>();
        public DbSet<EmailOtp> EmailOtps => Set<EmailOtp>();
        public DbSet<UserConsent> UserConsents => Set<UserConsent>();
        public DbSet<ThirdPartyProvisionLog> ThirdPartyProvisionLogs => Set<ThirdPartyProvisionLog>();

        protected override void OnModelCreating(ModelBuilder b)
        {
            // Configure schema - using public schema
            b.HasDefaultSchema("public");

            // Configure table names to be lowercase
            b.Entity<User>().ToTable("users");
            b.Entity<CareCircle>().ToTable("care_circles");
            b.Entity<CareCircleMember>().ToTable("care_circle_members");
            b.Entity<Patient>().ToTable("patients");
            b.Entity<Conversation>().ToTable("conversations");
            b.Entity<Message>().ToTable("messages");
            b.Entity<MessageAttachment>().ToTable("message_attachments");
            b.Entity<ShareGrant>().ToTable("share_grants");
            b.Entity<QuotaUsage>().ToTable("quota_usages");
            b.Entity<ApiKeySecret>().ToTable("api_key_secrets");
            b.Entity<Models.Task>().ToTable("tasks");

            // User indexes - email and phone can be null but must be unique when not null
            b.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique()
                .HasFilter("deleted_at IS NULL AND email IS NOT NULL")
                .HasDatabaseName("ux_users_email_active");
            
            b.Entity<User>()
                .HasIndex(u => u.PhoneE164)
                .IsUnique()
                .HasFilter("deleted_at IS NULL AND phone_e164 IS NOT NULL")
                .HasDatabaseName("ux_users_phone_active");

            // Map property names to database columns
            b.Entity<User>().Property(u => u.Id).HasColumnName("id");
            b.Entity<User>().Property(u => u.Email).HasColumnName("email");
            b.Entity<User>().Property(u => u.Name).HasColumnName("name");
            b.Entity<User>().Property(u => u.Role).HasColumnName("role");
            b.Entity<User>().Property(u => u.PhoneE164).HasColumnName("phone_e164");
            b.Entity<User>().Property(u => u.TimeZone).HasColumnName("time_zone");
            b.Entity<User>().Property(u => u.PasswordHash).HasColumnName("password_hash");
            b.Entity<User>().Property(u => u.CreatedAt).HasColumnName("created_at");
            b.Entity<User>().Property(u => u.UpdatedAt).HasColumnName("updated_at");
            b.Entity<User>().Property(u => u.DeletedAt).HasColumnName("deleted_at");
            
            // PostgreSQL enum types are now mapped at the data source level in Program.cs
            b.Entity<User>().Property(u => u.Plan).HasColumnName("plan");
            b.Entity<User>().Property(u => u.ModelTier).HasColumnName("model_tier");

            b.Entity<CareCircleMember>().HasIndex(m => new { m.CareCircleId, m.UserId }).IsUnique();
            
            // QuotaUsage configuration
            b.Entity<QuotaUsage>().HasIndex(q => new { q.UserId, q.Date }).IsUnique();
            b.Entity<QuotaUsage>().Property(q => q.Id).HasColumnName("id");
            b.Entity<QuotaUsage>().Property(q => q.UserId).HasColumnName("user_id");
            b.Entity<QuotaUsage>().Property(q => q.Date).HasColumnName("local_date");  // Column is named local_date in PostgreSQL
            b.Entity<QuotaUsage>().Property(q => q.UsedCount).HasColumnName("used_count");

            // ShareGrant configuration
            b.Entity<ShareGrant>().Property(s => s.Id).HasColumnName("id");
            b.Entity<ShareGrant>().Property(s => s.ConversationId).HasColumnName("conversation_id");
            b.Entity<ShareGrant>().Property(s => s.ToUserId).HasColumnName("to_user_id");
            b.Entity<ShareGrant>().Property(s => s.ToEmail).HasColumnName("to_email");
            b.Entity<ShareGrant>().Property(s => s.RedactPII).HasColumnName("redact_pii");
            b.Entity<ShareGrant>().Property(s => s.ExpiresAt).HasColumnName("expires_at");
            b.Entity<ShareGrant>().Property(s => s.CreatedAt).HasColumnName("created_at");
            b.Entity<ShareGrant>().Property(s => s.RevokedAt).HasColumnName("revoked_at");

            // ApiKeySecret configuration
            b.Entity<ApiKeySecret>().Property(a => a.Id).HasColumnName("id");
            b.Entity<ApiKeySecret>().Property(a => a.Provider).HasColumnName("provider");
            b.Entity<ApiKeySecret>().Property(a => a.Name).HasColumnName("name");
            b.Entity<ApiKeySecret>().Property(a => a.EncryptedValue).HasColumnName("encrypted_value");
            b.Entity<ApiKeySecret>().Property(a => a.CreatedByUserId).HasColumnName("created_by_user_id");
            b.Entity<ApiKeySecret>().Property(a => a.CreatedAt).HasColumnName("created_at");
            
            // Task entity configuration
            b.Entity<Models.Task>().Property(t => t.Id).HasColumnName("id");
            b.Entity<Models.Task>().Property(t => t.OwnerUserId).HasColumnName("owner_user_id");
            b.Entity<Models.Task>().Property(t => t.PatientId).HasColumnName("patient_id");
            b.Entity<Models.Task>().Property(t => t.Title).HasColumnName("title");
            b.Entity<Models.Task>().Property(t => t.DueAt).HasColumnName("due_at");
            b.Entity<Models.Task>().Property(t => t.Notes).HasColumnName("notes");
            b.Entity<Models.Task>().Property(t => t.Category).HasColumnName("category");
            b.Entity<Models.Task>().Property(t => t.IsDone).HasColumnName("is_done");
            b.Entity<Models.Task>().Property(t => t.CreatedAt).HasColumnName("created_at");
            b.Entity<Models.Task>().Property(t => t.UpdatedAt).HasColumnName("updated_at");
            b.Entity<Models.Task>()
                .HasOne(t => t.Owner).WithMany().HasForeignKey(t => t.OwnerUserId).OnDelete(DeleteBehavior.Cascade);
            b.Entity<Models.Task>()
                .HasOne(t => t.Patient).WithMany().HasForeignKey(t => t.PatientId).OnDelete(DeleteBehavior.SetNull);

            // OTP tables configuration
            b.Entity<PhoneOtp>().ToTable("phone_otp");
            b.Entity<PhoneOtp>().Property(o => o.Id).HasColumnName("id");
            b.Entity<PhoneOtp>().Property(o => o.PhoneE164).HasColumnName("phone_e164");
            b.Entity<PhoneOtp>().Property(o => o.Purpose).HasColumnName("purpose");
            b.Entity<PhoneOtp>().Property(o => o.CodeHash).HasColumnName("code_hash");
            b.Entity<PhoneOtp>().Property(o => o.CodeSalt).HasColumnName("code_salt");
            b.Entity<PhoneOtp>().Property(o => o.Attempts).HasColumnName("attempts");
            b.Entity<PhoneOtp>().Property(o => o.ExpiresAt).HasColumnName("expires_at");
            b.Entity<PhoneOtp>().Property(o => o.ConsumedAt).HasColumnName("consumed_at");
            b.Entity<PhoneOtp>().Property(o => o.CreatedAt).HasColumnName("created_at");
            b.Entity<PhoneOtp>().Property(o => o.CreatedIp).HasColumnName("created_ip");
            b.Entity<PhoneOtp>().Property(o => o.UserAgent).HasColumnName("user_agent");

            b.Entity<EmailOtp>().ToTable("email_otp");
            b.Entity<EmailOtp>().Property(o => o.Id).HasColumnName("id");
            b.Entity<EmailOtp>().Property(o => o.Email).HasColumnName("email");
            b.Entity<EmailOtp>().Property(o => o.Purpose).HasColumnName("purpose");
            b.Entity<EmailOtp>().Property(o => o.CodeHash).HasColumnName("code_hash");
            b.Entity<EmailOtp>().Property(o => o.CodeSalt).HasColumnName("code_salt");
            b.Entity<EmailOtp>().Property(o => o.Attempts).HasColumnName("attempts");
            b.Entity<EmailOtp>().Property(o => o.ExpiresAt).HasColumnName("expires_at");
            b.Entity<EmailOtp>().Property(o => o.ConsumedAt).HasColumnName("consumed_at");
            b.Entity<EmailOtp>().Property(o => o.CreatedAt).HasColumnName("created_at");
            b.Entity<EmailOtp>().Property(o => o.CreatedIp).HasColumnName("created_ip");
            b.Entity<EmailOtp>().Property(o => o.UserAgent).HasColumnName("user_agent");

            // CareCircle configuration
            b.Entity<CareCircle>().Property(c => c.Id).HasColumnName("id");
            b.Entity<CareCircle>().Property(c => c.Name).HasColumnName("name");
            b.Entity<CareCircle>().Property(c => c.OwnerUserId).HasColumnName("owner_user_id");
            b.Entity<CareCircle>()
                .HasOne(c => c.Owner).WithMany().HasForeignKey(c => c.OwnerUserId).OnDelete(DeleteBehavior.Restrict);

            // CareCircleMember configuration
            b.Entity<CareCircleMember>().Property(m => m.Id).HasColumnName("id");
            b.Entity<CareCircleMember>().Property(m => m.CareCircleId).HasColumnName("care_circle_id");
            b.Entity<CareCircleMember>().Property(m => m.UserId).HasColumnName("user_id");
            b.Entity<CareCircleMember>().Property(m => m.Role).HasColumnName("role");
            b.Entity<CareCircleMember>()
                .HasOne(m => m.CareCircle).WithMany(c => c.Members).HasForeignKey(m => m.CareCircleId);
            b.Entity<CareCircleMember>()
                .HasOne(m => m.User).WithMany().HasForeignKey(m => m.UserId);

            // Patient configuration
            b.Entity<Patient>().Property(p => p.Id).HasColumnName("id");
            b.Entity<Patient>().Property(p => p.Name).HasColumnName("name");
            b.Entity<Patient>().Property(p => p.BirthDate).HasColumnName("birth_date");
            b.Entity<Patient>().Property(p => p.Gender).HasColumnName("gender");
            b.Entity<Patient>().Property(p => p.Conditions).HasColumnName("conditions");
            b.Entity<Patient>().Property(p => p.Allergies).HasColumnName("allergies");
            b.Entity<Patient>().Property(p => p.EmergencyContact).HasColumnName("emergency_contact");
            b.Entity<Patient>().Property(p => p.PrimaryCircleId).HasColumnName("primary_circle_id");
            b.Entity<Patient>()
                .HasOne(p => p.PrimaryCircle).WithMany().HasForeignKey(p => p.PrimaryCircleId).OnDelete(DeleteBehavior.SetNull);

            // Conversation configuration - Add column mappings
            b.Entity<Conversation>().Property(c => c.Id).HasColumnName("id");
            b.Entity<Conversation>().Property(c => c.Title).HasColumnName("title");
            b.Entity<Conversation>().Property(c => c.PatientId).HasColumnName("patient_id");
            b.Entity<Conversation>().Property(c => c.OwnerUserId).HasColumnName("owner_user_id");
            b.Entity<Conversation>().Property(c => c.SummaryText).HasColumnName("summary_text");
            b.Entity<Conversation>().Property(c => c.IsShared).HasColumnName("is_shared");
            b.Entity<Conversation>().Property(c => c.CreatedAt).HasColumnName("created_at");
            
            b.Entity<Conversation>()
                .HasOne(c => c.Patient).WithMany().HasForeignKey(c => c.PatientId).OnDelete(DeleteBehavior.Cascade);
            b.Entity<Conversation>()
                .HasOne(c => c.Owner).WithMany().HasForeignKey(c => c.OwnerUserId).OnDelete(DeleteBehavior.Cascade);

            // Message configuration
            b.Entity<Message>().ToTable("messages");
            b.Entity<Message>().Property(m => m.Id).HasColumnName("id");
            b.Entity<Message>().Property(m => m.ConversationId).HasColumnName("conversation_id");
            b.Entity<Message>().Property(m => m.UserId).HasColumnName("user_id");
            b.Entity<Message>().Property(m => m.Content).HasColumnName("content");
            b.Entity<Message>().Property(m => m.Role).HasColumnName("role");
            b.Entity<Message>().Property(m => m.CreatedAt).HasColumnName("created_at");
            b.Entity<Message>()
                .HasOne(m => m.Conversation).WithMany(c => c.Messages).HasForeignKey(m => m.ConversationId).OnDelete(DeleteBehavior.Cascade);
            b.Entity<Message>()
                .HasOne(m => m.User).WithMany().HasForeignKey(m => m.UserId).OnDelete(DeleteBehavior.Cascade);

            // MessageAttachment configuration  
            b.Entity<MessageAttachment>().ToTable("message_attachments");
            b.Entity<MessageAttachment>().Property(a => a.Id).HasColumnName("id");
            b.Entity<MessageAttachment>().Property(a => a.MessageId).HasColumnName("message_id");
            b.Entity<MessageAttachment>().Property(a => a.FileName).HasColumnName("file_name");
            b.Entity<MessageAttachment>().Property(a => a.ContentType).HasColumnName("content_type");
            b.Entity<MessageAttachment>().Property(a => a.FileType).HasColumnName("file_type");
            b.Entity<MessageAttachment>().Property(a => a.StoragePath).HasColumnName("storage_path");
            b.Entity<MessageAttachment>().Property(a => a.FileSize).HasColumnName("file_size");
            b.Entity<MessageAttachment>().Property(a => a.ThumbnailPath).HasColumnName("thumbnail_path");
            b.Entity<MessageAttachment>().Property(a => a.DurationSeconds).HasColumnName("duration_seconds");
            b.Entity<MessageAttachment>().Property(a => a.TranscriptionText).HasColumnName("transcription_text");
            b.Entity<MessageAttachment>().Property(a => a.CreatedAt).HasColumnName("created_at");
            b.Entity<MessageAttachment>()
                .HasOne(a => a.Message).WithMany(m => m.Attachments).HasForeignKey(a => a.MessageId).OnDelete(DeleteBehavior.Cascade);

            // UserConsent configuration
            b.Entity<UserConsent>().ToTable("user_consents");
            b.Entity<UserConsent>().Property(c => c.Id).HasColumnName("id");
            b.Entity<UserConsent>().Property(c => c.UserId).HasColumnName("user_id");
            b.Entity<UserConsent>().Property(c => c.Type).HasColumnName("type");
            b.Entity<UserConsent>().Property(c => c.DocKey).HasColumnName("doc_key");
            b.Entity<UserConsent>().Property(c => c.DocVersion).HasColumnName("doc_version");
            b.Entity<UserConsent>().Property(c => c.ContentSha256).HasColumnName("content_sha256");
            b.Entity<UserConsent>().Property(c => c.Accepted).HasColumnName("accepted");
            b.Entity<UserConsent>().Property(c => c.LegalBasis).HasColumnName("legal_basis");
            b.Entity<UserConsent>().Property(c => c.Recipient).HasColumnName("recipient");
            b.Entity<UserConsent>().Property(c => c.RecipientCountry).HasColumnName("recipient_country");
            b.Entity<UserConsent>().Property(c => c.Method).HasColumnName("method");
            b.Entity<UserConsent>().Property(c => c.IpAddress).HasColumnName("ip");
            b.Entity<UserConsent>().Property(c => c.UserAgent).HasColumnName("user_agent");
            b.Entity<UserConsent>().Property(c => c.Locale).HasColumnName("locale");
            b.Entity<UserConsent>().Property(c => c.CreatedAt).HasColumnName("created_at");
            b.Entity<UserConsent>().Property(c => c.RevokedAt).HasColumnName("revoked_at");
            b.Entity<UserConsent>()
                .HasOne(c => c.User).WithMany().HasForeignKey(c => c.UserId).OnDelete(DeleteBehavior.Cascade);
            b.Entity<UserConsent>()
                .HasIndex(c => new { c.UserId, c.Type })
                .HasFilter("revoked_at IS NULL AND accepted = true")
                .HasDatabaseName("ux_user_consents_active");

            // ThirdPartyProvisionLog configuration
            b.Entity<ThirdPartyProvisionLog>().ToTable("third_party_provision_log");
            b.Entity<ThirdPartyProvisionLog>().Property(l => l.Id).HasColumnName("id");
            b.Entity<ThirdPartyProvisionLog>().Property(l => l.UserId).HasColumnName("user_id");
            b.Entity<ThirdPartyProvisionLog>().Property(l => l.RecipientName).HasColumnName("recipient_name");
            b.Entity<ThirdPartyProvisionLog>().Property(l => l.RecipientAddress).HasColumnName("recipient_address");
            b.Entity<ThirdPartyProvisionLog>().Property(l => l.RecipientCountry).HasColumnName("recipient_country");
            b.Entity<ThirdPartyProvisionLog>().Property(l => l.Categories).HasColumnName("categories");
            b.Entity<ThirdPartyProvisionLog>().Property(l => l.Method).HasColumnName("method");
            b.Entity<ThirdPartyProvisionLog>().Property(l => l.ProvidedAt).HasColumnName("provided_at");
            b.Entity<ThirdPartyProvisionLog>()
                .HasOne(l => l.User).WithMany().HasForeignKey(l => l.UserId).OnDelete(DeleteBehavior.Cascade);
        }
    }
}
