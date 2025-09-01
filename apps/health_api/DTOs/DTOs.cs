using System.ComponentModel.DataAnnotations;
using health_api.Models;

namespace health_api.DTOs
{
    public record RegisterRequest([Required, EmailAddress] string Email, [Required, MinLength(6)] string Password, [Required] string Name);
    public record LoginRequest([Required, EmailAddress] string Email, [Required] string Password);

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
}
