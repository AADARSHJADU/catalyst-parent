/// Model for a user that can be messaged (from /messages/users endpoint).
class ChatUserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  const ChatUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    // Map firstName + lastName to name, or fallback to name
    String finalName = json['name']?.toString() ?? '';
    if (finalName.isEmpty) {
      final fName = json['firstName']?.toString() ?? '';
      final lName = json['lastName']?.toString() ?? '';
      finalName = '$fName $lName'.trim();
    }
    if (finalName.isEmpty) {
      finalName = 'User ${json['id']}';
    }

    // Extract role from roles array or direct field
    String finalRole = json['role']?.toString() ?? '';
    if (finalRole.isEmpty && json['roles'] is List) {
      final List rolesList = json['roles'];
      if (rolesList.isNotEmpty && rolesList.first is Map) {
        finalRole = rolesList.first['name']?.toString() ?? '';
      }
    }

    return ChatUserModel(
      id: json['id']?.toString() ?? '',
      name: finalName,
      email: json['email']?.toString() ?? '',
      role: finalRole,
      avatarUrl: json['profilePic']?.toString() ?? json['avatarUrl']?.toString(),
    );
  }

  /// Returns initials (first letter of first + last name).
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
