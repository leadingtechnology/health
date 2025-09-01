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
            // For simplicity we use the most recent org-level (Name='default') key. In multi-tenant, scope by org.
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

            var baseUrl = _cfg["OpenAI:BaseUrl"] ?? "https://api.openai.com/v1";
            var m = model ?? _cfg["OpenAI:DefaultModel"] ?? "gpt-4o-mini";

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
