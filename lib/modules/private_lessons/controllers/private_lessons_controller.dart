import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/data/mock/mock_data.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivateLessonsController extends GetxController {
  final instructors = MockData.instructors;
  final categories = MockData.lessonCategories;

  // ── Lesson detail ───────────────────────────────────────────────────
  PrivateLessonModel? selectedLesson;
  void selectLesson(PrivateLessonModel lesson) => selectedLesson = lesson;

  // ── Filters (main screen) ───────────────────────────────────────────
  final filterStudent = 'All Students'.obs;
  final filterInstructor = 'All Instructors'.obs;
  final filterDateRange = 'May 19 – May 25, 2025'.obs;
  final filterViewMode = 'Week View'.obs;

  final studentOptions = <String>[
    'All Students', 'Ava Rodriguez', 'Liam Carter', 'Mia Johnson', 'Emma Johnson',
  ];
  final instructorOptions = <String>[
    'All Instructors', 'Hannah Blake', 'Liam Carter', 'Ava Rodriguez',
  ];
  final dateRangeOptions = <String>[
    'May 19 – May 25, 2025', 'May 12 – May 18, 2025',
    'May 5 – May 11, 2025', 'All Dates',
  ];
  final viewModeOptions = <String>['Week View', 'Month View', 'List View'];

  // ── Filtered lesson lists ───────────────────────────────────────────
  List<PrivateLessonModel> get allLessons => MockData.privateLessons;

  List<PrivateLessonModel> get upcomingFiltered => allLessons.where((l) {
        if (l.isPast) return false;
        if (filterStudent.value != 'All Students' &&
            l.student != filterStudent.value) return false;
        if (filterInstructor.value != 'All Instructors' &&
            l.instructor != filterInstructor.value) return false;
        return true;
      }).toList();

  List<PrivateLessonModel> get pastFiltered => allLessons.where((l) {
        if (!l.isPast) return false;
        if (filterStudent.value != 'All Students' &&
            l.student != filterStudent.value) return false;
        if (filterInstructor.value != 'All Instructors' &&
            l.instructor != filterInstructor.value) return false;
        return true;
      }).toList();

  List<PrivateLessonModel> get pastPreview => pastFiltered.take(2).toList();

  // ── Booking flow state ──────────────────────────────────────────────
  final bookingStep = 0.obs;

  // Step 1
  final selectedInstructor = Rxn<InstructorModel>();
  final searchQuery = ''.obs;

  // Step 2
  final selectedDate = Rxn<DateTime>();
  final selectedTime = ''.obs;
  final calendarMonth = DateTime.now().obs; // ← lives here, not as static

  // Step 3
  final selectedDanceStyle = 'Ballet'.obs;
  final selectedFocusAreas = <String>[].obs;
  final additionalNotes = ''.obs;
  final selectedStudio = 'Inferno'.obs;
  final selectedRecording = 'Mirrors (No Recording)'.obs;

  // Legacy (kept for BookLessonView compat)
  final selectedCategory = ''.obs;
  final selectedSlot = ''.obs;
  final selectedDancer = MockData.dancers.first.name.obs;
  final isBooking = false.obs;

  // ── Static data ─────────────────────────────────────────────────────
  final danceStyles = const [
    'Ballet', 'Hip Hop', 'Contemporary', 'Jazz', 'Tap',
    'Lyrical', 'Acrobatics', 'Technique',
  ];
  final focusOptions = const [
    'Technique', 'Strength', 'Flexibility', 'Performance',
    'Choreography', 'Turns', 'Leaps', 'Other',
  ];
  final studioOptions = const ['Inferno', 'Kindle', 'Ignite'];
  final recordingOptions = const [
    'Mirrors (No Recording)', 'Video Recording', 'No Mirrors',
  ];
  final timeSlots = const [
    '9:00 AM',  '9:30 AM',  '10:00 AM',
    '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '1:00 PM',
    '1:30 PM',  '2:00 PM',  '2:30 PM',
    '4:00 PM',  '4:30 PM',  '5:00 PM',
    '5:30 PM',  '6:00 PM',  '6:30 PM',
    '7:00 PM',  '7:30 PM',  '8:00 PM',
  ];

  // ── Computed ────────────────────────────────────────────────────────
  List<InstructorModel> get filteredInstructors {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return instructors;
    return instructors.where((i) =>
        i.name.toLowerCase().contains(q) ||
        i.specialty.toLowerCase().contains(q) ||
        i.styles.any((s) => s.toLowerCase().contains(q))).toList();
  }

  double get lessonPrice =>
      (selectedInstructor.value?.hourlyRate ?? 85.0).toDouble();
  double get serviceFee => 2.50;
  double get total => lessonPrice + serviceFee;

  // ── Methods ─────────────────────────────────────────────────────────
  void toggleFocusArea(String area) {
    if (selectedFocusAreas.contains(area)) {
      selectedFocusAreas.remove(area);
    } else {
      selectedFocusAreas.add(area);
    }
  }

  void prevCalendarMonth() {
    final m = calendarMonth.value;
    calendarMonth.value = DateTime(m.year, m.month - 1);
  }

  void nextCalendarMonth() {
    final m = calendarMonth.value;
    calendarMonth.value = DateTime(m.year, m.month + 1);
  }

  void resetBookingFlow() {
    bookingStep.value = 0;
    selectedInstructor.value = null;
    selectedDate.value = null;
    selectedTime.value = '';
    calendarMonth.value = DateTime.now();
    selectedDanceStyle.value = 'Ballet';
    selectedFocusAreas.clear();
    additionalNotes.value = '';
    selectedStudio.value = 'Inferno';
    selectedRecording.value = 'Mirrors (No Recording)';
    searchQuery.value = '';
  }

  // Legacy methods
  void selectInstructor(InstructorModel instructor) {
    selectedInstructor.value = instructor;
    selectedSlot.value = '';
  }

  void selectCategory(String category) => selectedCategory.value = category;
  void selectSlot(String slot) => selectedSlot.value = slot;
  void selectDancer(String dancer) => selectedDancer.value = dancer;

  Future<void> confirmBooking() async {
    isBooking.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isBooking.value = false;

    final instructorName = selectedInstructor.value?.name ?? '';
    resetBookingFlow();

    // Pop back to either /private-lessons (if user came from that tab)
    // or /instructor-detail (if user came from the schedule flow).
    // Get.until pops until the predicate returns true; if neither route
    // is in the stack it keeps popping — so we stop at the first
    // recognised "parent" screen.
    Get.until((route) {
      final name = route.settings.name;
      return name == AppRoutes.privateLessons ||
          name == AppRoutes.instructorDetail ||
          name == AppRoutes.main;
    });

    Get.snackbar(
      'Booking Confirmed!',
      'Your lesson with $instructorName is confirmed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
