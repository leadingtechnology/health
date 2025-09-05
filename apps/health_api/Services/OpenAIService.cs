using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using health_api.Data;
using health_api.Models;
using Microsoft.EntityFrameworkCore;

namespace health_api.Services
{
    public class OpenAIService
    {
        private readonly IConfiguration _cfg;
        private readonly HealthDbContext _db;
        private readonly EncryptionService _enc;
        private readonly HttpClient _http = new HttpClient();

        public OpenAIService(IConfiguration cfg, HealthDbContext db, EncryptionService enc)
        {
            _cfg = cfg; _db = db; _enc = enc;
        }

        private async Task<string?> GetOpenAIKeyAsync(Guid userId)
        {
            // First try to get from configuration (simple development setup)
            var configKey = _cfg["OpenAI:ApiKey"];
            if (!string.IsNullOrWhiteSpace(configKey) && configKey != "YOUR_OPENAI_API_KEY_HERE")
            {
                return configKey;
            }

            // Otherwise use the encrypted key from database (production setup)
            var ak = await _db.ApiKeys
                .Where(k => k.Provider == "openai")
                .OrderByDescending(k => k.CreatedAt)
                .FirstOrDefaultAsync();
            if (ak == null) return null;
            return _enc.Decrypt(ak.EncryptedValue);
        }

        public async Task<(string reply, string model, int inTok, int outTok)> AskAsync(Guid userId, string prompt, string? model = null)
        {
            var apiKey = await GetOpenAIKeyAsync(userId);
            if (string.IsNullOrWhiteSpace(apiKey))
                throw new InvalidOperationException("OpenAI API key is not configured.");

            // Get user's plan to determine model selection
            var user = await _db.Users.FindAsync(userId);
            if (user == null) throw new InvalidOperationException("User not found.");
            
            var baseUrl = _cfg["OpenAI:BaseUrl"] ?? "https://api.openai.com/v1";
            
            // Determine model based on plan and override
            string m;
            if (!string.IsNullOrEmpty(model))
            {
                m = model;
            }
            else
            {
                // Select model based on plan
                m = user.Plan switch
                {
                    Plan.Platinum => "gpt-4o",      // Best model for Platinum
                    Plan.Pro => "gpt-4o",           // Advanced model for Pro
                    Plan.Standard => "gpt-4o-mini", // Standard model 
                    Plan.Free => "gpt-4o-mini",     // Basic model for Free
                    _ => "gpt-4o-mini"
                };
            }
            
            // Check token usage for the month (for Platinum auto-fallback)
            if (user.Plan == Plan.Platinum)
            {
                var monthStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
                var tokenUsage = await _db.QuotaUsages
                    .Where(q => q.UserId == userId && q.Date >= DateOnly.FromDateTime(monthStart))
                    .SumAsync(q => q.UsedCount);
                
                // If over 12M input tokens equivalent, fallback to mini model
                if (tokenUsage > 12000000 && m == "gpt-4o")
                {
                    m = "gpt-4o-mini"; // Auto-downgrade to mini when quota exceeded
                }
            }

            var url = $"{baseUrl.TrimEnd('/')}/chat/completions";
            using var req = new HttpRequestMessage(HttpMethod.Post, url);
            req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
            req.Content = new StringContent(JsonSerializer.Serialize(new
            {
                model = m,
                messages = new[] { new { role = "user", content = prompt } }
            }), Encoding.UTF8, "application/json");

            using var res = await _http.SendAsync(req);
            var json = await res.Content.ReadAsStringAsync();
            if (!res.IsSuccessStatusCode) throw new Exception($"OpenAI error: {res.StatusCode}: {json}");

            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;
            var text = root.GetProperty("choices")[0].GetProperty("message").GetProperty("content").GetString() ?? "";
            int inTok = root.TryGetProperty("usage", out var usage) ? usage.GetProperty("prompt_tokens").GetInt32() : 0;
            int outTok = root.TryGetProperty("usage", out usage) ? usage.GetProperty("completion_tokens").GetInt32() : 0;
            return (text, m, inTok, outTok);
        }
    }
}
