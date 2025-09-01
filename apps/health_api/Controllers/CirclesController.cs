using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using health_api.Data;
using health_api.DTOs;
using health_api.Models;

namespace health_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CirclesController : ControllerBase
    {
        private readonly HealthDbContext _db;
        public CirclesController(HealthDbContext db) { _db = db; }
        private Guid UserId => Guid.Parse(User.FindFirstValue("sub")!);

        [HttpGet]
        public async Task<IActionResult> List()
        {
            var circles = await _db.CareCircleMembers
                .Where(m => m.UserId == UserId)
                .Select(m => m.CareCircle!)
                .Include(c => c.Members)
                .ToListAsync();
            return Ok(circles.Select(c => new {
                c.Id, c.Name, c.OwnerUserId, members = c.Members.Select(m => new { m.UserId, m.Role })
            }));
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateCircleRequest req)
        {
            var c = new CareCircle { Name = req.Name, OwnerUserId = UserId };
            _db.CareCircles.Add(c);
            _db.CareCircleMembers.Add(new CareCircleMember { CareCircle = c, UserId = UserId, Role = "admin" });
            await _db.SaveChangesAsync();
            return Ok(new { c.Id, c.Name });
        }

        [HttpPost("{id:guid}/members")]
        public async Task<IActionResult> AddMember(Guid id, [FromBody] AddMemberRequest req)
        {
            var circle = await _db.CareCircles.FindAsync(id);
            if (circle == null) return NotFound();
            var me = await _db.CareCircleMembers.FirstOrDefaultAsync(m => m.CareCircleId == id && m.UserId == UserId);
            if (me == null || me.Role != "admin") return Forbid();

            if (!await _db.Users.AnyAsync(u => u.Id == req.UserId)) return BadRequest("User not found");
            _db.CareCircleMembers.Add(new CareCircleMember { CareCircleId = id, UserId = req.UserId, Role = req.Role });
            await _db.SaveChangesAsync();
            return Ok();
        }

        [HttpDelete("{id:guid}/members/{userId:guid}")]
        public async Task<IActionResult> RemoveMember(Guid id, Guid userId)
        {
            var me = await _db.CareCircleMembers.FirstOrDefaultAsync(m => m.CareCircleId == id && m.UserId == UserId);
            if (me == null || me.Role != "admin") return Forbid();

            var mbr = await _db.CareCircleMembers.FirstOrDefaultAsync(m => m.CareCircleId == id && m.UserId == userId);
            if (mbr == null) return NotFound();
            _db.CareCircleMembers.Remove(mbr);
            await _db.SaveChangesAsync();
            return Ok();
        }
    }
}
