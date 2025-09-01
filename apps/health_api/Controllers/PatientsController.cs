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
    public class PatientsController : ControllerBase
    {
        private readonly HealthDbContext _db;
        public PatientsController(HealthDbContext db) { _db = db; }
        private Guid UserId => Guid.Parse(User.FindFirstValue("sub")!);

        [HttpGet]
        public async Task<IActionResult> List()
        {
            var q = _db.Patients.AsQueryable();
            var list = await q.OrderByDescending(p => p.Id).Take(100).ToListAsync();
            return Ok(list);
        }

        [HttpPost]
        public async Task<IActionResult> Upsert([FromBody] PatientUpsertRequest req)
        {
            var p = new Patient {
                Name = req.Name,
                BirthDate = req.BirthDate,
                Gender = req.Gender,
                Conditions = req.Conditions,
                Allergies = req.Allergies,
                EmergencyContact = req.EmergencyContact,
                PrimaryCircleId = req.PrimaryCircleId
            };
            _db.Patients.Add(p);
            await _db.SaveChangesAsync();
            return Ok(p);
        }
    }
}
