using System;

namespace health_api.Models
{
    public enum QuotaType
    {
        DailyQuestions,      // Free plan: 3/day
        MonthlyVoiceMinutes, // Platinum: 200/month
        DailyVoiceMinutes,   // Platinum: 30/day
        MonthlySTTMinutes,   // Pro: 300/month, Platinum: 300/month
        MonthlyTTSMinutes,   // Standard: 60/month, Pro: 200/month, Platinum: 300/month
        MonthlyImages,       // Standard: 40/month, Pro: 60/month, Platinum: 100/month
        MonthlyInputTokens,  // Token tracking for all paid plans
        MonthlyOutputTokens  // Token tracking for all paid plans
    }

    public class QuotaLimit
    {
        public Plan Plan { get; set; }
        public QuotaType Type { get; set; }
        public int Limit { get; set; }
        public string Period { get; set; } // "daily" or "monthly"
    }

    public static class QuotaLimits
    {
        public static readonly Dictionary<(Plan, QuotaType), QuotaLimit> Limits = new()
        {
            // Free Plan
            [(Plan.Free, QuotaType.DailyQuestions)] = new QuotaLimit 
            { 
                Plan = Plan.Free, 
                Type = QuotaType.DailyQuestions, 
                Limit = 3, 
                Period = "daily" 
            },
            
            // Standard Plan
            [(Plan.Standard, QuotaType.MonthlyTTSMinutes)] = new QuotaLimit 
            { 
                Plan = Plan.Standard, 
                Type = QuotaType.MonthlyTTSMinutes, 
                Limit = 60, 
                Period = "monthly" 
            },
            [(Plan.Standard, QuotaType.MonthlyImages)] = new QuotaLimit 
            { 
                Plan = Plan.Standard, 
                Type = QuotaType.MonthlyImages, 
                Limit = 40, 
                Period = "monthly" 
            },
            [(Plan.Standard, QuotaType.MonthlyInputTokens)] = new QuotaLimit 
            { 
                Plan = Plan.Standard, 
                Type = QuotaType.MonthlyInputTokens, 
                Limit = 5000000, 
                Period = "monthly" 
            },
            [(Plan.Standard, QuotaType.MonthlyOutputTokens)] = new QuotaLimit 
            { 
                Plan = Plan.Standard, 
                Type = QuotaType.MonthlyOutputTokens, 
                Limit = 400000, 
                Period = "monthly" 
            },
            
            // Pro Plan
            [(Plan.Pro, QuotaType.MonthlySTTMinutes)] = new QuotaLimit 
            { 
                Plan = Plan.Pro, 
                Type = QuotaType.MonthlySTTMinutes, 
                Limit = 300, 
                Period = "monthly" 
            },
            [(Plan.Pro, QuotaType.MonthlyTTSMinutes)] = new QuotaLimit 
            { 
                Plan = Plan.Pro, 
                Type = QuotaType.MonthlyTTSMinutes, 
                Limit = 200, 
                Period = "monthly" 
            },
            [(Plan.Pro, QuotaType.MonthlyImages)] = new QuotaLimit 
            { 
                Plan = Plan.Pro, 
                Type = QuotaType.MonthlyImages, 
                Limit = 60, 
                Period = "monthly" 
            },
            [(Plan.Pro, QuotaType.MonthlyInputTokens)] = new QuotaLimit 
            { 
                Plan = Plan.Pro, 
                Type = QuotaType.MonthlyInputTokens, 
                Limit = 8000000, 
                Period = "monthly" 
            },
            [(Plan.Pro, QuotaType.MonthlyOutputTokens)] = new QuotaLimit 
            { 
                Plan = Plan.Pro, 
                Type = QuotaType.MonthlyOutputTokens, 
                Limit = 600000, 
                Period = "monthly" 
            },
            
            // Platinum Plan
            [(Plan.Platinum, QuotaType.MonthlyVoiceMinutes)] = new QuotaLimit 
            { 
                Plan = Plan.Platinum, 
                Type = QuotaType.MonthlyVoiceMinutes, 
                Limit = 200, 
                Period = "monthly" 
            },
            [(Plan.Platinum, QuotaType.DailyVoiceMinutes)] = new QuotaLimit 
            { 
                Plan = Plan.Platinum, 
                Type = QuotaType.DailyVoiceMinutes, 
                Limit = 30, 
                Period = "daily" 
            },
            [(Plan.Platinum, QuotaType.MonthlySTTMinutes)] = new QuotaLimit 
            { 
                Plan = Plan.Platinum, 
                Type = QuotaType.MonthlySTTMinutes, 
                Limit = 300, 
                Period = "monthly" 
            },
            [(Plan.Platinum, QuotaType.MonthlyTTSMinutes)] = new QuotaLimit 
            { 
                Plan = Plan.Platinum, 
                Type = QuotaType.MonthlyTTSMinutes, 
                Limit = 300, 
                Period = "monthly" 
            },
            [(Plan.Platinum, QuotaType.MonthlyImages)] = new QuotaLimit 
            { 
                Plan = Plan.Platinum, 
                Type = QuotaType.MonthlyImages, 
                Limit = 100, 
                Period = "monthly" 
            },
            [(Plan.Platinum, QuotaType.MonthlyInputTokens)] = new QuotaLimit 
            { 
                Plan = Plan.Platinum, 
                Type = QuotaType.MonthlyInputTokens, 
                Limit = 12000000, 
                Period = "monthly" 
            },
            [(Plan.Platinum, QuotaType.MonthlyOutputTokens)] = new QuotaLimit 
            { 
                Plan = Plan.Platinum, 
                Type = QuotaType.MonthlyOutputTokens, 
                Limit = 1000000, 
                Period = "monthly" 
            },
        };
        
        public static QuotaLimit? GetLimit(Plan plan, QuotaType type)
        {
            return Limits.TryGetValue((plan, type), out var limit) ? limit : null;
        }
        
        public static bool HasQuota(Plan plan, QuotaType type)
        {
            return Limits.ContainsKey((plan, type));
        }
    }
}