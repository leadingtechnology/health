using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using health_api.Data;
using health_api.Models;

namespace health_api.Services
{
    public class OtpService
    {
        private readonly HealthDbContext _db;
        private readonly ILogger<OtpService> _logger;
        private readonly IConfiguration _config;

        public OtpService(HealthDbContext db, ILogger<OtpService> logger, IConfiguration config)
        {
            _db = db;
            _logger = logger;
            _config = config;
        }

        public string NormalizePhone(string? phone, string? defaultCountryCode = null)
        {
            if (string.IsNullOrWhiteSpace(phone)) return string.Empty;
            
            // Remove spaces, hyphens, parentheses
            var s = Regex.Replace(phone, @"[\s\-\(\)]", "", RegexOptions.Compiled);
            
            // Add country code if missing
            if (!s.StartsWith("+"))
            {
                if (!string.IsNullOrEmpty(defaultCountryCode) && Regex.IsMatch(defaultCountryCode, @"^[1-9][0-9]{1,3}$"))
                {
                    s = "+" + defaultCountryCode + Regex.Replace(s, @"[^0-9]", "");
                }
                else
                {
                    s = "+" + Regex.Replace(s, @"[^0-9]", "");
                }
            }
            else
            {
                s = "+" + Regex.Replace(s.Substring(1), @"[^0-9]", "");
            }
            
            // Validate E.164 format
            return Regex.IsMatch(s, @"^\+[1-9][0-9]{6,14}$") ? s : string.Empty;
        }

        public string NormalizeEmail(string? email)
        {
            if (string.IsNullOrWhiteSpace(email)) return string.Empty;
            
            var e = email.Trim().ToLowerInvariant();
            return Regex.IsMatch(e, @"^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$") ? e : string.Empty;
        }

        public string GenerateOtpCode(int digits = 6)
        {
            // Generate a numeric OTP with cryptographically secure randomness
            if (digits < 4 || digits > 10) digits = 6;
            var sb = new StringBuilder(digits);
            for (int i = 0; i < digits; i++)
            {
                // Uniform digit 0-9 without modulo bias
                var d = RandomNumberGenerator.GetInt32(0, 10);
                sb.Append((char)('0' + d));
            }
            return sb.ToString();
        }

        public async Task<(Guid otpId, string identifier, string code, DateTime expiresAt)> CreatePhoneOtp(
            string phone, string purpose = "login", int ttlSeconds = 300, string? defaultCountryCode = null)
        {
            var phoneE164 = NormalizePhone(phone, defaultCountryCode);
            if (string.IsNullOrEmpty(phoneE164))
                throw new ArgumentException("Invalid phone number");

            var code = GenerateOtpCode(6);
            var salt = RandomNumberGenerator.GetBytes(16);
            var hash = SHA256.HashData(Encoding.UTF8.GetBytes(code + Convert.ToBase64String(salt)));
            var expiresAt = DateTime.UtcNow.AddSeconds(ttlSeconds);

            var otp = new PhoneOtp
            {
                PhoneE164 = phoneE164,
                Purpose = purpose,
                CodeHash = hash,
                CodeSalt = salt,
                ExpiresAt = expiresAt,
                CreatedIp = null, // Can be set from HttpContext if needed
                UserAgent = null  // Can be set from HttpContext if needed
            };

            _db.Set<PhoneOtp>().Add(otp);
            await _db.SaveChangesAsync();

            return (otp.Id, phoneE164, code, expiresAt);
        }

        public async Task<(Guid otpId, string identifier, string code, DateTime expiresAt)> CreateEmailOtp(
            string email, string purpose = "login", int ttlSeconds = 600)
        {
            var normalizedEmail = NormalizeEmail(email);
            if (string.IsNullOrEmpty(normalizedEmail))
                throw new ArgumentException("Invalid email address");

            var code = GenerateOtpCode(6);
            var salt = RandomNumberGenerator.GetBytes(16);
            var hash = SHA256.HashData(Encoding.UTF8.GetBytes(code + Convert.ToBase64String(salt)));
            var expiresAt = DateTime.UtcNow.AddSeconds(ttlSeconds);

            var otp = new EmailOtp
            {
                Email = normalizedEmail,
                Purpose = purpose,
                CodeHash = hash,
                CodeSalt = salt,
                ExpiresAt = expiresAt,
                CreatedIp = null, // Can be set from HttpContext if needed
                UserAgent = null  // Can be set from HttpContext if needed
            };

            _db.Set<EmailOtp>().Add(otp);
            await _db.SaveChangesAsync();

            return (otp.Id, normalizedEmail, code, expiresAt);
        }

        public async Task<bool> VerifyPhoneOtp(string phone, string code, string purpose = "login", 
            string? defaultCountryCode = null, int maxAttempts = 5)
        {
            var phoneE164 = NormalizePhone(phone, defaultCountryCode);
            if (string.IsNullOrEmpty(phoneE164)) return false;

            var otp = await _db.Set<PhoneOtp>()
                .Where(o => o.PhoneE164 == phoneE164 && 
                           o.Purpose == purpose && 
                           o.ConsumedAt == null && 
                           o.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(o => o.CreatedAt)
                .FirstOrDefaultAsync();

            if (otp == null) return false;
            if (otp.Attempts >= maxAttempts) return false;

            var hash = SHA256.HashData(Encoding.UTF8.GetBytes(code + Convert.ToBase64String(otp.CodeSalt)));
            
            if (hash.SequenceEqual(otp.CodeHash))
            {
                otp.ConsumedAt = DateTime.UtcNow;
                await _db.SaveChangesAsync();
                return true;
            }
            else
            {
                otp.Attempts++;
                await _db.SaveChangesAsync();
                return false;
            }
        }

        public async Task<bool> VerifyEmailOtp(string email, string code, string purpose = "login", int maxAttempts = 5)
        {
            var normalizedEmail = NormalizeEmail(email);
            if (string.IsNullOrEmpty(normalizedEmail)) return false;

            var otp = await _db.Set<EmailOtp>()
                .Where(o => o.Email == normalizedEmail && 
                           o.Purpose == purpose && 
                           o.ConsumedAt == null && 
                           o.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(o => o.CreatedAt)
                .FirstOrDefaultAsync();

            if (otp == null) return false;
            if (otp.Attempts >= maxAttempts) return false;

            var hash = SHA256.HashData(Encoding.UTF8.GetBytes(code + Convert.ToBase64String(otp.CodeSalt)));
            
            if (hash.SequenceEqual(otp.CodeHash))
            {
                otp.ConsumedAt = DateTime.UtcNow;
                await _db.SaveChangesAsync();
                return true;
            }
            else
            {
                otp.Attempts++;
                await _db.SaveChangesAsync();
                return false;
            }
        }
    }
}
