import 'package:catalyst/data/models/student_attendance_model.dart';
import 'package:catalyst/data/models/student_evaluation_model.dart';
import 'package:catalyst/data/models/student_feedback_model.dart';
import 'package:catalyst/data/models/student_model.dart';
import 'package:catalyst/data/services/student_progress_service.dart';
import 'package:get/get.dart';

class StudentProgressController extends GetxController {
  final _service = StudentProgressService();

  // ── Students list ──────────────────────────────────────────────────────────
  final students = <StudentModel>[].obs;
  final selectedStudent = Rxn<StudentModel>();

  // ── Data ───────────────────────────────────────────────────────────────────
  final evaluations = <StudentEvaluationModel>[].obs;
  final feedbackList = <StudentFeedbackModel>[].obs;
  final attendanceRecords = <StudentAttendanceModel>[].obs;

  // ── State ──────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final isDataLoading = false.obs;
  final errorMessage = ''.obs;

  // ── Computed values ────────────────────────────────────────────────────────

  /// Overall score from latest evaluation (average of 6 skills).
  double get overallScore {
    if (evaluations.isEmpty) return 0;
    return evaluations.first.overallScore;
  }

  /// Skill breakdown from latest evaluation (0–1 scale for progress bars).
  Map<String, double> get skillBreakdown {
    if (evaluations.isEmpty) return {};
    final e = evaluations.first;
    return {
      'Technique': e.technique / 100.0,
      'Turns': e.turns / 100.0,
      'Leaps': e.leaps / 100.0,
      'Flexibility': e.flexibility / 100.0,
      'Rhythm': e.rhythm / 100.0,
      'Performance': e.performance / 100.0,
    };
  }

  /// Chronological data points for the progress line chart.
  List<Map<String, dynamic>> get progressTrend {
    if (evaluations.isEmpty) return [];
    // Sort oldest first
    final sorted = [...evaluations]
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.map((e) {
      return {
        'label': e.term ?? e.date,
        'value': e.overallScore / 100.0,
      };
    }).toList();
  }

  /// Attendance percentage.
  double get attendanceRate {
    if (attendanceRecords.isEmpty) return 0;
    final present = attendanceRecords
        .where((a) => a.status == 'Present' || a.status == 'Late')
        .length;
    return (present / attendanceRecords.length) * 100;
  }

  int get totalClasses => attendanceRecords.length;

  int get presentCount =>
      attendanceRecords.where((a) => a.status == 'Present').length;
  int get lateCount =>
      attendanceRecords.where((a) => a.status == 'Late').length;
  int get absentCount =>
      attendanceRecords.where((a) => a.status == 'Absent').length;
  int get excusedCount =>
      attendanceRecords.where((a) => a.status == 'Excused').length;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _service.getStudents();
      students.value =
          data.map((json) => StudentModel.fromJson(json)).toList();

      if (students.isNotEmpty) {
        selectedStudent.value = students.first;
        await _loadStudentData(students.first.id);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Called when parent picks a different student from dropdown.
  Future<void> selectStudent(StudentModel student) async {
    selectedStudent.value = student;
    await _loadStudentData(student.id);
  }

  Future<void> _loadStudentData(int studentId) async {
    try {
      isDataLoading.value = true;
      errorMessage.value = '';

      final results = await Future.wait([
        _service.getEvaluations(studentId),
        _service.getFeedback(studentId),
        _service.getAttendance(studentId),
      ]);

      evaluations.value = results[0] as List<StudentEvaluationModel>;
      feedbackList.value = results[1] as List<StudentFeedbackModel>;
      attendanceRecords.value =
          results[2] as List<StudentAttendanceModel>;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isDataLoading.value = false;
    }
  }

  /// Pull-to-refresh support.
  Future<void> refreshData() async {
    if (selectedStudent.value != null) {
      await _loadStudentData(selectedStudent.value!.id);
    }
  }
}
