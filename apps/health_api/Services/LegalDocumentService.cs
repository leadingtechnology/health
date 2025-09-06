using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using HealthApi.DTOs;

namespace HealthApi.Services
{
    public interface ILegalDocumentService
    {
        Task<LegalDocumentDto?> GetDocumentAsync(string docKey, string locale);
        Task<Dictionary<string, LegalDocumentDto>> GetAllDocumentsByLocaleAsync(string locale);
        string ComputeSha256(string content);
        Task<string> GetPrivacyPolicyAsync(string language);
        Task<string> GetTermsOfServiceAsync(string language);
        Task<string> GetDataProcessingConsentAsync(string language);
        Task<string> GetCrossBorderTransferAsync(string language);
    }

    public class LegalDocumentService : ILegalDocumentService
    {
        private readonly IWebHostEnvironment _env;
        private readonly ILogger<LegalDocumentService> _logger;
        private readonly Dictionary<string, LegalDocumentMetadata> _documentMetadata;

        public LegalDocumentService(IWebHostEnvironment env, ILogger<LegalDocumentService> logger)
        {
            _env = env;
            _logger = logger;
            
            // Initialize document metadata
            _documentMetadata = new Dictionary<string, LegalDocumentMetadata>
            {
                ["terms_of_service"] = new LegalDocumentMetadata
                {
                    Key = "terms_of_service",
                    Version = "2025-01-06",
                    EffectiveDate = new DateTime(2025, 1, 6),
                    AvailableLocales = new[] { "en", "ja", "ko", "zh" }
                },
                ["privacy_policy"] = new LegalDocumentMetadata
                {
                    Key = "privacy_policy",
                    Version = "2025-01-06",
                    EffectiveDate = new DateTime(2025, 1, 6),
                    AvailableLocales = new[] { "en", "ja", "ko", "zh" }
                },
                ["data_processing_consent"] = new LegalDocumentMetadata
                {
                    Key = "data_processing_consent",
                    Version = "2025-01-06",
                    EffectiveDate = new DateTime(2025, 1, 6),
                    AvailableLocales = new[] { "en", "ja", "ko", "zh" }
                },
                ["cross_border_transfer"] = new LegalDocumentMetadata
                {
                    Key = "cross_border_transfer",
                    Version = "2025-01-06",
                    EffectiveDate = new DateTime(2025, 1, 6),
                    AvailableLocales = new[] { "en", "ja", "ko", "zh" }
                },
                ["tokusho_confirm"] = new LegalDocumentMetadata
                {
                    Key = "tokusho_confirm",
                    Version = "2025-01-06",
                    EffectiveDate = new DateTime(2025, 1, 6),
                    AvailableLocales = new[] { "ja" } // Japan-specific
                }
            };
        }

        public async Task<LegalDocumentDto?> GetDocumentAsync(string docKey, string locale)
        {
            try
            {
                if (!_documentMetadata.TryGetValue(docKey, out var metadata))
                {
                    _logger.LogWarning("Document key {DocKey} not found", docKey);
                    return null;
                }

                // Determine best locale to load:
                // 1) Use requested locale if available
                // 2) Else, if English version exists in metadata, use 'en'
                // 3) Else, use the first available locale from metadata
                var candidateLocale = metadata.AvailableLocales.Contains(locale)
                    ? locale
                    : (metadata.AvailableLocales.Contains("en") ? "en" : metadata.AvailableLocales.FirstOrDefault());

                if (string.IsNullOrEmpty(candidateLocale))
                {
                    _logger.LogWarning("No available locales for document {DocKey}", docKey);
                    return null;
                }

                // Path structure: wwwroot/legal/{locale}/{docKey}.md
                var filePath = Path.Combine(_env.WebRootPath, "legal", candidateLocale, $"{docKey}.md");

                if (!File.Exists(filePath))
                {
                    // As a last resort, if we didn't already try English and the file is missing, try 'en'
                    if (candidateLocale != "en" && metadata.AvailableLocales.Contains("en"))
                    {
                        var enPath = Path.Combine(_env.WebRootPath, "legal", "en", $"{docKey}.md");
                        if (File.Exists(enPath))
                        {
                            filePath = enPath;
                            candidateLocale = "en";
                        }
                        else
                        {
                            // Do not warn for intentional absence in non-supported locales
                            _logger.LogDebug("Document file not found for {DocKey} in locales [{Locales}]", docKey, string.Join(",", metadata.AvailableLocales));
                            return null;
                        }
                    }
                    else
                    {
                        // Do not warn for intentional absence in non-supported locales
                        _logger.LogDebug("Document file not found for {DocKey} in locales [{Locales}]", docKey, string.Join(",", metadata.AvailableLocales));
                        return null;
                    }
                }

                var content = await File.ReadAllTextAsync(filePath);
                var title = GetTitleForDocument(docKey, locale);
                
                return new LegalDocumentDto
                {
                    Key = docKey,
                    Version = metadata.Version,
                    Title = title,
                    Content = content,
                    ContentSha256 = ComputeSha256(content),
                    Locale = candidateLocale,
                    EffectiveDate = metadata.EffectiveDate
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading document {DocKey} for locale {Locale}", docKey, locale);
                return null;
            }
        }

        public async Task<Dictionary<string, LegalDocumentDto>> GetAllDocumentsByLocaleAsync(string locale)
        {
            var documents = new Dictionary<string, LegalDocumentDto>();
            
            foreach (var kvp in _documentMetadata)
            {
                var doc = await GetDocumentAsync(kvp.Key, locale);
                if (doc != null)
                {
                    documents[kvp.Key] = doc;
                }
            }
            
            return documents;
        }

        public string ComputeSha256(string content)
        {
            using var sha256 = SHA256.Create();
            var bytes = Encoding.UTF8.GetBytes(content);
            var hash = sha256.ComputeHash(bytes);
            return Convert.ToHexString(hash).ToLowerInvariant();
        }

        private string GetTitleForDocument(string docKey, string locale)
        {
            var titles = new Dictionary<(string, string), string>
            {
                // English
                [("terms_of_service", "en")] = "Terms of Service",
                [("privacy_policy", "en")] = "Privacy Policy",
                [("data_processing_consent", "en")] = "Health Data Processing Consent",
                [("cross_border_transfer", "en")] = "Cross-Border Data Transfer",
                
                // Japanese
                [("terms_of_service", "ja")] = "利用規約",
                [("privacy_policy", "ja")] = "プライバシーポリシー",
                [("data_processing_consent", "ja")] = "健康情報の取得・処理への同意",
                [("cross_border_transfer", "ja")] = "越境データ移転",
                [("tokusho_confirm", "ja")] = "特定商取引法に基づく表記",
                
                // Korean
                [("terms_of_service", "ko")] = "서비스 이용약관",
                [("privacy_policy", "ko")] = "개인정보 처리방침",
                [("data_processing_consent", "ko")] = "건강 데이터 처리 동의",
                [("cross_border_transfer", "ko")] = "국경 간 데이터 이전",
                
                // Chinese
                [("terms_of_service", "zh")] = "服务条款",
                [("privacy_policy", "zh")] = "隐私政策",
                [("data_processing_consent", "zh")] = "健康数据处理同意",
                [("cross_border_transfer", "zh")] = "跨境数据传输"
            };
            
            return titles.TryGetValue((docKey, locale), out var title) 
                ? title 
                : titles.GetValueOrDefault((docKey, "en"), docKey);
        }

        public async Task<string> GetPrivacyPolicyAsync(string language)
        {
            var doc = await GetDocumentAsync("privacy_policy", language);
            if (doc == null)
            {
                throw new FileNotFoundException($"Privacy policy not found for language: {language}");
            }
            return doc.Content;
        }

        public async Task<string> GetTermsOfServiceAsync(string language)
        {
            var doc = await GetDocumentAsync("terms_of_service", language);
            if (doc == null)
            {
                throw new FileNotFoundException($"Terms of service not found for language: {language}");
            }
            return doc.Content;
        }

        public async Task<string> GetDataProcessingConsentAsync(string language)
        {
            var doc = await GetDocumentAsync("data_processing_consent", language);
            if (doc == null)
            {
                throw new FileNotFoundException($"Data processing consent not found for language: {language}");
            }
            return doc.Content;
        }

        public async Task<string> GetCrossBorderTransferAsync(string language)
        {
            var doc = await GetDocumentAsync("cross_border_transfer", language);
            if (doc == null)
            {
                throw new FileNotFoundException($"Cross border transfer document not found for language: {language}");
            }
            return doc.Content;
        }

        private class LegalDocumentMetadata
        {
            public string Key { get; set; } = string.Empty;
            public string Version { get; set; } = string.Empty;
            public DateTime EffectiveDate { get; set; }
            public string[] AvailableLocales { get; set; } = Array.Empty<string>();
        }
    }
}
