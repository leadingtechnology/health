import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../l10n/gen/app_localizations.dart';

class QuotaBadge extends StatelessWidget {
  const QuotaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
    final String label = state.isFreePlan
        ? t.quotaRemaining(state.dailyLimitFree - state.usedToday, state.dailyLimitFree)
        : t.quotaUnlimited;
    final Color bg = state.isFreePlan ? cs.surfaceContainerHighest : cs.secondaryContainer;
    final Color fg = state.isFreePlan ? cs.onSurfaceVariant : cs.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(state.isFreePlan ? Icons.timer_outlined : Icons.all_inclusive, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
