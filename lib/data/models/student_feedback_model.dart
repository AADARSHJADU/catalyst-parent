/// Model representing teacher feedback / instructor notes for a student.
class StudentFeedbackModel {
  const StudentFeedbackModel({
    required this.id,
    required this.type,
    required this.date,
    this.summary,
    this.notesToParent,
    this.sharedWithParent = true,
    this.instructor,
  });

  final dynamic id; // Can be int or String (e.g. "sn-88")
  final String type;
  final String date;
  final String? summary;
  final String? notesToParent;
  final bool sharedWithParent;
  final FeedbackInstructor? instructor;

  factory StudentFeedbackModel.fromJson(Map<String, dynamic> json) {
    return StudentFeedbackModel(
      id: json['id'],
      type: json['type'] as String? ?? 'Note',
      date: json['date'] as String? ?? '',
      summary: json['summary'] as String?,
      notesToParent: json['notesToParent'] as String?,
      sharedWithParent: json['sharedWithParent'] as bool? ?? true,
      instructor: json['instructor'] != null
          ? FeedbackInstructor.fromJson(
              json['instructor'] as Map<String, dynamic>)
          : null,
    );
  }
}

class FeedbackInstructor {
  const FeedbackInstructor({this.user});
  final FeedbackUser? user;

  String get fullName => user != null
      ? '${user!.firstName} ${user!.lastName}'.trim()
      : 'Instructor';

  String? get profilePic => user?.profilePic;

  factory FeedbackInstructor.fromJson(Map<String, dynamic> json) {
    return FeedbackInstructor(
      user: json['user'] != null
          ? FeedbackUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class FeedbackUser {
  const FeedbackUser({
    required this.firstName,
    required this.lastName,
    this.profilePic,
  });

  final String firstName;
  final String lastName;
  final String? profilePic;

  factory FeedbackUser.fromJson(Map<String, dynamic> json) {
    return FeedbackUser(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      profilePic: json['profilePic'] as String?,
    );
  }
}
