import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../l10n/gen/app_localizations.dart';

class ModelBadge extends StatelessWidget {
  const ModelBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = AppLocalizations.of(context)!;
    final map = {
      ModelTier.basic: t.modelBasic,
      ModelTier.enhanced: t.modelEnhanced,
      ModelTier.realtime: t.modelRealtime,
    };
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 16),
          const SizedBox(width: 6),
          Text(map[state.modelTier]!, style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

