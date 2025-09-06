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

        [HttpPut("me/plan")]
        public async Task<IActionResult> UpdatePlan([FromBody] UpdatePlanRequest request)
        {
            var user = await _db.Users.FindAsync(UserId);
            if (user == null) return NotFound();

            // Validate plan value
            if (!Enum.TryParse<Plan>(request.Plan, true, out var newPlan))
            {
                return BadRequest(new { message = "Invalid plan value" });
            }

            // Update user's plan
            user.Plan = newPlan;
            user.UpdatedAt = DateTime.UtcNow;

            try
            {
                await _db.SaveChangesAsync();
                return Ok(new { 
                    message = "Plan updated successfully",
                    plan = newPlan.ToString(),
                    updatedAt = user.UpdatedAt
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Failed to update plan", error = ex.Message });
            }
        }

        [HttpPut("me/model-tier")]
        public async Task<IActionResult> UpdateModelTier([FromBody] UpdateModelTierRequest request)
        {
            var user = await _db.Users.FindAsync(UserId);
            if (user == null) return NotFound();

            // Validate model tier value
            if (!Enum.TryParse<ModelTier>(request.ModelTier, true, out var newTier))
            {
                return BadRequest(new { message = "Invalid model tier value" });
            }

            // Update user's model tier
            user.ModelTier = newTier;
            user.UpdatedAt = DateTime.UtcNow;

            try
            {
                await _db.SaveChangesAsync();
                return Ok(new { 
                    message = "Model tier updated successfully",
                    modelTier = newTier.ToString(),
                    updatedAt = user.UpdatedAt
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Failed to update model tier", error = ex.Message });
            }
        }
    }
}
