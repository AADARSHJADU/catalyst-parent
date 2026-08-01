/// Model representing a single attendance record for a student.
class StudentAttendanceModel {
  const StudentAttendanceModel({
    required this.id,
    this.sessionId,
    this.studentId,
    this.classType,
    required this.status,
    this.markedAt,
    this.notes,
    this.session,
  });

  final int id;
  final int? sessionId;
  final int? studentId;
  final String? classType;
  final String status; // Present, Late, Absent, Excused
  final String? markedAt;
  final String? notes;
  final AttendanceSession? session;

  factory StudentAttendanceModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceModel(
      id: json['id'] as int,
      sessionId: json['sessionId'] as int?,
      studentId: json['studentId'] as int?,
      classType: json['classType'] as String?,
      status: json['status'] as String? ?? 'Absent',
      markedAt: json['markedAt'] as String?,
      notes: json['notes'] as String?,
      session: json['session'] != null
          ? AttendanceSession.fromJson(
              json['session'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AttendanceSession {
  const AttendanceSession({
    required this.id,
    this.classId,
    this.classType,
    this.sessionDate,
    this.startTime,
    this.endTime,
  });

  final int id;
  final int? classId;
  final String? classType;
  final String? sessionDate;
  final String? startTime;
  final String? endTime;

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] as int,
      classId: json['class_id'] as int?,
      classType: json['class_type'] as String?,
      sessionDate: json['session_date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );
  }
}
