import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'pages/assistant_page.dart';
import 'pages/tasks_page.dart';
import 'pages/task_edit_page.dart';
import 'pages/logs_page.dart';
import 'pages/circle_page.dart';
import 'pages/settings_page.dart';
import 'pages/auth/login_page.dart';
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
      supportedLocales: const [Locale('en'), Locale('zh'), Locale('ja')],
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
    LogsPage(),
    CirclePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final titles = [t.navAssistant, t.navTasks, t.navLogs, t.navCircle, t.navSettings];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.assistant), label: t.navAssistant),
          NavigationDestination(icon: const Icon(Icons.check_circle_outlined), label: t.navTasks),
          NavigationDestination(icon: const Icon(Icons.auto_graph), label: t.navLogs),
          NavigationDestination(icon: const Icon(Icons.group_outlined), label: t.navCircle),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: t.navSettings),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
