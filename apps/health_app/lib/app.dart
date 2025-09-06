import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'pages/assistant_page.dart';
import 'pages/tasks_page.dart';
import 'pages/task_edit_page.dart';
import 'pages/circle_page.dart';
import 'pages/settings_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/legal/privacy_policy_page.dart';
import 'pages/legal/terms_of_service_page.dart';
import 'services/consent_service.dart';
import 'widgets/consent_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/gen/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    List<String>? fallbacks;
    final code = state.locale?.languageCode;
    if (code == 'zh') {
      // Prefer platform defaults; do not force an explicit family to avoid init errors
      fallbacks = ['Noto Sans CJK SC', 'PingFang SC', 'Microsoft YaHei', 'Heiti SC', 'Source Han Sans SC', 'Droid Sans Fallback'];
    } else if (code == 'ja') {
      fallbacks = ['Noto Sans CJK JP', 'Hiragino Sans', 'Yu Gothic UI', 'Meiryo', 'Source Han Sans JP'];
    } else {
      fallbacks = ['SF Pro Text', 'Roboto', 'Segoe UI', 'Inter'];
    }

    return MaterialApp(
      title: AppLocalizations.of(context)?.appTitle ?? 'Health Assistant',
      debugShowCheckedModeBanner: false,
      themeMode: state.themeMode,
      locale: state.locale,
      supportedLocales: const [
        Locale('en'),        // English
        Locale('zh'),        // Chinese (Simplified)
        Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'), // Chinese (Traditional)
        Locale('fr'),        // French
        Locale('de'),        // German
        Locale('ja'),        // Japanese
        Locale('ko'),        // Korean
        Locale('pt'),        // Portuguese
        Locale('ru'),        // Russian
        Locale('es'),        // Spanish
        Locale('vi'),        // Vietnamese
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildAppTheme(seed: Color(state.seedColor), brightness: Brightness.light, fontFallback: fallbacks, elderMode: state.elderMode),
      darkTheme: buildAppTheme(seed: Color(state.seedColor), brightness: Brightness.dark, fontFallback: fallbacks, elderMode: state.elderMode),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(state.textScale),
          ),
          child: child!,
        );
      },
      home: Consumer<AppState>(
        builder: (context, appState, _) {
          if (!appState.isAuthenticated) {
            return const LoginPage();
          }
          return const AppShell();
        },
      ),
      routes: {
        '/tasks/edit': (_) => const TaskEditPage(),
        '/login': (_) => const LoginPage(),
        '/legal/privacy': (_) => const PrivacyPolicyPage(),
        '/legal/terms': (_) => const TermsOfServicePage(),
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _pages = const [
    AssistantPage(),
    TasksPage(),
    CirclePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Check consent status after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConsentStatus();
    });
  }

  Future<void> _checkConsentStatus() async {
    try {
      // Check if user has agreed to terms from database
      final consentRes = await ConsentService().getConsentStatus();
      if (consentRes.success && consentRes.data != null) {
        final hasAgreedToTerms = consentRes.data!.hasAgreedToTerms;
        final hasAgreedToPrivacy = consentRes.data!.hasAgreedToPrivacyPolicy;
        final hasAgreedToDataProcessing = consentRes.data!.hasAgreedToDataProcessing;
        
        // If any consent is missing, show consent dialog
        if (!hasAgreedToTerms || !hasAgreedToPrivacy || !hasAgreedToDataProcessing) {
          if (mounted) {
            final agreed = await showConsentDialog(context);
            if (!agreed) {
              // If user doesn't agree, log them out
              if (mounted) {
                final appState = Provider.of<AppState>(context, listen: false);
                await appState.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            }
          }
        }
      } else {
        debugPrint('Failed to get consent status: ${consentRes.error ?? 'unknown error'}');
      }
    } catch (e) {
      // If we can't check consent status, it might be a network issue
      // We'll let the user continue but check again next time
      debugPrint('Failed to check consent status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // Show FAB only on Tasks page
    final showFab = _index == 1;
    
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: _pages),
      ),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed('/tasks/edit'),
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              backgroundColor: theme.colorScheme.primary,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _index,
          height: 65,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.psychology_outlined),
              selectedIcon: const Icon(Icons.psychology),
              label: t.navAssistant,
            ),
            NavigationDestination(
              icon: const Icon(Icons.task_outlined),
              selectedIcon: const Icon(Icons.task),
              label: t.navTasks,
            ),
            NavigationDestination(
              icon: const Icon(Icons.group_outlined),
              selectedIcon: const Icon(Icons.group),
              label: t.navCircle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: t.navSettings,
            ),
          ],
          onDestinationSelected: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
