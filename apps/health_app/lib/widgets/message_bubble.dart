import 'package:flutter/material.dart';
import '../models/models.dart';
import '../l10n/gen/app_localizations.dart';

class MessageBubble extends StatelessWidget {
  final Message msg;
  final VoidCallback? onSetTask;
  final VoidCallback? onExport;
  final VoidCallback? onShare;
  const MessageBubble({super.key, required this.msg, this.onSetTask, this.onExport, this.onShare});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final align = msg.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = msg.fromUser ? cs.primaryContainer : cs.surfaceContainerHighest;
    final textColor = msg.fromUser ? cs.onPrimaryContainer : cs.onSurfaceVariant;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 680),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(msg.text, style: TextStyle(color: textColor, height: 1.35)),
        ),
        if (!msg.fromUser && msg.actions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              children: [
                if (msg.actions.contains('set_task'))
                  ActionChip(label: Text(AppLocalizations.of(context)!.actionSetTask), avatar: const Icon(Icons.add_task, size: 18), onPressed: onSetTask),
                if (msg.actions.contains('export_pdf'))
                  ActionChip(label: Text(AppLocalizations.of(context)!.actionExportPdf), avatar: const Icon(Icons.picture_as_pdf, size: 18), onPressed: onExport),
                if (msg.actions.contains('share'))
                  ActionChip(label: Text(AppLocalizations.of(context)!.actionShare), avatar: const Icon(Icons.share, size: 18), onPressed: onShare),
              ],
            ),
          ),
      ],
    );
  }
}
