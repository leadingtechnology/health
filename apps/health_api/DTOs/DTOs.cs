using System.ComponentModel.DataAnnotations;
using health_api.Models;

namespace health_api.DTOs
{
    // Legacy password-based auth (deprecated)
    public record RegisterRequest([EmailAddress] string? Email, [Phone] string? Phone, [MinLength(6)] string? Password, string Name = "");
    public record LoginRequest([EmailAddress] string? Email, [Phone] string? Phone, string? Password);

    // OTP-based auth
    public record OtpLoginRequest(string? Email, string? Phone, string? Purpose = "login");
    public record OtpVerifyRequest(string? Email, string? Phone, [Required] string Code, string? Purpose = "login");
    public record OtpResponse(Guid OtpId, string Identifier, DateTime ExpiresAt, string? Code = null); // Code only returned in dev/test

    public record TokenResponse(string AccessToken, DateTime ExpiresAt, string Plan, string ModelTier, string Name, string Email);

    public record CreateCircleRequest([Required] string Name);
    public record AddMemberRequest([Required] Guid UserId, string Role);
    public record InviteMemberRequest([Required, EmailAddress] string Email, string Role);

    public record PatientUpsertRequest([Required] string Name, DateOnly? BirthDate, string? Gender, string? Conditions, string? Allergies, string? EmergencyContact, Guid? PrimaryCircleId);

    public record ConversationUpsertRequest([Required] string Title, [Required] Guid PatientId, string SummaryText, bool IsShared);
    public record ShareRequest([Required] Guid ConversationId, Guid? ToUserId, string? ToEmail, bool RedactPII, DateTime? ExpiresAt);

    public record QuotaInfo(int DailyLimit, int UsedToday, DateTime ResetAt);
    public record ConsumeQuotaRequest(string Reason);

    public record OpenAIKeyUpsertRequest([Required] string KeyName, [Required] string ApiKeyPlain);
    public record OpenAIAskRequest([Required] string Prompt, string? Model);
    public record OpenAIAskResponse(string ReplyText, string ModelUsed, int TokensInput, int TokensOutput);

    public record TaskUpsertRequest([Required] string Title, [Required] DateTime DueAt, Guid? PatientId, string? Notes, string? Category);
    public record TaskResponse(Guid Id, string Title, DateTime DueAt, Guid? PatientId, string? Notes, string? Category, bool IsDone, DateTime CreatedAt);
}
