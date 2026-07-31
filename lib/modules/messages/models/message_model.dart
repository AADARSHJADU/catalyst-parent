/// Model for a single chat message.
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String? messageType; // text | image | file
  final String? attachmentUrl;
  final String? attachmentName;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? sender;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.attachmentUrl,
    this.attachmentName,
    this.isRead = false,
    required this.createdAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    final rawSenderId = (json['senderId'] ??
            json['sender_id'] ??
            json['sender']?['id'])
        ?.toString() ??
        '';
    final rawConvId = (json['conversationId'] ?? json['conversation_id'])
            ?.toString() ??
        '';

    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: rawConvId,
      senderId: rawSenderId,
      content: json['content']?.toString() ?? json['text']?.toString() ?? '',
      messageType: json['messageType']?.toString() ??
          json['message_type']?.toString() ??
          'text',
      attachmentUrl: (json['attachmentUrl'] ?? json['attachment_url'])?.toString(),
      attachmentName: (json['attachmentName'] ?? json['attachment_name'])?.toString(),
      isRead: json['isRead'] == true || json['is_read'] == true,
      createdAt: rawCreatedAt != null
          ? DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now()
          : DateTime.now(),
      sender: json['sender'] is Map<String, dynamic>
          ? json['sender'] as Map<String, dynamic>
          : null,
    );
  }

  MessageModel copyWith({bool? isRead}) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      messageType: messageType,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      sender: sender,
    );
  }
}
