import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/data/mock/mock_data.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:catalyst/data/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class HomeController extends GetxController {
  final user = MockData.currentUser;
  final dancers = MockData.dancers;
  final upcomingBookings = MockData.bookings.take(3).toList();
  final unreadNotifications =
      MockData.notifications.where((n) => !n.isRead).length;
}

class ScheduleController extends GetxController {
  final allClasses = MockData.classes.obs;
  final selectedDay = 'All'.obs;
  final searchQuery = ''.obs;
  ClassScheduleModel? selectedClass;
  InstructorModel? selectedInstructor;

  final days = ['All', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].obs;

  final classBookingStep = 0.obs;
  final classBookingDancer = MockData.dancers.first.name.obs;
  final classBookingDate = Rxn<DateTime>();
  final classBookingTime = ''.obs;
  final classBookingCalendarMonth = DateTime.now().obs;
  final classBookingAddons = <String>[].obs;
  final isConfirmingClass = false.obs;

  final classTimeSlots = const [
    '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM', '2:00 PM', '2:30 PM',
    '4:00 PM', '4:30 PM', '5:00 PM', '5:30 PM', '6:00 PM', '6:30 PM',
    '7:00 PM', '7:30 PM', '8:00 PM',
  ];

  final classAddOnOptions = const [
    'Recording of class',
    'Extra warm-up (15 mins)',
    'Progress report',
    'Parent observation pass',
  ];

  void resetClassBooking() {
    classBookingStep.value = 0;
    classBookingDancer.value = MockData.dancers.first.name;
    classBookingDate.value = null;
    classBookingTime.value = '';
    classBookingCalendarMonth.value = DateTime.now();
    classBookingAddons.clear();
  }

  void prevClassCalendarMonth() {
    final m = classBookingCalendarMonth.value;
    classBookingCalendarMonth.value = DateTime(m.year, m.month - 1);
  }

  void nextClassCalendarMonth() {
    final m = classBookingCalendarMonth.value;
    classBookingCalendarMonth.value = DateTime(m.year, m.month + 1);
  }

  void toggleClassAddon(String addon) {
    if (classBookingAddons.contains(addon)) {
      classBookingAddons.remove(addon);
    } else {
      classBookingAddons.add(addon);
    }
  }

  Future<void> confirmClassBooking() async {
    isConfirmingClass.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isConfirmingClass.value = false;
    Get.until((r) => r.settings.name == AppRoutes.classDetail);
    Get.snackbar(
      'Class Booked!',
      '${selectedClass?.title ?? 'Class'} has been booked for ${classBookingDancer.value}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    resetClassBooking();
  }

  List<ClassScheduleModel> get filteredClasses {
    List<ClassScheduleModel> result = allClasses.toList();
    if (selectedDay.value != 'All') {
      result = result.where((c) => c.day == selectedDay.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where((c) =>
              c.title.toLowerCase().contains(query) ||
              c.instructor.toLowerCase().contains(query))
          .toList();
    }
    return result;
  }

  Map<String, List<ClassScheduleModel>> get classesGroupedByDate {
    final grouped = <String, List<ClassScheduleModel>>{};
    for (final cls in filteredClasses) {
      final key = cls.fullDate.isEmpty ? cls.day : cls.fullDate;
      grouped.putIfAbsent(key, () => []).add(cls);
    }
    return grouped;
  }

  void selectDay(String day) => selectedDay.value = day;
  void updateSearch(String query) => searchQuery.value = query;
  void selectClass(ClassScheduleModel cls) => selectedClass = cls;

  void selectInstructorByName(String name) {
    selectedInstructor = MockData.instructors.firstWhereOrNull(
      (i) => i.name.toLowerCase() == name.toLowerCase(),
    );
    selectedInstructor ??= InstructorModel(
      id: '0', name: name, specialty: 'Dance', hourlyRate: 70,
      rating: 5.0, availableSlots: [], reviewCount: 0,
      bio: '', styles: [], certifications: [],
    );
  }
}

class MoreController extends GetxController {
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userRole = 'Parent'.obs;
  final profilePicUrl = ''.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final service = SettingsService();
      final profile = await service.getProfile();
      userName.value = profile.user.fullName;
      userEmail.value = profile.user.email;
      profilePicUrl.value = profile.user.profilePic ?? '';
      userRole.value = 'Parent';
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final service = SettingsService();
      final profile = await service.getProfile();
      userName.value = profile.user.fullName;
      userEmail.value = profile.user.email;
      profilePicUrl.value = profile.user.profilePic ?? '';
    } catch (_) {}
  }
}
