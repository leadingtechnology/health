using Microsoft.EntityFrameworkCore;
using health_api.Models;

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
        public DbSet<ShareGrant> ShareGrants => Set<ShareGrant>();
        public DbSet<QuotaUsage> QuotaUsages => Set<QuotaUsage>();
        public DbSet<ApiKeySecret> ApiKeys => Set<ApiKeySecret>();
        public DbSet<Models.Task> Tasks => Set<Models.Task>();
        public DbSet<PhoneOtp> PhoneOtps => Set<PhoneOtp>();
        public DbSet<EmailOtp> EmailOtps => Set<EmailOtp>();

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
            b.Entity<QuotaUsage>().HasIndex(q => new { q.UserId, q.Date }).IsUnique();

            // Task entity configuration
            b.Entity<Models.Task>()
                .HasOne(t => t.Owner).WithMany().HasForeignKey(t => t.OwnerUserId).OnDelete(DeleteBehavior.Cascade);
            b.Entity<Models.Task>()
                .HasOne(t => t.Patient).WithMany().HasForeignKey(t => t.PatientId).OnDelete(DeleteBehavior.SetNull);
            b.Entity<Models.Task>().Property(t => t.DueAt).HasColumnName("due_at");
            b.Entity<Models.Task>().Property(t => t.IsDone).HasColumnName("is_done");
            b.Entity<Models.Task>().Property(t => t.CreatedAt).HasColumnName("created_at");
            b.Entity<Models.Task>().Property(t => t.UpdatedAt).HasColumnName("updated_at");

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

            b.Entity<CareCircle>()
                .HasOne(c => c.Owner).WithMany().HasForeignKey(c => c.OwnerUserId).OnDelete(DeleteBehavior.Restrict);

            b.Entity<CareCircleMember>()
                .HasOne(m => m.CareCircle).WithMany(c => c.Members).HasForeignKey(m => m.CareCircleId);
            b.Entity<CareCircleMember>()
                .HasOne(m => m.User).WithMany().HasForeignKey(m => m.UserId);

            b.Entity<Patient>()
                .HasOne(p => p.PrimaryCircle).WithMany().HasForeignKey(p => p.PrimaryCircleId).OnDelete(DeleteBehavior.SetNull);

            b.Entity<Conversation>()
                .HasOne(c => c.Patient).WithMany().HasForeignKey(c => c.PatientId).OnDelete(DeleteBehavior.Cascade);
            b.Entity<Conversation>()
                .HasOne(c => c.Owner).WithMany().HasForeignKey(c => c.OwnerUserId).OnDelete(DeleteBehavior.Cascade);
        }
    }
}
