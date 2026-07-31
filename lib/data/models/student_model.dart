/// Model representing a student/child from the API.
class StudentModel {
  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    this.email,
    this.mobileNumber,
    this.emergencyContact1,
    this.emergencyContact2,
    this.medicalNotes,
    this.notes,
    this.studentCode,
    this.status = true,
    this.enrollmentDate,
    this.profilePicture,
    this.ageGroupId,
    this.levelId,
    this.studioId,
    this.danceStyles = const [],
    this.ageGroup,
    this.level,
    this.studio,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? email;
  final String? mobileNumber;
  final String? emergencyContact1;
  final String? emergencyContact2;
  final String? medicalNotes;
  final String? notes;
  final String? studentCode;
  final bool status;
  final String? enrollmentDate;
  final String? profilePicture;
  final int? ageGroupId;
  final int? levelId;
  final int? studioId;
  final List<StudentDanceStyle> danceStyles;
  final StudentLookup? ageGroup;
  final StudentLookup? level;
  final StudentStudio? studio;
  final String? createdAt;
  final String? updatedAt;

  String get fullName => '$firstName $lastName';

  String get dobFormatted {
    if (dateOfBirth == null || dateOfBirth!.isEmpty) return '';
    return dateOfBirth!.split('T').first;
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final styles = json['danceStyles'] as List<dynamic>? ?? [];
    return StudentModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      email: json['email'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      emergencyContact1: json['emergencyContact1'] as String?,
      emergencyContact2: json['emergencyContact2'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      notes: json['notes'] as String?,
      studentCode: json['studentCode'] as String?,
      status: json['status'] as bool? ?? true,
      enrollmentDate: json['enrollmentDate'] as String?,
      profilePicture: json['profilePicture'] as String?,
      ageGroupId: json['ageGroupId'] as int?,
      levelId: json['levelId'] as int?,
      studioId: json['studioId'] as int?,
      danceStyles: styles
          .map((e) =>
              StudentDanceStyle.fromJson(e as Map<String, dynamic>))
          .toList(),
      ageGroup: json['ageGroup'] != null
          ? StudentLookup.fromJson(
              json['ageGroup'] as Map<String, dynamic>)
          : null,
      level: json['level'] != null
          ? StudentLookup.fromJson(
              json['level'] as Map<String, dynamic>)
          : null,
      studio: json['studio'] != null
          ? StudentStudio.fromJson(
              json['studio'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
    );
  }
}

class StudentDanceStyle {
  const StudentDanceStyle({required this.id, required this.name, this.description});
  final int id;
  final String name;
  final String? description;

  factory StudentDanceStyle.fromJson(Map<String, dynamic> json) {
    return StudentDanceStyle(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class StudentLookup {
  const StudentLookup({required this.id, required this.name, this.description});
  final int id;
  final String name;
  final String? description;

  factory StudentLookup.fromJson(Map<String, dynamic> json) {
    return StudentLookup(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class StudentStudio {
  const StudentStudio({required this.id, required this.name});
  final int id;
  final String name;

  factory StudentStudio.fromJson(Map<String, dynamic> json) {
    return StudentStudio(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}
