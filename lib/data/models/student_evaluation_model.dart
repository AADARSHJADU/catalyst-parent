/// Model representing a term evaluation for a student.
class StudentEvaluationModel {
  const StudentEvaluationModel({
    required this.id,
    required this.studentId,
    required this.instructorId,
    required this.date,
    this.term,
    this.technique = 0,
    this.turns = 0,
    this.leaps = 0,
    this.flexibility = 0,
    this.rhythm = 0,
    this.performance = 0,
    this.strengths,
    this.areasToImprove,
    this.comments,
    this.goals,
    this.instructor,
    this.createdAt,
  });

  final int id;
  final int studentId;
  final int instructorId;
  final String date;
  final String? term;
  final int technique;
  final int turns;
  final int leaps;
  final int flexibility;
  final int rhythm;
  final int performance;
  final String? strengths;
  final String? areasToImprove;
  final String? comments;
  final String? goals;
  final EvaluationInstructor? instructor;
  final String? createdAt;

  /// Average of all 6 skill scores (0–100).
  double get overallScore =>
      (technique + turns + leaps + flexibility + rhythm + performance) / 6.0;

  factory StudentEvaluationModel.fromJson(Map<String, dynamic> json) {
    return StudentEvaluationModel(
      id: json['id'] as int,
      studentId: json['studentId'] as int? ?? 0,
      instructorId: json['instructorId'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      term: json['term'] as String?,
      technique: json['technique'] as int? ?? 0,
      turns: json['turns'] as int? ?? 0,
      leaps: json['leaps'] as int? ?? 0,
      flexibility: json['flexibility'] as int? ?? 0,
      rhythm: json['rhythm'] as int? ?? 0,
      performance: json['performance'] as int? ?? 0,
      strengths: json['strengths'] as String?,
      areasToImprove: json['areasToImprove'] as String?,
      comments: json['comments'] as String?,
      goals: json['goals'] as String?,
      instructor: json['instructor'] != null
          ? EvaluationInstructor.fromJson(
              json['instructor'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class EvaluationInstructor {
  const EvaluationInstructor({
    required this.id,
    this.userId,
    this.user,
  });

  final int id;
  final int? userId;
  final EvaluationUser? user;

  String get fullName => user != null
      ? '${user!.firstName} ${user!.lastName}'.trim()
      : 'Instructor';

  String? get profilePic => user?.profilePic;

  factory EvaluationInstructor.fromJson(Map<String, dynamic> json) {
    return EvaluationInstructor(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      user: json['user'] != null
          ? EvaluationUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EvaluationUser {
  const EvaluationUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePic,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String? profilePic;

  factory EvaluationUser.fromJson(Map<String, dynamic> json) {
    return EvaluationUser(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      profilePic: json['profilePic'] as String?,
    );
  }
}
