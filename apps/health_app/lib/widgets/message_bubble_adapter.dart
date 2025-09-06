import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/message_model.dart';
import 'simple_message_bubble.dart';

// Adapter widget to use SimpleMessageBubble with the old Message model
class MessageBubble extends StatelessWidget {
  final Message msg;
  final VoidCallback? onSetTask;
  final VoidCallback? onExport;
  final VoidCallback? onShare;
  
  const MessageBubble({
    super.key,
    required this.msg,
    this.onSetTask,
    this.onExport,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    // Convert old Message to new MessageModel
    final messageModel = MessageModel(
      id: msg.id,
      conversationId: 'default',
      userId: msg.fromUser ? 'user' : 'assistant',
      userName: msg.fromUser ? 'You' : 'Assistant',
      content: msg.text,
      role: msg.fromUser ? 'user' : 'assistant',
      createdAt: msg.time,
      attachments: [],
    );
    
    return Column(
      crossAxisAlignment: msg.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        SimpleMessageBubble(
          message: messageModel,
          isMe: msg.fromUser,
        ),
        
        // Action buttons if available
        if (msg.actions.isNotEmpty && !msg.fromUser)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Wrap(
              spacing: 8,
              children: msg.actions.map((action) {
                if (action == 'set_task' && onSetTask != null) {
                  return TextButton.icon(
                    onPressed: onSetTask,
                    icon: const Icon(Icons.task_alt, size: 16),
                    label: const Text('Set as Task'),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  );
                } else if (action == 'export_pdf' && onExport != null) {
                  return TextButton.icon(
                    onPressed: onExport,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Export'),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  );
                } else if (action == 'share' && onShare != null) {
                  return TextButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ),
      ],
    );
  }
}