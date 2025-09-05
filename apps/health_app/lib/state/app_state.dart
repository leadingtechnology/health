import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  
  User? currentUser;
  bool isAuthenticated = false;
  
  Plan plan = Plan.free;
  ModelTier modelTier = ModelTier.basic;
  
  // Getters for user information
  String? get userName => currentUser?.name;
  String? get userEmail => currentUser?.email;

  int dailyLimitFree = 3;
  int usedToday = 0;
  DateTime lastAskDay = DateTime.now();

  bool elderMode = false;
  double textScale = 1.0;
  int seedColor = Colors.teal.toARGB32();
  ThemeMode themeMode = ThemeMode.system;
  Locale? locale; // null means follow system
  String? countryCode; // Country/Region code (e.g., 'US', 'JP')

  final List<Message> messages = [];
  final List<TaskItem> tasks = [];
  final List<Member> members = [
    Member(id: 'm1', name: 'Alice', relation: 'Family', icon: Icons.person_outline),
    Member(id: 'm2', name: 'Dr. Chen', relation: 'Physician', icon: Icons.medical_services_outlined),
  ];

  Future<void> bootstrap() async {
    // Initialize API service
    await _api.initialize();
    
    // Check if user is authenticated
    if (_api.isAuthenticated) {
      final result = await _auth.fetchCurrentUser();
      if (result.success && result.user != null) {
        currentUser = result.user;
        isAuthenticated = true;
        plan = result.user!.plan;
        modelTier = result.user!.modelTier;
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    usedToday = prefs.getInt('usedToday') ?? 0;
    final last = prefs.getString('lastAskDay');
    if (last != null) {
      lastAskDay = DateTime.tryParse(last) ?? DateTime.now();
    }
    final planStr = prefs.getString('plan');
    if (planStr != null) {
      plan = Plan.values.firstWhere((e) => e.toString() == planStr, orElse: () => Plan.free);
    }
    final tierStr = prefs.getString('tier');
    if (tierStr != null) {
      modelTier = ModelTier.values.firstWhere((e) => e.toString() == tierStr, orElse: () => ModelTier.basic);
    }
    final ts = prefs.getDouble('textScale');
    if (ts != null) textScale = ts;
    elderMode = prefs.getBool('elderMode') ?? false;
    seedColor = prefs.getInt('seedColor') ?? Colors.teal.toARGB32();
    final tm = prefs.getString('themeMode');
    if (tm == 'light') themeMode = ThemeMode.light;
    if (tm == 'dark') themeMode = ThemeMode.dark;
    if (tm == 'system' || tm == null) themeMode = ThemeMode.system;

    // Always detect country code from system (no manual setting)
    try {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final country = deviceLocale.countryCode;
      if (country != null && country.isNotEmpty) {
        countryCode = country;
      } else {
        countryCode = 'US'; // Default to US if system doesn't provide
      }
    } catch (_) {
      countryCode = 'US'; // Default to US on error
    }

    // Load language/locale
    final locCode = prefs.getString('localeCode');
    if (locCode != null && locCode.isNotEmpty && locCode != 'system') {
      locale = Locale(locCode);
    } else {
      try {
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final code = deviceLocale.languageCode;
        const supported = ['en', 'zh', 'ja', 'fr', 'de', 'ko', 'pt', 'ru', 'es', 'vi'];
        final chosen = supported.contains(code) ? code : 'en'; // Default to English
        
        // Handle Traditional Chinese
        if (code == 'zh' && deviceLocale.countryCode == 'TW') {
          locale = const Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW');
          await prefs.setString('localeCode', 'zh_TW');
        } else {
          locale = Locale(chosen);
          await prefs.setString('localeCode', chosen);
        }
      } catch (_) {
        locale = const Locale('en'); // Default to English
        await prefs.setString('localeCode', 'en');
      }
    }

    if (messages.isEmpty) {
      final loc = await AppLocalizations.delegate.load(locale ?? const Locale('en'));
      messages.add(Message(
        id: UniqueKey().toString(),
        fromUser: false,
        time: DateTime.now(),
        text: loc.welcomeMessage,
        actions: const ['set_task'],
      ));
    }
    resetIfNewDay();
    notifyListeners();
  }

  bool get isFreePlan => plan == Plan.free;
  bool get canAskNow {
    resetIfNewDay();
    // Only Free plan has daily question limits
    if (plan == Plan.free) return usedToday < dailyLimitFree;
    // All paid plans (Standard, Pro, Platinum) have unlimited text questions
    return true;
  }

  void resetIfNewDay() {
    final today = DateTime.now();
    if (today.year != lastAskDay.year || today.month != lastAskDay.month || today.day != lastAskDay.day) {
      usedToday = 0;
      lastAskDay = today;
      _persist();
      notifyListeners();
    }
  }

  Future<void> setPlan(Plan p) async {
    plan = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plan', p.toString());
    notifyListeners();
  }

  Future<void> setModelTier(ModelTier t) async {
    modelTier = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tier', t.toString());
    notifyListeners();
  }

  Future<void> setTextScale(double scale) async {
    textScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScale', scale);
    notifyListeners();
  }

  Future<void> setElderMode(bool value) async {
    elderMode = value;
    // Use two clear sizes: normal and large
    textScale = elderMode ? 1.2 : 1.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('elderMode', elderMode);
    await prefs.setDouble('textScale', textScale);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    final prefs = await SharedPreferences.getInstance();
    final s = m == ThemeMode.light
        ? 'light'
        : m == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString('themeMode', s);
    notifyListeners();
  }

  Future<void> setSeedColor(Color c) async {
    seedColor = c.toARGB32();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', seedColor);
    notifyListeners();
  }

  Future<void> setLocaleCode(String code) async {
    if (code == 'system') {
      locale = null;
    } else if (code == 'zh_TW') {
      locale = const Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW');
    } else {
      locale = Locale(code);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeCode', code);
    notifyListeners();
  }
  
  // Country code is now automatically detected from system only
  // No manual setting allowed

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('usedToday', usedToday);
    await prefs.setString('lastAskDay', lastAskDay.toIso8601String());
  }

  void addTaskFromSuggestion(String title) {
    final now = DateTime.now();
    final t = title.isEmpty ? 'Suggested task' : title;
    tasks.add(TaskItem(id: UniqueKey().toString(), title: t, due: now.add(const Duration(hours: 8))));
    notifyListeners();
  }

  void toggleTask(String id, bool done) {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      tasks[idx].done = done;
      notifyListeners();
    }
  }

  void addTask(TaskItem t) {
    tasks.add(t);
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    currentUser = null;
    isAuthenticated = false;
    plan = Plan.free;
    modelTier = ModelTier.basic;
    messages.clear();
    tasks.clear();
    notifyListeners();
  }
  
  Future<AskResult> ask(String text) async {
    resetIfNewDay();
    
    // Check quota for free plan
    if (plan == Plan.free && usedToday >= dailyLimitFree) {
      messages.add(Message(
        id: UniqueKey().toString(),
        fromUser: false,
        time: DateTime.now(),
        text: 'You\'ve reached your daily limit of 3 questions. Upgrade to continue!',
        actions: const [],
      ));
      notifyListeners();
      return AskResult.limited;
    }
    
    // Add user message
    messages.add(Message(
      id: UniqueKey().toString(),
      fromUser: true,
      text: text.trim(),
      time: DateTime.now(),
    ));
    notifyListeners();

    // Call OpenAI API through backend
    final result = await _api.askOpenAI(text.trim());
    
    if (result.success && result.data != null) {
      // Success - add AI response with plan-specific actions
      List<String> actions = ['set_task'];
      
      // Add actions based on plan
      if (plan != Plan.free) {
        actions.add('export_pdf');
        actions.add('share');
      }
      if (plan == Plan.standard || plan == Plan.pro || plan == Plan.platinum) {
        actions.add('tts_play'); // TTS playback available
      }
      if (plan == Plan.platinum) {
        actions.add('translate'); // Real-time translation
      }
      
      messages.add(Message(
        id: UniqueKey().toString(),
        fromUser: false,
        time: DateTime.now(),
        text: result.data!,
        actions: actions,
      ));
      
      // Update usage for free plan
      if (plan == Plan.free) {
        usedToday++;
        await _persist();
      }
      
      notifyListeners();
      return AskResult.ok;
    } else {
      // Error handling
      String errorMessage;
      if (result.error?.contains('quota') ?? false) {
        errorMessage = plan == Plan.free 
          ? 'Daily free quota reached. Upgrade to Standard, Pro, or Platinum for unlimited access!'
          : 'Monthly quota reached. Consider upgrading your plan.';
      } else if (result.error?.contains('429') ?? false) {
        errorMessage = 'Service is busy. Please try again in a moment.';
      } else {
        errorMessage = 'Sorry, I encountered an error. Please try again.';
      }
      
      messages.add(Message(
        id: UniqueKey().toString(),
        fromUser: false,
        time: DateTime.now(),
        text: errorMessage,
        actions: const [],
      ));
      
      notifyListeners();
      return result.error?.contains('quota') ?? false ? AskResult.limited : AskResult.ok;
    }
  }
}

enum AskResult { ok, limited }
