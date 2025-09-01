using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using health_api.Data;
using health_api.Services;

var builder = WebApplication.CreateBuilder(args);

// Configuration
var config = builder.Configuration;

// DbContext (auto-detect provider by connection string)
builder.Services.AddDbContext<HealthDbContext>(opt =>
{
    var cs = config.GetConnectionString("Default");
    if (!string.IsNullOrWhiteSpace(cs) && cs.Contains("Host=", StringComparison.OrdinalIgnoreCase))
    {
        // PostgreSQL connection string provided
        opt.UseNpgsql(cs);
    }
    else
    {
        // Fallback to local SQLite for development
        cs ??= "Data Source=./data/health.db";
        Directory.CreateDirectory("./data");
        opt.UseSqlite(cs);
    }
});

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AppCors", policy =>
    {
        var allowed = config.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? new[] { "http://localhost:5173" };
        policy.WithOrigins(allowed)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Auth (JWT)
var jwtIssuer = config["Jwt:Issuer"];
var jwtAudience = config["Jwt:Audience"];
var jwtKey = config["Jwt:SigningKey"] ?? throw new Exception("Missing Jwt:SigningKey");
var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateIssuerSigningKey = true,
            ValidateLifetime = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = signingKey,
            ClockSkew = TimeSpan.FromMinutes(2)
        };
    });
builder.Services.AddAuthorization();

// Services
builder.Services.AddScoped<JwtService>();
builder.Services.AddSingleton<EncryptionService>();
builder.Services.AddScoped<OpenAIService>();
builder.Services.AddScoped<QuotaService>();

builder.Services.AddControllers().AddJsonOptions(o =>
{
    o.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
});

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "health_api", Version = "v1" });
    var securityScheme = new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "JWT Authorization header using the Bearer scheme."
    };
    c.AddSecurityDefinition("Bearer", securityScheme);
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        { securityScheme, new List<string>() }
    });
});

var app = builder.Build();

app.UseCors("AppCors");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Swagger in all envs (protect if needed)
app.UseSwagger();
app.UseSwaggerUI();

// Auto-create DB for dev (SQLite only). Skip for Postgres to avoid schema conflicts
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<HealthDbContext>();
    if (db.Database.IsSqlite())
    {
        db.Database.EnsureCreated();
    }
}

app.Run();
