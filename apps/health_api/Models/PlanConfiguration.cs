using System.Collections.Generic;

namespace health_api.Models
{
    public class PlanConfiguration
    {
        public Plan Plan { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public Dictionary<string, decimal> MonthlyPrices { get; set; } = new();
        public Dictionary<string, decimal> YearlyPrices { get; set; } = new();
        public PlanQuotas Quotas { get; set; } = new();
    }

    public class PlanQuotas
    {
        // Voice features
        public int RealtimeVoiceMinutesPerMonth { get; set; }
        public int MaxSessionMinutes { get; set; }
        public int MaxDailyVoiceMinutes { get; set; }
        public int OfflineSTTMinutesPerMonth { get; set; }
        public int TTSMinutesPerMonth { get; set; }
        
        // Text/Image features
        public int TextInputTokensPerMonth { get; set; }
        public int TextOutputTokensPerMonth { get; set; }
        public int DailyTextQuestions { get; set; } // For free plan
        public bool UnlimitedTextQuestions { get; set; }
        
        // Image generation
        public int ImageGenerationPerMonth { get; set; }
        public string ImageQuality { get; set; } = "standard";
        
        // Other features
        public bool TranslationEnabled { get; set; }
        public bool RealtimeTranslation { get; set; }
        public bool MemoryPersistence { get; set; }
        public string DefaultModel { get; set; } = "gpt-4o-mini";
        public string FallbackModel { get; set; } = "gpt-4o-mini";
    }

    public static class PlanConfigurations
    {
        public static readonly Dictionary<Plan, PlanConfiguration> Configurations = new()
        {
            [Plan.Free] = new PlanConfiguration
            {
                Plan = Plan.Free,
                Name = "Free",
                Description = "High-quality text + image understanding entry experience",
                MonthlyPrices = new Dictionary<string, decimal>
                {
                    ["USD"] = 0m,
                    ["JPY"] = 0m,
                    ["KRW"] = 0m,
                    ["TWD"] = 0m,
                    ["CNY"] = 0m
                },
                YearlyPrices = new Dictionary<string, decimal>
                {
                    ["USD"] = 0m,
                    ["JPY"] = 0m,
                    ["KRW"] = 0m,
                    ["TWD"] = 0m,
                    ["CNY"] = 0m
                },
                Quotas = new PlanQuotas
                {
                    DailyTextQuestions = 3,
                    UnlimitedTextQuestions = false,
                    TTSMinutesPerMonth = 0,
                    MemoryPersistence = false,
                    DefaultModel = "gpt-4o-mini"
                }
            },
            
            [Plan.Standard] = new PlanConfiguration
            {
                Plan = Plan.Standard,
                Name = "Standard",
                Description = "Memory, high-quality text + image understanding, TTS playback",
                MonthlyPrices = new Dictionary<string, decimal>
                {
                    ["USD"] = 19m,
                    ["JPY"] = 2900m,
                    ["KRW"] = 25900m,
                    ["TWD"] = 590m,
                    ["CNY"] = 138m
                },
                YearlyPrices = new Dictionary<string, decimal>
                {
                    ["USD"] = 179m,
                    ["JPY"] = 26800m,
                    ["KRW"] = 239000m,
                    ["TWD"] = 5690m,
                    ["CNY"] = 1298m
                },
                Quotas = new PlanQuotas
                {
                    TextInputTokensPerMonth = 5000000,
                    TextOutputTokensPerMonth = 400000,
                    UnlimitedTextQuestions = true,
                    TTSMinutesPerMonth = 60,
                    ImageGenerationPerMonth = 40,
                    TranslationEnabled = true,
                    MemoryPersistence = true,
                    DefaultModel = "gpt-4o-mini",
                    FallbackModel = "gpt-4o"
                }
            },
            
            [Plan.Pro] = new PlanConfiguration
            {
                Plan = Plan.Pro,
                Name = "Pro",
                Description = "Memory, high-quality text + image, voice transcription and TTS",
                MonthlyPrices = new Dictionary<string, decimal>
                {
                    ["USD"] = 49m,
                    ["JPY"] = 7400m,
                    ["KRW"] = 66000m,
                    ["TWD"] = 1590m,
                    ["CNY"] = 358m
                },
                YearlyPrices = new Dictionary<string, decimal>
                {
                    ["USD"] = 469m,
                    ["JPY"] = 70000m,
                    ["KRW"] = 629000m,
                    ["TWD"] = 14900m,
                    ["CNY"] = 3388m
                },
                Quotas = new PlanQuotas
                {
                    OfflineSTTMinutesPerMonth = 300,
                    TTSMinutesPerMonth = 200,
                    TextInputTokensPerMonth = 8000000,
                    TextOutputTokensPerMonth = 600000,
                    UnlimitedTextQuestions = true,
                    ImageGenerationPerMonth = 60,
                    TranslationEnabled = true,
                    MemoryPersistence = true,
                    DefaultModel = "gpt-4o",
                    FallbackModel = "gpt-4o-mini"
                }
            },
            
            [Plan.Platinum] = new PlanConfiguration
            {
                Plan = Plan.Platinum,
                Name = "Platinum",
                Description = "Realtime voice chat, unlimited text, transcription, and translation",
                MonthlyPrices = new Dictionary<string, decimal>
                {
                    ["USD"] = 89m,
                    ["JPY"] = 13400m,
                    ["KRW"] = 119000m,
                    ["TWD"] = 2890m,
                    ["CNY"] = 648m
                },
                YearlyPrices = new Dictionary<string, decimal>
                {
                    ["USD"] = 859m,
                    ["JPY"] = 128800m,
                    ["KRW"] = 1149000m,
                    ["TWD"] = 26900m,
                    ["CNY"] = 6188m
                },
                Quotas = new PlanQuotas
                {
                    RealtimeVoiceMinutesPerMonth = 200,
                    MaxSessionMinutes = 15,
                    MaxDailyVoiceMinutes = 30,
                    OfflineSTTMinutesPerMonth = 300,
                    TTSMinutesPerMonth = 300,
                    TextInputTokensPerMonth = 12000000,
                    TextOutputTokensPerMonth = 1000000,
                    UnlimitedTextQuestions = true,
                    ImageGenerationPerMonth = 100,
                    ImageQuality = "medium",
                    TranslationEnabled = true,
                    RealtimeTranslation = true,
                    MemoryPersistence = true,
                    DefaultModel = "gpt-4o",
                    FallbackModel = "gpt-4o-mini"
                }
            }
        };
    }
}