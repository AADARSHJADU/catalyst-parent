/// Model for a chat conversation (inbox entry).
class ConversationModel {
  final String id;
  final String? senderId;
  final String? receiverId;
  final String subject;
  final bool isGroup;
  final String? name;
  final String? creatorId;
  final bool isArchivedBySender;
  final bool isArchivedByReceiver;
  final String? latestMessage;
  final int unreadCount;
  final List<Map<String, dynamic>> participants;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;
  final Map<String, dynamic>? otherUser;
  final bool isArchived;
  final DateTime? updatedAt;

  const ConversationModel({
    required this.id,
    this.senderId,
    this.receiverId,
    required this.subject,
    this.isGroup = false,
    this.name,
    this.creatorId,
    this.isArchivedBySender = false,
    this.isArchivedByReceiver = false,
    this.latestMessage,
    this.unreadCount = 0,
    this.participants = const [],
    this.sender,
    this.receiver,
    this.otherUser,
    this.isArchived = false,
    this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final rawUpdatedAt = json['updatedAt'] ??
        json['updated_at'] ??
        json['lastMessageAt'] ??
        json['last_message_at'];

    // Parse latest message content safely (supports latestMessage or lastMessage object/string)
    String? latestContent;
    final rawMsg = json['latestMessage'] ?? json['lastMessage'] ?? json['last_message'];
    if (rawMsg != null) {
      if (rawMsg is Map) {
        latestContent = rawMsg['content']?.toString() ?? rawMsg['text']?.toString();
      } else {
        latestContent = rawMsg.toString();
      }
    }

    final convSenderId = (json['senderId'] ?? json['sender_id'])?.toString();
    final convReceiverId = (json['receiverId'] ?? json['receiver_id'])?.toString();
    final groupName = json['name']?.toString();

    // Determine archived status based on flags or direct parameter
    final archivedBySender =
        json['isArchivedBySender'] == true || json['is_archived_by_sender'] == true;
    final archivedByReceiver =
        json['isArchivedByReceiver'] == true || json['is_archived_by_receiver'] == true;
    final archivedValue = json['isArchived'] == true ||
        json['is_archived'] == true ||
        archivedBySender ||
        archivedByReceiver;

    Map<String, dynamic>? parsedOtherUser;
    if (json['otherUser'] is Map<String, dynamic>) {
      parsedOtherUser = json['otherUser'] as Map<String, dynamic>;
    } else if (json['other_user'] is Map<String, dynamic>) {
      parsedOtherUser = json['other_user'] as Map<String, dynamic>;
    }

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      senderId: convSenderId,
      receiverId: convReceiverId,
      subject: json['subject']?.toString() ?? groupName ?? 'Chat',
      isGroup: json['isGroup'] == true || json['is_group'] == true,
      name: groupName,
      creatorId: (json['creatorId'] ?? json['creator_id'])?.toString(),
      isArchivedBySender: archivedBySender,
      isArchivedByReceiver: archivedByReceiver,
      latestMessage: latestContent,
      unreadCount:
          (json['unreadCount'] ?? json['unread_count'] as num?)?.toInt() ?? 0,
      participants: json['participants'] != null
          ? List<Map<String, dynamic>>.from(json['participants'])
          : (json['members'] != null
              ? List<Map<String, dynamic>>.from(json['members'])
              : []),
      sender: json['sender'],
      receiver: json['receiver'],
      otherUser: parsedOtherUser,
      isArchived: archivedValue,
      updatedAt: rawUpdatedAt != null
          ? DateTime.tryParse(rawUpdatedAt.toString())
          : null,
    );
  }

  /// Returns participant name excluding the current user.
  String participantName(String? currentUserId) {
    if (isGroup && name != null && name!.isNotEmpty) {
      return name!;
    }

    // Direct match from otherUser field if returned by backend API
    if (otherUser != null) {
      final fName = otherUser!['firstName']?.toString() ?? '';
      final lName = otherUser!['lastName']?.toString() ?? '';
      final fullName = '$fName $lName'.trim();
      if (fullName.isNotEmpty) return fullName;
      if (otherUser!['name'] != null) return otherUser!['name'].toString();
    }

    // Try to get name from other participant (sender vs receiver)
    if (sender != null && senderId != currentUserId) {
      final fName = sender!['firstName']?.toString() ?? '';
      final lName = sender!['lastName']?.toString() ?? '';
      final fullName = '$fName $lName'.trim();
      if (fullName.isNotEmpty) return fullName;
      if (sender!['name'] != null) return sender!['name'].toString();
    }

    if (receiver != null && receiverId != currentUserId) {
      final fName = receiver!['firstName']?.toString() ?? '';
      final lName = receiver!['lastName']?.toString() ?? '';
      final fullName = '$fName $lName'.trim();
      if (fullName.isNotEmpty) return fullName;
      if (receiver!['name'] != null) return receiver!['name'].toString();
    }

    if (participants.isNotEmpty) {
      final other = participants.firstWhere(
        (p) => p['id']?.toString() != currentUserId,
        orElse: () => participants.first,
      );
      final fName = other['firstName']?.toString() ?? '';
      final lName = other['lastName']?.toString() ?? '';
      final fullName = '$fName $lName'.trim();
      if (fullName.isNotEmpty) return fullName;
      return other['name']?.toString() ?? subject;
    }

    return subject;
  }

  String? participantAvatar(String? currentUserId) {
    if (otherUser != null) {
      final pic = (otherUser!['profilePic'] ??
              otherUser!['profile_pic'] ??
              otherUser!['avatarUrl'])
          ?.toString();
      if (pic != null && pic.isNotEmpty) return pic;
    }

    if (sender != null && senderId != currentUserId) {
      return (sender!['profilePic'] ??
              sender!['profile_pic'] ??
              sender!['avatarUrl'])
          ?.toString();
    }
    if (receiver != null && receiverId != currentUserId) {
      return (receiver!['profilePic'] ??
              receiver!['profile_pic'] ??
              receiver!['avatarUrl'])
          ?.toString();
    }

    if (participants.isNotEmpty) {
      final other = participants.firstWhere(
        (p) => p['id']?.toString() != currentUserId,
        orElse: () => participants.first,
      );
      return (other['profilePic'] ??
              other['profile_pic'] ??
              other['avatarUrl'] ??
              other['avatar_url'])
          ?.toString();
    }
    return null;
  }
}
