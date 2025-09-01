using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using health_api.Data;
using health_api.DTOs;
using health_api.Models;
using health_api.Services;

namespace health_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly HealthDbContext _db;
        private readonly QuotaService _quota;
        public UsersController(HealthDbContext db, QuotaService quota) { _db = db; _quota = quota; }

        private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!);

        [HttpGet("me")]
        public async Task<IActionResult> Me()
        {
            var u = await _db.Users.FindAsync(UserId);
            if (u == null) return NotFound();
            return Ok(new {
                u.Id, u.Email, u.Name, u.Role, Plan = u.Plan.ToString(), ModelTier = u.ModelTier.ToString(), u.CreatedAt
            });
        }

        [HttpGet("me/quota")]
        public async Task<ActionResult<QuotaInfo>> Quota()
        {
            var u = await _db.Users.FindAsync(UserId);
            if (u == null) return NotFound();
            var (used, limit) = await _quota.GetUsageAsync(u.Id, u.Plan);
            var (_, resetAt) = _quota.GetPolicy(u.Plan);
            return new QuotaInfo(limit == int.MaxValue ? int.MaxValue : limit, used, resetAt);
        }
    }
}
