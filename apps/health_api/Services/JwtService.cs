using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using health_api.Models;

namespace health_api.Services
{
    public class JwtService
    {
        private readonly IConfiguration _cfg;
        public JwtService(IConfiguration cfg) { _cfg = cfg; }

        public (string token, DateTime expires) CreateToken(User user, TimeSpan? lifetime = null)
        {
            var issuer = _cfg["Jwt:Issuer"];
            var audience = _cfg["Jwt:Audience"];
            var key = _cfg["Jwt:SigningKey"] ?? throw new Exception("Missing Jwt:SigningKey");
            var creds = new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)), SecurityAlgorithms.HmacSha256);

            var now = DateTime.UtcNow;
            var expires = now.Add(lifetime ?? TimeSpan.FromHours(12));

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim("name", user.Name),
                new Claim("role", user.Role),
                new Claim("plan", user.Plan.ToString()),
                new Claim("tier", user.ModelTier.ToString())
            };
            
            if (!string.IsNullOrEmpty(user.Email))
                claims.Add(new Claim(JwtRegisteredClaimNames.Email, user.Email));
            
            if (!string.IsNullOrEmpty(user.PhoneE164))
                claims.Add(new Claim("phone", user.PhoneE164));

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                notBefore: now,
                expires: expires,
                signingCredentials: creds
            );
            var jwt = new JwtSecurityTokenHandler().WriteToken(token);
            return (jwt, expires);
        }
    }
}
