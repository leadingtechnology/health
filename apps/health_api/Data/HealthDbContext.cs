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

        protected override void OnModelCreating(ModelBuilder b)
        {
            b.Entity<User>().HasIndex(u => u.Email).IsUnique();
            b.Entity<CareCircleMember>().HasIndex(m => new { m.CareCircleId, m.UserId }).IsUnique();
            b.Entity<QuotaUsage>().HasIndex(q => new { q.UserId, q.Date }).IsUnique();

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
