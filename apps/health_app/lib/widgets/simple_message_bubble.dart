import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message_model.dart';

class SimpleMessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  
  const SimpleMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: message.role == 'assistant'
                  ? const Icon(Icons.smart_toy, size: 20, color: Colors.white)
                  : Text(
                      message.userName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image attachments
                  if (message.attachments.isNotEmpty)
                    ...message.attachments.where((a) => a.fileType == 'image').map((attachment) {
                      // Check if it's a local file or network URL
                      final isLocal = !attachment.url.startsWith('http');
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isLocal
                              ? Image.file(
                                  File(attachment.url),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      color: theme.colorScheme.surface,
                                      child: const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                    );
                                  },
                                )
                              : CachedNetworkImage(
                                  imageUrl: attachment.url,
                                  placeholder: (context, url) => Container(
                                    height: 150,
                                    color: theme.colorScheme.surface,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 150,
                                    color: theme.colorScheme.surface,
                                    child: const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                        ),
                      );
                    }).toList(),
                  
                  // Text content
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe 
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  
                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? theme.colorScheme.onPrimary.withAlpha(178)
                            : theme.colorScheme.onSurfaceVariant.withAlpha(178),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}