/// Model representing a single announcement from the API.
class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    this.priority = 'normal',
    this.status = 'published',
    this.publishAt,
    this.expiresAt,
    this.creatorName = 'Studio Administration',
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String priority;
  final String status;
  final String? publishAt;
  final String? expiresAt;
  final String creatorName;
  final String? createdAt;

  bool get isUrgent =>
      priority.toLowerCase() == 'urgent' ||
      priority.toLowerCase() == 'high';

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'] as Map<String, dynamic>?;
    final firstName = creator?['firstName'] as String? ?? '';
    final lastName = creator?['lastName'] as String? ?? '';
    final authorName = '$firstName $lastName'.trim();

    return AnnouncementModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      priority: json['priority'] as String? ?? 'normal',
      status: json['status'] as String? ?? 'published',
      publishAt: json['publishAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      creatorName:
          authorName.isNotEmpty ? authorName : 'Studio Administration',
      createdAt: json['createdAt'] as String? ??
          json['created_at'] as String?,
    );
  }
}
