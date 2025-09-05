import 'models.dart';

/// Example response schema from GET /api/plans (truncated):
/// [
///   {
///     "plan": "standard",
///     "name": "Standard",
///     "description": "...",
///     "monthlyPrices": { "USD": 19, "JPY": 2900 },
///     "yearlyPrices":  { "USD": 179, "JPY": 26800 },
///     "quotas": {
///       "textInputTokensPerMonth": 5000000,
///       "textOutputTokensPerMonth": 400000,
///       "ttsMinutesPerMonth": 60,
///       "imageGenerationPerMonth": 40,
///       "translationEnabled": true,
///       "memoryPersistence": true,
///       "defaultModel": "gpt-4o-mini"
///     }
///   }
/// ]

class PlanConfig {
  final Plan plan;
  final String name;
  final String description;
  final Map<String, PlanPrice> prices;
  final PlanQuotas quotas;
  
  const PlanConfig({
    required this.plan,
    required this.name,
    required this.description,
    required this.prices,
    required this.quotas,
  });

  factory PlanConfig.fromJson(Map<String, dynamic> json) {
    final plan = _parsePlan(json['plan'] as String?);
    final name = (json['name'] ?? '').toString();
    final description = (json['description'] ?? '').toString();
    final monthly = (json['monthlyPrices'] as Map?)?.map((k, v) => MapEntry(k.toString().toUpperCase(), (v as num).toDouble())) ?? {};
    final yearly  = (json['yearlyPrices']  as Map?)?.map((k, v) => MapEntry(k.toString().toUpperCase(), (v as num).toDouble())) ?? {};

    final prices = <String, PlanPrice>{};
    final currencies = {...monthly.keys, ...yearly.keys};
    for (final c in currencies) {
      prices[c] = PlanPrice(
        monthly: monthly[c] ?? 0,
        yearly: yearly[c] ?? 0,
        currency: c,
        symbol: _currencySymbol(c),
      );
    }

    final quotas = PlanQuotas.fromJson((json['quotas'] as Map?)?.cast<String, dynamic>() ?? const {});

    return PlanConfig(plan: plan, name: name, description: description, prices: prices, quotas: quotas);
  }
}

class PlanPrice {
  final double monthly;
  final double yearly;
  final String currency;
  final String symbol;
  
  const PlanPrice({
    required this.monthly,
    required this.yearly,
    required this.currency,
    required this.symbol,
  });
}

class PlanQuotas {
  // Voice features
  final int realtimeVoiceMinutesPerMonth;
  final int maxSessionMinutes;
  final int maxDailyVoiceMinutes;
  final int offlineSTTMinutesPerMonth;
  final int ttsMinutesPerMonth;
  
  // Text/Image features
  final int textInputTokensPerMonth;
  final int textOutputTokensPerMonth;
  final int dailyTextQuestions;
  final bool unlimitedTextQuestions;
  
  // Image generation
  final int imageGenerationPerMonth;
  final String imageQuality;
  
  // Other features
  final bool translationEnabled;
  final bool realtimeTranslation;
  final bool memoryPersistence;
  final String defaultModel;
  
  const PlanQuotas({
    this.realtimeVoiceMinutesPerMonth = 0,
    this.maxSessionMinutes = 0,
    this.maxDailyVoiceMinutes = 0,
    this.offlineSTTMinutesPerMonth = 0,
    this.ttsMinutesPerMonth = 0,
    this.textInputTokensPerMonth = 0,
    this.textOutputTokensPerMonth = 0,
    this.dailyTextQuestions = 0,
    this.unlimitedTextQuestions = false,
    this.imageGenerationPerMonth = 0,
    this.imageQuality = 'standard',
    this.translationEnabled = false,
    this.realtimeTranslation = false,
    this.memoryPersistence = false,
    this.defaultModel = 'gpt-4o-mini',
  });

  factory PlanQuotas.fromJson(Map<String, dynamic> json) {
    int _i(String k) => (json[k] as num?)?.toInt() ?? 0;
    bool _b(String k) => (json[k] as bool?) ?? false;
    String _s(String k, String d) => (json[k] ?? d).toString();
    return PlanQuotas(
      realtimeVoiceMinutesPerMonth: _i('realtimeVoiceMinutesPerMonth'),
      maxSessionMinutes: _i('maxSessionMinutes'),
      maxDailyVoiceMinutes: _i('maxDailyVoiceMinutes'),
      offlineSTTMinutesPerMonth: _i('offlineSTTMinutesPerMonth'),
      ttsMinutesPerMonth: _i('ttsMinutesPerMonth'),
      textInputTokensPerMonth: _i('textInputTokensPerMonth'),
      textOutputTokensPerMonth: _i('textOutputTokensPerMonth'),
      dailyTextQuestions: _i('dailyTextQuestions'),
      unlimitedTextQuestions: _b('unlimitedTextQuestions'),
      imageGenerationPerMonth: _i('imageGenerationPerMonth'),
      imageQuality: _s('imageQuality', 'standard'),
      translationEnabled: _b('translationEnabled'),
      realtimeTranslation: _b('realtimeTranslation'),
      memoryPersistence: _b('memoryPersistence'),
      defaultModel: _s('defaultModel', 'gpt-4o-mini'),
    );
  }
}

class PlanConfigurations {
  static final Map<Plan, PlanConfig> configs = {
    Plan.free: const PlanConfig(
      plan: Plan.free,
      name: 'Free',
      description: 'High-quality text + image understanding entry experience',
      prices: {
        'USD': PlanPrice(monthly: 0, yearly: 0, currency: 'USD', symbol: r'$'),
        'JPY': PlanPrice(monthly: 0, yearly: 0, currency: 'JPY', symbol: '¥'),
        'KRW': PlanPrice(monthly: 0, yearly: 0, currency: 'KRW', symbol: '₩'),
        'TWD': PlanPrice(monthly: 0, yearly: 0, currency: 'TWD', symbol: r'NT$'),
        'CNY': PlanPrice(monthly: 0, yearly: 0, currency: 'CNY', symbol: '¥'),
      },
      quotas: PlanQuotas(
        dailyTextQuestions: 3,
        unlimitedTextQuestions: false,
        memoryPersistence: false,
      ),
    ),
    
    Plan.standard: const PlanConfig(
      plan: Plan.standard,
      name: 'Standard',
      description: 'Memory, high-quality text + image understanding, TTS playback',
      prices: {
        'USD': PlanPrice(monthly: 19, yearly: 179, currency: 'USD', symbol: r'$'),
        'JPY': PlanPrice(monthly: 2900, yearly: 26800, currency: 'JPY', symbol: '¥'),
        'KRW': PlanPrice(monthly: 25900, yearly: 239000, currency: 'KRW', symbol: '₩'),
        'TWD': PlanPrice(monthly: 590, yearly: 5690, currency: 'TWD', symbol: r'NT$'),
        'CNY': PlanPrice(monthly: 138, yearly: 1298, currency: 'CNY', symbol: '¥'),
      },
      quotas: PlanQuotas(
        textInputTokensPerMonth: 5000000,
        textOutputTokensPerMonth: 400000,
        unlimitedTextQuestions: true,
        ttsMinutesPerMonth: 60,
        imageGenerationPerMonth: 40,
        translationEnabled: true,
        memoryPersistence: true,
        defaultModel: 'gpt-4o-mini',
      ),
    ),
    
    Plan.pro: const PlanConfig(
      plan: Plan.pro,
      name: 'Pro',
      description: 'Memory, high-quality text + image, voice transcription and TTS',
      prices: {
        'USD': PlanPrice(monthly: 49, yearly: 469, currency: 'USD', symbol: r'$'),
        'JPY': PlanPrice(monthly: 7400, yearly: 70000, currency: 'JPY', symbol: '¥'),
        'KRW': PlanPrice(monthly: 66000, yearly: 629000, currency: 'KRW', symbol: '₩'),
        'TWD': PlanPrice(monthly: 1590, yearly: 14900, currency: 'TWD', symbol: r'NT$'),
        'CNY': PlanPrice(monthly: 358, yearly: 3388, currency: 'CNY', symbol: '¥'),
      },
      quotas: PlanQuotas(
        offlineSTTMinutesPerMonth: 300,
        ttsMinutesPerMonth: 200,
        textInputTokensPerMonth: 8000000,
        textOutputTokensPerMonth: 600000,
        unlimitedTextQuestions: true,
        imageGenerationPerMonth: 60,
        translationEnabled: true,
        memoryPersistence: true,
        defaultModel: 'gpt-4o',
      ),
    ),
    
    Plan.platinum: const PlanConfig(
      plan: Plan.platinum,
      name: 'Platinum',
      description: 'Realtime voice chat, unlimited text, transcription, and translation',
      prices: {
        'USD': PlanPrice(monthly: 89, yearly: 859, currency: 'USD', symbol: r'$'),
        'JPY': PlanPrice(monthly: 13400, yearly: 128800, currency: 'JPY', symbol: '¥'),
        'KRW': PlanPrice(monthly: 119000, yearly: 1149000, currency: 'KRW', symbol: '₩'),
        'TWD': PlanPrice(monthly: 2890, yearly: 26900, currency: 'TWD', symbol: r'NT$'),
        'CNY': PlanPrice(monthly: 648, yearly: 6188, currency: 'CNY', symbol: '¥'),
      },
      quotas: PlanQuotas(
        realtimeVoiceMinutesPerMonth: 200,
        maxSessionMinutes: 15,
        maxDailyVoiceMinutes: 30,
        offlineSTTMinutesPerMonth: 300,
        ttsMinutesPerMonth: 300,
        textInputTokensPerMonth: 12000000,
        textOutputTokensPerMonth: 1000000,
        unlimitedTextQuestions: true,
        imageGenerationPerMonth: 100,
        imageQuality: 'medium',
        translationEnabled: true,
        realtimeTranslation: true,
        memoryPersistence: true,
        defaultModel: 'gpt-4o',
      ),
    ),
  };
  
  /// Build configs from API response of GET /api/plans
  static List<PlanConfig> fromApi(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(PlanConfig.fromJson)
        .toList(growable: false);
  }
  
  static PlanConfig getConfig(Plan plan) {
    return configs[plan] ?? configs[Plan.free]!;
  }
  
  static String getPlanName(Plan plan) {
    return getConfig(plan).name;
  }
  
  static String getPlanDescription(Plan plan) {
    return getConfig(plan).description;
  }
  
  static PlanPrice? getPlanPrice(Plan plan, String currencyCode) {
    return getConfig(plan).prices[currencyCode];
  }
}

// Helpers
Plan _parsePlan(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'standard': return Plan.standard;
    case 'pro':      return Plan.pro;
    case 'platinum': return Plan.platinum;
    default:         return Plan.free;
  }
}

String _currencySymbol(String code) {
  switch (code.toUpperCase()) {
    case 'USD': return r'$';
    case 'JPY': return '¥';
    case 'KRW': return '₩';
    case 'TWD': return 'NT\$';
    case 'CNY': return '¥';
    default:    return code.toUpperCase();
  }
}
