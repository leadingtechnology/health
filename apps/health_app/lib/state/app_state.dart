import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../l10n/gen/app_localizations.dart';

class AppState extends ChangeNotifier {
  Plan plan = Plan.free;
  ModelTier modelTier = ModelTier.basic;

  int dailyLimitFree = 3;
  int usedToday = 0;
  DateTime lastAskDay = DateTime.now();

  bool elderMode = false;
  double textScale = 1.0;
  int seedColor = Colors.teal.toARGB32();
  ThemeMode themeMode = ThemeMode.system;
  Locale? locale; // null means follow system

  final List<Message> messages = [];
  final List<TaskItem> tasks = [];
  final List<Member> members = [
    Member(id: 'm1', name: 'Alice', relation: 'Family', icon: Icons.person_outline),
    Member(id: 'm2', name: 'Dr. Chen', relation: 'Physician', icon: Icons.medical_services_outlined),
  ];

  Future<void> bootstrap() async {
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

    final locCode = prefs.getString('localeCode');
    if (locCode != null && locCode.isNotEmpty && locCode != 'system') {
      locale = Locale(locCode);
    } else {
      try {
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final code = deviceLocale.languageCode;
        const supported = ['en', 'zh', 'ja'];
        final chosen = supported.contains(code) ? code : 'ja';
        locale = Locale(chosen);
        await prefs.setString('localeCode', chosen);
      } catch (_) {
        locale = const Locale('ja');
        await prefs.setString('localeCode', 'ja');
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
    if (plan == Plan.free) return usedToday < dailyLimitFree;
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
    } else {
      locale = Locale(code);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeCode', code);
    notifyListeners();
  }

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

  Future<AskResult> ask(String text) async {
    resetIfNewDay();
    if (plan == Plan.free && usedToday >= dailyLimitFree) {
      return AskResult.limited;
    }
    messages.add(Message(
      id: UniqueKey().toString(),
      fromUser: true,
      text: text.trim(),
      time: DateTime.now(),
    ));
    if (plan == Plan.free) {
      usedToday++;
      await _persist();
    }
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    final loc = await AppLocalizations.delegate.load(locale ?? const Locale('en'));
    messages.add(Message(
      id: UniqueKey().toString(),
      fromUser: false,
      time: DateTime.now(),
      text: loc.sampleAdvice,
      actions: const ['set_task', 'export_pdf', 'share'],
    ));
    notifyListeners();
    return AskResult.ok;
  }
}

enum AskResult { ok, limited }
