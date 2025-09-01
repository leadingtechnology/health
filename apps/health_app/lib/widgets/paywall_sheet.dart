import 'package:flutter/material.dart';
import '../l10n/gen/app_localizations.dart';

Future<void> showQuotaPaywall(BuildContext context) async {
  final cs = Theme.of(context).colorScheme;
  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      final t = AppLocalizations.of(context)!;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.paywallTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(t.paywallBody),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.paywallLater),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/');
                    },
                    icon: const Icon(Icons.workspace_premium_outlined),
                    label: Text(t.paywallUpgrade),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(t.paywallFootnote, style: TextStyle(color: cs.outline)),
          ],
        ),
      );
    },
  );
}

