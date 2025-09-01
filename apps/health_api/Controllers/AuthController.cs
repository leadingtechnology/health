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
        public AuthController(HealthDbContext db, JwtService jwt) { _db = db; _jwt = jwt; }

        [HttpPost("register")]
        public async Task<ActionResult<TokenResponse>> Register([FromBody] RegisterRequest req)
        {
            if (await _db.Users.AnyAsync(u => u.Email == req.Email))
                return Conflict("Email already registered");
            var user = new User {
                Email = req.Email.Trim().ToLowerInvariant(),
                Name = req.Name.Trim(),
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
                Role = "user",
                Plan = Plan.Free,
                ModelTier = ModelTier.Basic
            };
            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            var (token, exp) = _jwt.CreateToken(user);
            return new TokenResponse(token, exp, user.Plan.ToString(), user.ModelTier.ToString(), user.Name, user.Email);
        }

        [HttpPost("login")]
        public async Task<ActionResult<TokenResponse>> Login([FromBody] LoginRequest req)
        {
            var email = req.Email.Trim().ToLowerInvariant();
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
                return Unauthorized("Invalid credentials");

            var (token, exp) = _jwt.CreateToken(user);
            return new TokenResponse(token, exp, user.Plan.ToString(), user.ModelTier.ToString(), user.Name, user.Email);
        }
    }
}
