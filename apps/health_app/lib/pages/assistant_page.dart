import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/quota_badge.dart';
import '../widgets/model_badge.dart';
import '../widgets/message_bubble.dart';
import '../widgets/paywall_sheet.dart';
import '../theme/app_theme.dart';
import '../l10n/gen/app_localizations.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final msgs = state.messages.reversed.toList();
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(AppGaps.md, AppGaps.xs, AppGaps.md, 0),
          child: Row(
            children: const [
              QuotaBadge(),
              SizedBox(width: AppGaps.xs),
              ModelBadge(),
              Spacer(),
            ],
          ),
        ),
        const SizedBox(height: AppGaps.xs),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            reverse: true,
            padding: const EdgeInsetsDirectional.fromSTEB(AppGaps.md, AppGaps.xs, AppGaps.md, AppGaps.xs),
            itemCount: msgs.length,
            itemBuilder: (context, i) {
              final m = msgs[i];
              return MessageBubble(
                msg: m,
                onSetTask: () {
                  context.read<AppState>().addTaskFromSuggestion('');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.taskAdded)));
                },
                onExport: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.exportPrepared)));
                },
                onShare: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.sharePrepared)));
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AppGaps.sm, AppGaps.xs, AppGaps.sm, AppGaps.sm),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.add_a_photo_outlined)),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: t.chatInputHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppGaps.xs),
                GestureDetector(
                  onLongPress: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.voiceHoldToTalk)));
                  },
                  onLongPressUp: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.voiceReleaseToSend)));
                  },
                  child: const CircleAvatar(child: Icon(Icons.mic_none)),
                ),
                const SizedBox(width: AppGaps.xs),
                FilledButton(
                  onPressed: () async {
                    final text = _ctrl.text.trim();
                    if (text.isEmpty) return;

                    final okToAsk = context.read<AppState>().canAskNow;
                    if (!okToAsk) {
                      await showQuotaPaywall(context);
                      return;
                    }
                    _ctrl.clear();
                    final res = await context.read<AppState>().ask(text);
                    if (res == AskResult.limited) {
                      await showQuotaPaywall(context);
                    } else {
                      _scroll.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
                    }
                  },
                  child: Text(t.send),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
