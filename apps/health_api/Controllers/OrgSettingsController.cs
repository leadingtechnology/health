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
    [Route("api/orgsettings")]
    [Authorize]
    public class OrgSettingsController : ControllerBase
    {
        private readonly HealthDbContext _db;
        private readonly EncryptionService _enc;
        public OrgSettingsController(HealthDbContext db, EncryptionService enc) { _db = db; _enc = enc; }
        private Guid UserId => Guid.Parse(User.FindFirstValue("sub")!);

        private async Task<bool> IsAdminAsync()
        {
            var u = await _db.Users.FindAsync(UserId);
            return u?.Role == "admin";
        }

        [HttpGet("openai")]
        public async Task<IActionResult> GetOpenAIKeyMasked()
        {
            if (!await IsAdminAsync()) return Forbid();
            var ak = await _db.ApiKeys.Where(k => k.Provider == "openai").OrderByDescending(k => k.CreatedAt).FirstOrDefaultAsync();
            if (ak == null) return Ok(new { configured = false });
            var plain = _enc.Decrypt(ak.EncryptedValue);
            var masked = plain.Length <= 8 ? "****" : $"{plain[..4]}****{plain[^4..]}";
            return Ok(new { configured = true, name = ak.Name, masked });
        }

        [HttpPost("openai")]
        public async Task<IActionResult> SetOpenAIKey([FromBody] OpenAIKeyUpsertRequest req)
        {
            if (!await IsAdminAsync()) return Forbid();
            var enc = _enc.Encrypt(req.ApiKeyPlain);
            var k = new ApiKeySecret { Provider = "openai", Name = req.KeyName, EncryptedValue = enc, CreatedByUserId = UserId };
            _db.ApiKeys.Add(k);
            await _db.SaveChangesAsync();
            return Ok(new { ok = true });
        }
    }
}
