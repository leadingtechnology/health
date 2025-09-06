import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/quota_badge.dart';
import '../widgets/model_badge.dart';
import '../widgets/message_bubble_adapter.dart';
import '../widgets/paywall_sheet.dart';
import '../widgets/common_widgets.dart';
import '../widgets/simple_chat_input.dart';
import 'dart:io';
import '../l10n/gen/app_localizations.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() {
        _isTyping = _ctrl.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final msgs = state.messages.reversed.toList();
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header with badges
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // AI Assistant Avatar
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Assistant',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          QuotaBadge(),
                          SizedBox(width: 8),
                          ModelBadge(),
                        ],
                      ),
                    ],
                  ),
                ),
                // Settings button
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Show assistant settings
                  },
                ),
              ],
            ),
          ),
          
          // Messages list
          Expanded(
            child: msgs.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: t.welcomeMessage,
                    description: 'Ask me anything about your health',
                    action: FilledButton.icon(
                      onPressed: () {
                        _focusNode.requestFocus();
                      },
                      icon: const Icon(Icons.waving_hand),
                      label: const Text('Start Conversation'),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: msgs.length,
                    itemBuilder: (context, i) {
                      final m = msgs[i];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: MessageBubble(
                          msg: m,
                          onSetTask: () {
                            context.read<AppState>().addTaskFromSuggestion('');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t.taskAdded),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          onExport: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t.exportPrepared),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          onShare: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t.sharePrepared),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          
          // Input area
          // Multimedia chat input
          SimpleChatInput(
            onSendMessage: _sendMessageWithAttachments,
            enabled: !loading,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessageWithAttachments(String text, List<File> attachments) async {
    if (text.isEmpty && attachments.isEmpty) return;

    final okToAsk = context.read<AppState>().canAskNow;
    if (!okToAsk) {
      await showQuotaPaywall(context);
      return;
    }
    
    setState(() {
      loading = true;
    });
    
    try {
      // Call the enhanced ask method with attachments
      final res = await context.read<AppState>().askWithAttachments(text, attachments);
      
      if (res == AskResult.limited) {
        await showQuotaPaywall(context);
      } else {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }
  
  // Keep the old method for backward compatibility
  Future<void> _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    await _sendMessageWithAttachments(text, []);
  }
}