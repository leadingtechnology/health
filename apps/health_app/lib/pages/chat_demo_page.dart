import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/simple_chat_input.dart';
import '../widgets/simple_message_bubble.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

class ChatDemoPage extends StatefulWidget {
  const ChatDemoPage({super.key});

  @override
  State<ChatDemoPage> createState() => _ChatDemoPageState();
}

class _ChatDemoPageState extends State<ChatDemoPage> {
  final List<MessageModel> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadInitialMessage();
  }

  void _loadInitialMessage() {
    // Add a welcome message
    setState(() {
      _messages.add(MessageModel(
        id: '1',
        conversationId: 'demo',
        userId: 'assistant',
        userName: 'Health Assistant',
        content: 'Hello! I can help you with health-related questions. You can send text messages, images, or voice recordings.',
        role: 'assistant',
        createdAt: DateTime.now(),
        attachments: [],
      ));
    });
  }

  Future<void> _sendMessage(String text, List<File> attachments) async {
    if (text.isEmpty && attachments.isEmpty) return;

    // Create user message
    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: 'demo',
      userId: 'user',
      userName: 'You',
      content: text,
      role: 'user',
      createdAt: DateTime.now(),
      attachments: attachments.map((file) {
        final isImage = file.path.toLowerCase().endsWith('.jpg') || 
                       file.path.toLowerCase().endsWith('.jpeg') || 
                       file.path.toLowerCase().endsWith('.png');
        final isAudio = file.path.toLowerCase().endsWith('.m4a') || 
                       file.path.toLowerCase().endsWith('.mp3');
        
        return AttachmentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fileName: file.path.split('/').last,
          fileType: isImage ? 'image' : isAudio ? 'audio' : 'document',
          contentType: isImage ? 'image/jpeg' : isAudio ? 'audio/mp4' : 'application/octet-stream',
          url: file.path, // Local path for now
          fileSize: file.lengthSync(),
        );
      }).toList(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    // Send to API (if authenticated)
    try {
      if (_apiService.isAuthenticated) {
        // TODO: Implement actual API call with file upload
        // For now, just simulate a response
        await Future.delayed(const Duration(seconds: 2));
      } else {
        // Simulate response for demo
        await Future.delayed(const Duration(seconds: 1));
      }

      // Add AI response
      final aiResponse = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: 'demo',
        userId: 'assistant',
        userName: 'Health Assistant',
        content: _generateDemoResponse(text, attachments),
        role: 'assistant',
        createdAt: DateTime.now(),
        attachments: [],
      );

      setState(() {
        _messages.add(aiResponse);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _generateDemoResponse(String text, List<File> attachments) {
    if (attachments.isNotEmpty) {
      final imageCount = attachments.where((f) => 
        f.path.toLowerCase().endsWith('.jpg') || 
        f.path.toLowerCase().endsWith('.jpeg') || 
        f.path.toLowerCase().endsWith('.png')
      ).length;
      
      final audioCount = attachments.where((f) => 
        f.path.toLowerCase().endsWith('.m4a') || 
        f.path.toLowerCase().endsWith('.mp3')
      ).length;

      String response = "I've received ";
      if (imageCount > 0) {
        response += "$imageCount image${imageCount > 1 ? 's' : ''}";
      }
      if (audioCount > 0) {
        if (imageCount > 0) response += " and ";
        response += "$audioCount audio recording${audioCount > 1 ? 's' : ''}";
      }
      response += ". ";
      
      if (text.isNotEmpty) {
        response += "Regarding your message: \"$text\" - ";
      }
      
      response += "I'll analyze this and provide you with relevant health information. Is there anything specific you'd like to know?";
      return response;
    } else if (text.toLowerCase().contains('headache')) {
      return "For headaches, ensure you're well-hydrated and have had enough rest. If headaches persist or are severe, please consult with a healthcare professional.";
    } else if (text.toLowerCase().contains('fever')) {
      return "For fever management, rest and stay hydrated. Monitor your temperature regularly. Seek medical attention if the fever is above 103°F (39.4°C) or persists for more than 3 days.";
    } else if (text.toLowerCase().contains('diet') || text.toLowerCase().contains('nutrition')) {
      return "A balanced diet includes fruits, vegetables, whole grains, lean proteins, and healthy fats. Would you like specific dietary recommendations?";
    } else {
      return "I understand you're asking about: \"$text\". Could you provide more details so I can give you more specific health guidance?";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Chat'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'AI is thinking...',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final message = _messages[index];
                return SimpleMessageBubble(
                  message: message,
                  isMe: message.role == 'user',
                );
              },
            ),
          ),
          
          // Input widget
          SimpleChatInput(
            onSendMessage: _sendMessage,
            enabled: !_isLoading,
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}