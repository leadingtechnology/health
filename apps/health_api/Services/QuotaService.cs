using health_api.Data;
using health_api.Models;
using Microsoft.EntityFrameworkCore;

namespace health_api.Services
{
    public class QuotaService
    {
        private readonly HealthDbContext _db;
        public QuotaService(HealthDbContext db) { _db = db; }

        public (int dailyLimit, DateTime resetAt) GetPolicy(Plan plan)
        {
            // Free: 3/day, others: unlimited text questions (but have other quotas)
            return plan == Plan.Free ? (3, GetResetAtLocalMidnight()) : (int.MaxValue, GetResetAtLocalMidnight());
        }

        private DateTime GetResetAtLocalMidnight()
        {
            var now = DateTime.Now;
            var next = new DateTime(now.Year, now.Month, now.Day).AddDays(1);
            return next;
        }

        public async Task<(int used, int limit)> GetUsageAsync(Guid userId, Plan plan)
        {
            var (limit, _) = GetPolicy(plan);
            var today = DateOnly.FromDateTime(DateTime.Now);
            var u = await _db.QuotaUsages.FirstOrDefaultAsync(q => q.UserId == userId && q.Date == today);
            return (u?.UsedCount ?? 0, limit);
        }

        /// <summary>
        /// Consume 1 unit if under limit. Returns true if success.
        /// </summary>
        public async Task<bool> TryConsumeAsync(Guid userId, Plan plan, string reason = "ask")
        {
            var (limit, _) = GetPolicy(plan);
            if (limit == int.MaxValue) return true;
            var today = DateOnly.FromDateTime(DateTime.Now);
            var u = await _db.QuotaUsages.SingleOrDefaultAsync(q => q.UserId == userId && q.Date == today);
            if (u == null)
            {
                u = new QuotaUsage { UserId = userId, Date = today, UsedCount = 0 };
                _db.QuotaUsages.Add(u);
            }
            if (u.UsedCount >= limit) return false;
            u.UsedCount += 1;
            await _db.SaveChangesAsync();
            return true;
        }
    }
}
