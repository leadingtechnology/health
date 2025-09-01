import 'package:flutter/material.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(AppGaps.md, AppGaps.md, AppGaps.md, AppGaps.md),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppGaps.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.logsQuickActions, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppGaps.xs),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.logsLike)));
                  },
                  icon: const Icon(Icons.favorite),
                  label: Text(t.logsLike),
                ),
                const SizedBox(height: AppGaps.xxs),
                Text(t.logsLikeNote, style: TextStyle(color: cs.outline)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppGaps.sm),
        Row(
          children: [
            Expanded(child: _StatCard(title: t.stepsTitle, value: '5,124', note: t.stepsNote)),
            const SizedBox(width: AppGaps.sm),
            Expanded(child: _StatCard(title: t.sleepTitle, value: '7.2h', note: t.sleepNote)),
          ],
        ),
        const SizedBox(height: AppGaps.sm),
        Row(
          children: [
            Expanded(child: _StatCard(title: t.bpTitle, value: '128/79', note: t.bpNote)),
            const SizedBox(width: AppGaps.sm),
            Expanded(child: _StatCard(title: t.hrTitle, value: '72', note: t.hrNote)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String note;

  const _StatCard({required this.title, required this.value, required this.note});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGaps.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppGaps.xs),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppGaps.xxs),
          Text(note, style: TextStyle(color: cs.outline)),
        ]),
      ),
    );
  }
}
