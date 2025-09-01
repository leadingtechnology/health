import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final plan = state.plan;
    final model = state.modelTier;
    final t = AppLocalizations.of(context)!;
    final code = state.locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final largeTextLabel = code == 'ja'
        ? '大きい文字'
        : (code == 'zh' ? '大字号' : 'Large text');

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(AppGaps.md, AppGaps.md, AppGaps.md, AppGaps.md),
      children: [
        Text(t.settingsTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppGaps.md),
        Text(t.displayTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppGaps.xs),
        const _ThemeModeSelector(),
        const SizedBox(height: AppGaps.xs),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(t.modeNormal), icon: const Icon(Icons.text_fields)),
            ButtonSegment(value: true, label: Text(largeTextLabel), icon: const Icon(Icons.format_size)),
          ],
          selected: {state.elderMode},
          onSelectionChanged: (s) => context.read<AppState>().setElderMode(s.first),
        ),
        const SizedBox(height: AppGaps.xs),
        Text(t.fontAutoNote, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
        const SizedBox(height: AppGaps.xs),
        Text(
          code == 'ja' ? 'テーマカラー' : (code == 'zh' ? '主题颜色' : 'Theme color'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppGaps.xs),
        const _SeedColorPicker(),
        const SizedBox(height: AppGaps.md),
        const Divider(height: 1),
        const SizedBox(height: AppGaps.md),
        Text(t.settingsLanguage, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppGaps.xs),
        const _LanguageSelector(),
        const SizedBox(height: AppGaps.md),
        const Divider(height: 1),
        const SizedBox(height: AppGaps.md),
        Text(t.plansTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppGaps.xs),
        _PlanCard(
          title: t.planFreeTitle,
          subtitle: t.planFreeSubtitle,
          selected: plan == Plan.free,
          onTap: () => context.read<AppState>().setPlan(Plan.free),
        ),
        _PlanCard(
          title: t.planStandardTitle,
          subtitle: t.planStandardSubtitle,
          selected: plan == Plan.standard,
          onTap: () => context.read<AppState>().setPlan(Plan.standard),
        ),
        _PlanCard(
          title: t.planProTitle,
          subtitle: t.planProSubtitle,
          selected: plan == Plan.pro,
          onTap: () => context.read<AppState>().setPlan(Plan.pro),
        ),
        const SizedBox(height: AppGaps.xs),
        SegmentedButton<ModelTier>(
          segments: [
            ButtonSegment(value: ModelTier.basic, label: Text(t.modelBasic), icon: const Icon(Icons.speed_outlined)),
            ButtonSegment(value: ModelTier.enhanced, label: Text(t.modelEnhanced), icon: const Icon(Icons.rocket_launch_outlined)),
            ButtonSegment(value: ModelTier.realtime, label: Text(t.modelRealtime), icon: const Icon(Icons.bolt)),
          ],
          selected: {model},
          onSelectionChanged: (s) => context.read<AppState>().setModelTier(s.first),
        ),
        const SizedBox(height: AppGaps.md),
        const Divider(height: 1),
        const SizedBox(height: AppGaps.md),
        Text(t.readingPrivacyTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppGaps.xs),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.privacyTitle),
          subtitle: Text(t.privacyDesc),
          trailing: const Icon(Icons.privacy_tip_outlined),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.privacyTitle)));
          },
        ),
        const SizedBox(height: AppGaps.xs),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.aboutTitle),
          subtitle: Text(t.aboutDesc),
          trailing: const Icon(Icons.info_outline),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _PlanCard({required this.title, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: selected ? 1 : 0,
      color: selected ? cs.primaryContainer : null,
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? cs.onPrimaryContainer : null)),
        subtitle: Text(subtitle, style: TextStyle(color: selected ? cs.onPrimaryContainer.withValues(alpha: .9) : null)),
        trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
        onTap: onTap,
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final selected = state.themeMode;
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
        ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
        ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.phone_iphone)),
      ],
      selected: {selected},
      onSelectionChanged: (s) => context.read<AppState>().setThemeMode(s.first),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    String current = 'system';
    if (state.locale?.languageCode == 'en') current = 'en';
    if (state.locale?.languageCode == 'zh') current = 'zh';
    if (state.locale?.languageCode == 'ja') current = 'ja';

    const items = [
      DropdownMenuItem(value: 'system', child: Text('System default')),
      DropdownMenuItem(value: 'en', child: Text('English')),
      DropdownMenuItem(value: 'zh', child: Text('简体中文')),
      DropdownMenuItem(value: 'ja', child: Text('日本語')),
    ];

    return DropdownButtonFormField<String>(
      value: current,
      isExpanded: true,
      items: items,
      onChanged: (v) => context.read<AppState>().setLocaleCode(v!),
    );
  }
}

class _SeedColorPicker extends StatelessWidget {
  const _SeedColorPicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final current = Color(state.seedColor);
    const List<Color> seeds = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lime,
      Colors.orange,
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final c in seeds)
          GestureDetector(
            onTap: () => context.read<AppState>().setSeedColor(c),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                ],
                border: Border.all(
                  color: current.toARGB32() == c.toARGB32() ? Theme.of(context).colorScheme.onPrimaryContainer : Colors.transparent,
                  width: 2,
                ),
              ),
              child: current.toARGB32() == c.toARGB32()
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
      ],
    );
  }
}
