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
    public class OpenAIController : ControllerBase
    {
        private readonly HealthDbContext _db;
        private readonly OpenAIService _svc;
        private readonly QuotaService _quota;
        public OpenAIController(HealthDbContext db, OpenAIService svc, QuotaService quota) { _db = db; _svc = svc; _quota = quota; }

        private Guid UserId => Guid.Parse(User.FindFirstValue("sub")!);

        [HttpPost("ask")]
        public async Task<ActionResult<OpenAIAskResponse>> Ask([FromBody] OpenAIAskRequest req)
        {
            var user = await _db.Users.FindAsync(UserId);
            if (user == null) return Unauthorized();
            // Enforce quota for Free plan BEFORE calling model (or do "after first token" on streaming)
            var ok = await _quota.TryConsumeAsync(user.Id, user.Plan, "ask");
            if (!ok) return StatusCode(429, "Daily free quota reached");

            var (reply, model, inTok, outTok) = await _svc.AskAsync(user.Id, req.Prompt, req.Model);
            return new OpenAIAskResponse(reply, model, inTok, outTok);
        }
    }
}
