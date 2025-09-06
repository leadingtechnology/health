using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using HealthApi.Services;

namespace HealthApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LegalController : ControllerBase
{
    private readonly ILegalDocumentService _legalDocumentService;
    private readonly ILogger<LegalController> _logger;

    public LegalController(ILegalDocumentService legalDocumentService, ILogger<LegalController> logger)
    {
        _legalDocumentService = legalDocumentService;
        _logger = logger;
    }

    [HttpGet("privacy_policy")]
    [AllowAnonymous]
    public async Task<IActionResult> GetPrivacyPolicy([FromQuery] string language = "en")
    {
        try
        {
            var content = await _legalDocumentService.GetPrivacyPolicyAsync(language);
            return Ok(content);
        }
        catch (FileNotFoundException)
        {
            _logger.LogWarning("Privacy policy not found for language: {Language}", language);
            // Fallback to English if the requested language is not available
            if (language != "en")
            {
                var fallbackContent = await _legalDocumentService.GetPrivacyPolicyAsync("en");
                return Ok(fallbackContent);
            }
            return NotFound($"Privacy policy not found for language: {language}");
        }
    }

    [HttpGet("terms_of_service")]
    [AllowAnonymous]
    public async Task<IActionResult> GetTermsOfService([FromQuery] string language = "en")
    {
        try
        {
            var content = await _legalDocumentService.GetTermsOfServiceAsync(language);
            return Ok(content);
        }
        catch (FileNotFoundException)
        {
            _logger.LogWarning("Terms of service not found for language: {Language}", language);
            // Fallback to English if the requested language is not available
            if (language != "en")
            {
                var fallbackContent = await _legalDocumentService.GetTermsOfServiceAsync("en");
                return Ok(fallbackContent);
            }
            return NotFound($"Terms of service not found for language: {language}");
        }
    }

    [HttpGet("data_processing_consent")]
    [AllowAnonymous]
    public async Task<IActionResult> GetDataProcessingConsent([FromQuery] string language = "en")
    {
        try
        {
            var content = await _legalDocumentService.GetDataProcessingConsentAsync(language);
            return Ok(content);
        }
        catch (FileNotFoundException)
        {
            _logger.LogWarning("Data processing consent not found for language: {Language}", language);
            // Fallback to English if the requested language is not available
            if (language != "en")
            {
                var fallbackContent = await _legalDocumentService.GetDataProcessingConsentAsync("en");
                return Ok(fallbackContent);
            }
            return NotFound($"Data processing consent not found for language: {language}");
        }
    }

    [HttpGet("cross_border_transfer")]
    [AllowAnonymous]
    public async Task<IActionResult> GetCrossBorderTransfer([FromQuery] string language = "en")
    {
        try
        {
            var content = await _legalDocumentService.GetCrossBorderTransferAsync(language);
            return Ok(content);
        }
        catch (FileNotFoundException)
        {
            _logger.LogWarning("Cross border transfer document not found for language: {Language}", language);
            // Fallback to English if the requested language is not available
            if (language != "en")
            {
                var fallbackContent = await _legalDocumentService.GetCrossBorderTransferAsync("en");
                return Ok(fallbackContent);
            }
            return NotFound($"Cross border transfer document not found for language: {language}");
        }
    }
}