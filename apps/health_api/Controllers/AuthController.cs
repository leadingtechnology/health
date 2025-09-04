using System.Security.Claims;
using BCrypt.Net;
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
    public class AuthController : ControllerBase
    {
        private readonly HealthDbContext _db;
        private readonly JwtService _jwt;
        private readonly OtpService _otp;
        private readonly ILogger<AuthController> _logger;
        
        public AuthController(HealthDbContext db, JwtService jwt, OtpService otp, ILogger<AuthController> logger) 
        { 
            _db = db; 
            _jwt = jwt; 
            _otp = otp;
            _logger = logger;
        }

        [HttpPost("register")]
        public async Task<ActionResult<TokenResponse>> Register([FromBody] RegisterRequest req)
        {
            // Validate that at least email or phone is provided
            if (string.IsNullOrWhiteSpace(req.Email) && string.IsNullOrWhiteSpace(req.Phone))
                return BadRequest("Either email or phone number is required");

            // Normalize identifiers
            var email = !string.IsNullOrWhiteSpace(req.Email) ? _otp.NormalizeEmail(req.Email) : null;
            var phone = !string.IsNullOrWhiteSpace(req.Phone) ? _otp.NormalizePhone(req.Phone, "81") : null; // Default to Japan (+81)

            // Check if already registered
            if (!string.IsNullOrEmpty(email) && await _db.Users.AnyAsync(u => u.Email == email && u.DeletedAt == null))
                return Conflict("Email already registered");
            if (!string.IsNullOrEmpty(phone) && await _db.Users.AnyAsync(u => u.PhoneE164 == phone && u.DeletedAt == null))
                return Conflict("Phone number already registered");

            var user = new User 
            {
                Email = email,
                PhoneE164 = phone,
                Name = req.Name?.Trim() ?? string.Empty,
                PasswordHash = !string.IsNullOrWhiteSpace(req.Password) ? BCrypt.Net.BCrypt.HashPassword(req.Password) : null,
                Role = "user",
                Plan = Plan.Free,
                ModelTier = ModelTier.Basic,
                TimeZone = "Asia/Tokyo"
            };
            
            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            var (token, exp) = _jwt.CreateToken(user);
            return new TokenResponse(token, exp, user.Plan.ToString(), user.ModelTier.ToString(), user.Name, user.Email ?? user.PhoneE164 ?? "");
        }

        [HttpPost("login")]
        public async Task<ActionResult<TokenResponse>> Login([FromBody] LoginRequest req)
        {
            // Legacy password-based login (deprecated but still supported)
            if (!string.IsNullOrWhiteSpace(req.Password))
            {
                User? user = null;
                
                if (!string.IsNullOrWhiteSpace(req.Email))
                {
                    var email = _otp.NormalizeEmail(req.Email);
                    user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email && u.DeletedAt == null);
                }
                else if (!string.IsNullOrWhiteSpace(req.Phone))
                {
                    var phone = _otp.NormalizePhone(req.Phone, "81");
                    user = await _db.Users.FirstOrDefaultAsync(u => u.PhoneE164 == phone && u.DeletedAt == null);
                }

                if (user == null || user.PasswordHash == null || !BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
                    return Unauthorized("Invalid credentials");

                var (token, exp) = _jwt.CreateToken(user);
                return new TokenResponse(token, exp, user.Plan.ToString(), user.ModelTier.ToString(), user.Name, user.Email ?? user.PhoneE164 ?? "");
            }
            
            return BadRequest("Password is required for legacy login. Use /otp/send for OTP-based login.");
        }

        [HttpPost("otp/send")]
        public async Task<ActionResult<OtpResponse>> SendOtp([FromBody] OtpLoginRequest req)
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(req.Email))
                {
                    var (otpId, identifier, code, expiresAt) = await _otp.CreateEmailOtp(req.Email, req.Purpose ?? "login");
                    
                    // TODO: Send email with OTP code
                    _logger.LogInformation($"Email OTP {code} sent to {identifier}");
                    
                    // In development/test, return the code directly
                    var isDev = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") == "Development";
                    return new OtpResponse(otpId, identifier, expiresAt, isDev ? code : null);
                }
                else if (!string.IsNullOrWhiteSpace(req.Phone))
                {
                    var (otpId, identifier, code, expiresAt) = await _otp.CreatePhoneOtp(req.Phone, req.Purpose ?? "login", 300, "81");
                    
                    // TODO: Send SMS with OTP code
                    _logger.LogInformation($"Phone OTP {code} sent to {identifier}");
                    
                    // In development/test, return the code directly
                    var isDev = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") == "Development";
                    return new OtpResponse(otpId, identifier, expiresAt, isDev ? code : null);
                }
                else
                {
                    return BadRequest("Either email or phone is required");
                }
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("otp/verify")]
        public async Task<ActionResult<TokenResponse>> VerifyOtp([FromBody] OtpVerifyRequest req)
        {
            bool verified = false;
            User? user = null;
            
            if (!string.IsNullOrWhiteSpace(req.Email))
            {
                verified = await _otp.VerifyEmailOtp(req.Email, req.Code, req.Purpose ?? "login");
                if (verified)
                {
                    var email = _otp.NormalizeEmail(req.Email);
                    user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email && u.DeletedAt == null);
                    
                    // Auto-register if not found (for login purpose only)
                    if (user == null && req.Purpose == "login")
                    {
                        user = new User
                        {
                            Email = email,
                            Name = email.Split('@')[0], // Use email prefix as default name
                            Role = "user",
                            Plan = Plan.Free,
                            ModelTier = ModelTier.Basic,
                            TimeZone = "Asia/Tokyo"
                        };
                        _db.Users.Add(user);
                        await _db.SaveChangesAsync();
                    }
                }
            }
            else if (!string.IsNullOrWhiteSpace(req.Phone))
            {
                verified = await _otp.VerifyPhoneOtp(req.Phone, req.Code, req.Purpose ?? "login", "81");
                if (verified)
                {
                    var phone = _otp.NormalizePhone(req.Phone, "81");
                    user = await _db.Users.FirstOrDefaultAsync(u => u.PhoneE164 == phone && u.DeletedAt == null);
                    
                    // Auto-register if not found (for login purpose only)
                    if (user == null && req.Purpose == "login")
                    {
                        user = new User
                        {
                            PhoneE164 = phone,
                            Name = "User", // Default name for phone users
                            Role = "user",
                            Plan = Plan.Free,
                            ModelTier = ModelTier.Basic,
                            TimeZone = "Asia/Tokyo"
                        };
                        _db.Users.Add(user);
                        await _db.SaveChangesAsync();
                    }
                }
            }
            else
            {
                return BadRequest("Either email or phone is required");
            }

            if (!verified)
                return Unauthorized("Invalid or expired OTP");
                
            if (user == null)
                return NotFound("User not found");

            var (token, exp) = _jwt.CreateToken(user);
            return new TokenResponse(token, exp, user.Plan.ToString(), user.ModelTier.ToString(), user.Name, user.Email ?? user.PhoneE164 ?? "");
        }
    }
}
