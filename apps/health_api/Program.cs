using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Reflection;
using health_api.Data;
using health_api.Services;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// Configuration
var config = builder.Configuration;

// Configure Npgsql global type mappings for PostgreSQL enums
var dataSourceBuilder = new NpgsqlDataSourceBuilder(config.GetConnectionString("DefaultConnection"));
dataSourceBuilder.MapEnum<health_api.Models.Plan>("public.plan_type");
dataSourceBuilder.MapEnum<health_api.Models.ModelTier>("public.model_tier");
var dataSource = dataSourceBuilder.Build();

// DbContext (PostgreSQL only via ConnectionStrings:DefaultConnection)
builder.Services.AddDbContext<HealthDbContext>(opt =>
{
    opt.UseNpgsql(dataSource);
    opt.EnableDetailedErrors();
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
builder.Services.AddScoped<OtpService>();

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

    // Include XML comments for Swagger (controller + action summaries)
    try
    {
        var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
        var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
        if (File.Exists(xmlPath))
        {
            c.IncludeXmlComments(xmlPath, includeControllerXmlComments: true);
        }
    }
    catch { /* best-effort */ }
});

var app = builder.Build();

app.UseCors("AppCors");

// Serve static files for uploads
app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Swagger in all envs (protect if needed)
app.UseSwagger();
app.UseSwaggerUI();

// Startup info and DB connectivity check
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<HealthDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    // Display startup information in development
    if (app.Environment.IsDevelopment())
    {
        Console.WriteLine("\n========================================");
        Console.WriteLine("  Health API - Development Environment");
        Console.WriteLine("========================================\n");

        // Database connection info
        try
        {
            var connectionString = config.GetConnectionString("DefaultConnection") ?? "(not set)";
            Console.WriteLine("?? Database Information:");
            Console.WriteLine($"   Provider: PostgreSQL");

            // Extract details from PostgreSQL connection string (avoid printing password)
            var hostMatch = System.Text.RegularExpressions.Regex.Match(connectionString, @"Host=([^;]+)", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            var portMatch = System.Text.RegularExpressions.Regex.Match(connectionString, @"Port=([^;]+)", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            var dbMatch   = System.Text.RegularExpressions.Regex.Match(connectionString, @"Database=([^;]+)", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            var userMatch = System.Text.RegularExpressions.Regex.Match(connectionString, @"(?:Username|User Id|UserID)=([^;]+)", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            var schemaMatch = System.Text.RegularExpressions.Regex.Match(connectionString, @"(?:Search Path|SearchPath|Schema)=([^;]+)", System.Text.RegularExpressions.RegexOptions.IgnoreCase);

            if (hostMatch.Success)   Console.WriteLine($"   Host: {hostMatch.Groups[1].Value}");
            if (portMatch.Success)   Console.WriteLine($"   Port: {portMatch.Groups[1].Value}");
            if (dbMatch.Success)     Console.WriteLine($"   Database: {dbMatch.Groups[1].Value}");
            if (userMatch.Success)   Console.WriteLine($"   User: {userMatch.Groups[1].Value}");
            if (schemaMatch.Success) Console.WriteLine($"   Schema: {schemaMatch.Groups[1].Value}");

            // Test database connection and report detailed errors
            try
            {
                var providerName = db.Database.ProviderName;
                using var conn = db.Database.GetDbConnection();
                conn.Open();
                Console.WriteLine("   Status: ✅ Connected successfully");
                Console.WriteLine($"   Provider Name: {providerName}");
                Console.WriteLine($"   Server Version: {conn.ServerVersion}");
                conn.Close();
            }
            catch (Exception openEx)
            {
                Console.WriteLine("   Status: ❌ Connection failed");
                Console.WriteLine($"   Error: {openEx.GetType().Name}: {openEx.Message}");
                if (openEx.InnerException != null)
                    Console.WriteLine($"   Inner: {openEx.InnerException.GetType().Name}: {openEx.InnerException.Message}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"   Status: ❌ Error: {ex.Message}");
        }

        Console.WriteLine();

        // API Endpoints information
        var urls = app.Urls.Any() ? string.Join(", ", app.Urls) : $"http://localhost:{config["Urls"]?.Split(':').Last() ?? "5000"}";
        Console.WriteLine("?? API Endpoints:");
        Console.WriteLine($"   Base URL: {urls}");
        Console.WriteLine($"   Swagger UI: {urls}/swagger");
        Console.WriteLine($"   Swagger JSON: {urls}/swagger/v1/swagger.json");

        Console.WriteLine();
        Console.WriteLine("?? Authentication:");
        Console.WriteLine($"   Type: JWT Bearer");
        Console.WriteLine($"   Issuer: {jwtIssuer ?? "Not configured"}");
        Console.WriteLine($"   Audience: {jwtAudience ?? "Not configured"}");

        Console.WriteLine();
        Console.WriteLine("?? CORS Configuration:");
        var corsOrigins = config.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? new[] { "http://localhost:5173" };
        foreach (var origin in corsOrigins)
        {
            Console.WriteLine($"   Allowed: {origin}");
        }

        Console.WriteLine();
        Console.WriteLine("? Key Features:");
        Console.WriteLine("   ? User registration & JWT authentication");
        Console.WriteLine("   ? Daily quota management (3 free questions/day)");
        Console.WriteLine("   ? Care circles & patient management");
        Console.WriteLine("   ? OpenAI API proxy with encrypted key storage");
        Console.WriteLine("   ? Conversation sharing & permissions");

        Console.WriteLine();
        Console.WriteLine("========================================");
        Console.WriteLine($"?? Server is running at {urls}");
        Console.WriteLine("   Press Ctrl+C to stop");
        Console.WriteLine("========================================\n");
    }
}

app.Run();
