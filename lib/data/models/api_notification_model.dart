/// Model representing a single notification from the API.
/// API returns title/message inside the `payload` object.
class ApiNotificationModel {
  const ApiNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.path,
    this.isRead = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String message;
  final String type;
  final String? path;
  final bool isRead;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;

  /// Categorize notification for UI tabs
  String get category {
    final t = type.toLowerCase();
    final titleLower = title.toLowerCase();
    if (t.contains('billing') || t.contains('payment') ||
        titleLower.contains('payment') || titleLower.contains('billing')) {
      return 'Billing';
    }
    if (t.contains('booking') || t.contains('class') ||
        t.contains('schedule') || titleLower.contains('booking') ||
        titleLower.contains('reschedul')) {
      return 'Bookings';
    }
    if (t.contains('announcement') || titleLower.contains('announc')) {
      return 'Announcements';
    }
    return 'Studio Updates';
  }

  factory ApiNotificationModel.fromJson(Map<String, dynamic> json) {
    // title and message can be at root level OR inside payload
    final payload = json['payload'] as Map<String, dynamic>?;

    final title = json['title'] as String? ??
        payload?['title'] as String? ??
        '';
    final message = json['message'] as String? ??
        payload?['message'] as String? ??
        '';
    final type = json['type'] as String? ??
        payload?['type'] as String? ??
        'general';
    final path = json['path'] as String? ??
        payload?['path'] as String?;

    return ApiNotificationModel(
      id: json['id'] as int,
      title: title,
      message: message,
      type: type,
      path: path,
      isRead: json['isRead'] as bool? ?? false,
      userId: json['userId'] as int?,
      createdAt: json['created_at'] as String? ??
          json['createdAt'] as String?,
      updatedAt: json['updated_at'] as String? ??
          json['updatedAt'] as String?,
    );
  }

  ApiNotificationModel copyWith({bool? isRead}) {
    return ApiNotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      path: path,
      isRead: isRead ?? this.isRead,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
