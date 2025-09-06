class MessageModel {
  final String id;
  final String conversationId;
  final String userId;
  final String? userName;
  final String content;
  final String role; // 'user', 'assistant', 'system'
  final DateTime createdAt;
  final List<AttachmentModel> attachments;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.userId,
    this.userName,
    required this.content,
    required this.role,
    required this.createdAt,
    this.attachments = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      userId: json['userId'],
      userName: json['userName'],
      content: json['content'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      attachments: (json['attachments'] as List?)
          ?.map((a) => AttachmentModel.fromJson(a))
          .toList() ?? [],
    );
  }
}

class AttachmentModel {
  final String id;
  final String fileName;
  final String fileType; // 'image', 'audio', 'document'
  final String contentType;
  final String url;
  final String? thumbnailUrl;
  final int? duration;
  final String? transcription;
  final int fileSize;

  AttachmentModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.contentType,
    required this.url,
    this.thumbnailUrl,
    this.duration,
    this.transcription,
    required this.fileSize,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      contentType: json['contentType'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      transcription: json['transcription'],
      fileSize: json['fileSize'],
    );
  }
}