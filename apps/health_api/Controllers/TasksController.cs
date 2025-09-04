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
    public class TasksController : ControllerBase
    {
        private readonly HealthDbContext _db;
        private readonly ILogger<TasksController> _logger;

        public TasksController(HealthDbContext db, ILogger<TasksController> logger)
        {
            _db = db;
            _logger = logger;
        }

        private Guid GetUserId() => Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException());

        [HttpGet]
        public async Task<ActionResult<List<TaskResponse>>> GetMyTasks([FromQuery] bool? isDone = null, [FromQuery] Guid? patientId = null)
        {
            var userId = GetUserId();
            var query = _db.Tasks.Where(t => t.OwnerUserId == userId);
            
            if (isDone.HasValue)
                query = query.Where(t => t.IsDone == isDone.Value);
            
            if (patientId.HasValue)
                query = query.Where(t => t.PatientId == patientId.Value);
            
            var tasks = await query
                .OrderBy(t => t.DueAt)
                .Select(t => new TaskResponse(
                    t.Id,
                    t.Title,
                    t.DueAt,
                    t.PatientId,
                    t.Notes,
                    t.Category,
                    t.IsDone,
                    t.CreatedAt
                ))
                .ToListAsync();
            
            return Ok(tasks);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<TaskResponse>> GetTask(Guid id)
        {
            var userId = GetUserId();
            var task = await _db.Tasks
                .Where(t => t.Id == id && t.OwnerUserId == userId)
                .Select(t => new TaskResponse(
                    t.Id,
                    t.Title,
                    t.DueAt,
                    t.PatientId,
                    t.Notes,
                    t.Category,
                    t.IsDone,
                    t.CreatedAt
                ))
                .FirstOrDefaultAsync();
            
            if (task == null)
                return NotFound();
            
            return Ok(task);
        }

        [HttpPost]
        public async Task<ActionResult<TaskResponse>> CreateTask([FromBody] TaskUpsertRequest req)
        {
            var userId = GetUserId();
            
            // Validate patient if provided
            if (req.PatientId.HasValue)
            {
                var patientExists = await _db.Patients.AnyAsync(p => p.Id == req.PatientId.Value);
                if (!patientExists)
                    return BadRequest("Invalid patient ID");
            }
            
            // Validate category if provided
            if (!string.IsNullOrEmpty(req.Category))
            {
                var validCategories = new[] { "medication", "exercise", "appointment", "safety", "other" };
                if (!validCategories.Contains(req.Category.ToLower()))
                    return BadRequest($"Invalid category. Must be one of: {string.Join(", ", validCategories)}");
            }
            
            var task = new Models.Task
            {
                OwnerUserId = userId,
                Title = req.Title,
                DueAt = req.DueAt,
                PatientId = req.PatientId,
                Notes = req.Notes,
                Category = req.Category?.ToLower(),
                IsDone = false
            };
            
            _db.Tasks.Add(task);
            await _db.SaveChangesAsync();
            
            return CreatedAtAction(
                nameof(GetTask),
                new { id = task.Id },
                new TaskResponse(
                    task.Id,
                    task.Title,
                    task.DueAt,
                    task.PatientId,
                    task.Notes,
                    task.Category,
                    task.IsDone,
                    task.CreatedAt
                )
            );
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<TaskResponse>> UpdateTask(Guid id, [FromBody] TaskUpsertRequest req)
        {
            var userId = GetUserId();
            var task = await _db.Tasks.FirstOrDefaultAsync(t => t.Id == id && t.OwnerUserId == userId);
            
            if (task == null)
                return NotFound();
            
            // Validate patient if provided
            if (req.PatientId.HasValue)
            {
                var patientExists = await _db.Patients.AnyAsync(p => p.Id == req.PatientId.Value);
                if (!patientExists)
                    return BadRequest("Invalid patient ID");
            }
            
            // Validate category if provided
            if (!string.IsNullOrEmpty(req.Category))
            {
                var validCategories = new[] { "medication", "exercise", "appointment", "safety", "other" };
                if (!validCategories.Contains(req.Category.ToLower()))
                    return BadRequest($"Invalid category. Must be one of: {string.Join(", ", validCategories)}");
            }
            
            task.Title = req.Title;
            task.DueAt = req.DueAt;
            task.PatientId = req.PatientId;
            task.Notes = req.Notes;
            task.Category = req.Category?.ToLower();
            task.UpdatedAt = DateTime.UtcNow;
            
            await _db.SaveChangesAsync();
            
            return Ok(new TaskResponse(
                task.Id,
                task.Title,
                task.DueAt,
                task.PatientId,
                task.Notes,
                task.Category,
                task.IsDone,
                task.CreatedAt
            ));
        }

        [HttpPost("{id}/toggle")]
        public async Task<ActionResult<TaskResponse>> ToggleTask(Guid id)
        {
            var userId = GetUserId();
            var task = await _db.Tasks.FirstOrDefaultAsync(t => t.Id == id && t.OwnerUserId == userId);
            
            if (task == null)
                return NotFound();
            
            task.IsDone = !task.IsDone;
            task.UpdatedAt = DateTime.UtcNow;
            
            await _db.SaveChangesAsync();
            
            return Ok(new TaskResponse(
                task.Id,
                task.Title,
                task.DueAt,
                task.PatientId,
                task.Notes,
                task.Category,
                task.IsDone,
                task.CreatedAt
            ));
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTask(Guid id)
        {
            var userId = GetUserId();
            var task = await _db.Tasks.FirstOrDefaultAsync(t => t.Id == id && t.OwnerUserId == userId);
            
            if (task == null)
                return NotFound();
            
            _db.Tasks.Remove(task);
            await _db.SaveChangesAsync();
            
            return NoContent();
        }
    }
}