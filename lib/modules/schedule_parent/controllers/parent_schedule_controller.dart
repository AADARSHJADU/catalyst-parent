import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/services/schedule_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ParentScheduleController extends GetxController {
  final ScheduleApiService _service = Get.find<ScheduleApiService>();

  // ── State ──────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // ── Raw data ───────────────────────────────────────────────────────────
  final regularEnrollments = <Map<String, dynamic>>[].obs;
  final privateLessons = <Map<String, dynamic>>[].obs;
  final routines = <Map<String, dynamic>>[].obs;
  final completedSessions = <Map<String, dynamic>>[].obs;
  final wellnessClasses = <Map<String, dynamic>>[].obs;
  final choreographies = <Map<String, dynamic>>[].obs;
  final students = <Map<String, dynamic>>[].obs;
  final studios = <Map<String, dynamic>>[].obs;

  // ── Filters ────────────────────────────────────────────────────────────
  final selectedDate = DateTime.now().obs;
  final selectedStudentId = 'All'.obs;
  final selectedStudioId = 'All'.obs;
  final activeTab = 0.obs; // 0=classes,1=private,2=wellness,3=choreography,4=routines

  final tabLabels = const ['Classes', 'Private', 'Wellness', 'Choreography', 'Routines'];

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        _service.getMyEnrollments(),
        _service.getWellnessSchedule(),
        _service.getStudents(),
        _service.getStudios(),
      ]);

      final enrollData = results[0] as Map<String, dynamic>;
      regularEnrollments.value = List<Map<String, dynamic>>.from(
          enrollData['regular'] ?? []);
      privateLessons.value = List<Map<String, dynamic>>.from(
          enrollData['privateLessons'] ?? []);
      routines.value = List<Map<String, dynamic>>.from(
          enrollData['routines'] ?? []);
      choreographies.value = List<Map<String, dynamic>>.from(
          enrollData['choreography'] ?? []);
      completedSessions.value = List<Map<String, dynamic>>.from(
          enrollData['completedSessions'] ?? []);

      wellnessClasses.value = results[1] as List<Map<String, dynamic>>;
      students.value = results[2] as List<Map<String, dynamic>>;
      studios.value = results[3] as List<Map<String, dynamic>>;

      print('📅 [SCHEDULE] Loaded: regular=${regularEnrollments.length} private=${privateLessons.length} wellness=${wellnessClasses.length} choreo=${choreographies.length} routines=${routines.length}');
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Failed to load schedule.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => _loadAll();

  // ── Date helpers ───────────────────────────────────────────────────────
  void goToday() => selectedDate.value = DateTime.now();
  void prevDay() => selectedDate.value =
      selectedDate.value.subtract(const Duration(days: 1));
  void nextDay() => selectedDate.value =
      selectedDate.value.add(const Duration(days: 1));
  void setDate(DateTime d) => selectedDate.value = d;

  String get dateLabel => DateFormat('EEEE, MMM d').format(selectedDate.value);

  List<DateTime> get weekDays {
    final now = selectedDate.value;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  // ── Filtered items per tab ─────────────────────────────────────────────
  List<Map<String, dynamic>> get filteredItems {
    switch (activeTab.value) {
      case 0: return _filterClasses();
      case 1: return _filterPrivate();
      case 2: return _filterWellness();
      case 3: return _filterChoreography();
      case 4: return _filterRoutines();
      default: return [];
    }
  }

  // ── Classes filter ─────────────────────────────────────────────────────
  List<Map<String, dynamic>> _filterClasses() {
    final date = selectedDate.value;
    final weekday = DateFormat('EEEE').format(date).toLowerCase();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    if (regularEnrollments.isEmpty) return [];

    final results = <Map<String, dynamic>>[];
    for (final e in regularEnrollments) {
      // Student filter
      if (selectedStudentId.value != 'All') {
        if (e['studentId']?.toString() != selectedStudentId.value) continue;
      }
      // Studio filter
      if (selectedStudioId.value != 'All') {
        final cls = e['class'] as Map<String, dynamic>? ?? {};
        final studioId = cls['room']?['studio']?['id']?.toString() ?? '';
        if (studioId != selectedStudioId.value) continue;
      }

      // Schedule match — check if class runs on this weekday
      final cls = e['class'] as Map<String, dynamic>? ?? {};
      final schedules = cls['schedules'] as List? ?? [];

      bool matchesDay = false;
      if (schedules.isEmpty) {
        // No schedule data — show the class anyway (don't filter out)
        matchesDay = true;
      } else {
        for (final s in schedules) {
          final sMap = s as Map<String, dynamic>;
          final start = sMap['startDate']?.toString() ?? '';
          final end = sMap['endDate']?.toString() ?? '';
          if (start.isNotEmpty && dateStr.compareTo(start) < 0) continue;
          if (end.isNotEmpty && dateStr.compareTo(end) > 0) continue;

          // Check dayOfWeek field from API
          final dayOfWeek = sMap['dayOfWeek']?.toString().toLowerCase() ?? '';
          if (dayOfWeek == weekday) {
            matchesDay = true;
            break;
          }
          // Fallback: check boolean fields
          if (sMap[weekday] == true || sMap[weekday] == 1) {
            matchesDay = true;
            break;
          }
        }
      }

      if (matchesDay) {
        // Attach completed status
        final classId = cls['id'];
        final isCompleted = completedSessions.any((cs) =>
            cs['classId'] == classId &&
            cs['sessionDate']?.toString() == dateStr);
        results.add({...e, '_isCompleted': isCompleted});
      }
    }

    return results;
  }

  // ── Private Lessons filter ─────────────────────────────────────────────
  List<Map<String, dynamic>> _filterPrivate() {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    return privateLessons.where((e) {
      final lesson = e['lesson'] as Map<String, dynamic>? ?? {};
      final lessonDate = lesson['date']?.toString() ?? '';
      if (lessonDate != dateStr) return false;
      // Student filter
      if (selectedStudentId.value != 'All') {
        if (e['studentId']?.toString() != selectedStudentId.value) return false;
      }
      // Studio filter
      if (selectedStudioId.value != 'All') {
        final studioId = lesson['studio']?['id']?.toString() ?? '';
        if (studioId != selectedStudioId.value) return false;
      }
      return true;
    }).toList();
  }

  // ── Wellness filter ────────────────────────────────────────────────────
  List<Map<String, dynamic>> _filterWellness() {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    return wellnessClasses.where((c) {
      if (c['date']?.toString() != dateStr) return false;
      if (selectedStudioId.value != 'All') {
        final sId = (c['studio_id'] ?? c['studio']?['id'])?.toString() ?? '';
        if (sId != selectedStudioId.value) return false;
      }
      return true;
    }).toList();
  }

  // ── Choreography filter ────────────────────────────────────────────────
  List<Map<String, dynamic>> _filterChoreography() {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    return choreographies.where((e) {
      final choreo = e['choreography'] as Map<String, dynamic>? ?? e;
      final start = choreo['startDate']?.toString() ?? '';
      final end = choreo['endDate']?.toString() ?? '';
      // Show if current date is within the choreography date range
      if (start.isNotEmpty && dateStr.compareTo(start) < 0) return false;
      if (end.isNotEmpty && dateStr.compareTo(end) > 0) return false;
      // Student filter
      if (selectedStudentId.value != 'All') {
        if (e['studentId']?.toString() != selectedStudentId.value) return false;
      }
      // Studio filter
      if (selectedStudioId.value != 'All') {
        final studioId = choreo['studio']?['id']?.toString() ?? '';
        if (studioId != selectedStudioId.value) return false;
      }
      return true;
    }).toList();
  }

  // ── Routines filter ────────────────────────────────────────────────────
  List<Map<String, dynamic>> _filterRoutines() {
    return routines.where((e) {
      // Student filter
      if (selectedStudentId.value != 'All') {
        if (e['studentId']?.toString() != selectedStudentId.value) return false;
      }
      // Studio filter
      if (selectedStudioId.value != 'All') {
        final routine = e['routine'] as Map<String, dynamic>? ?? {};
        final studioId = routine['room']?['studio']?['id']?.toString() ?? '';
        if (studioId != selectedStudioId.value) return false;
      }
      return true;
    }).toList();
  }

  // ── Time formatting helper ─────────────────────────────────────────────
  String formatTime24to12(String? time24) {
    if (time24 == null || time24.isEmpty) return '';
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final min = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:$min $period';
    } catch (_) {
      return time24;
    }
  }
}
