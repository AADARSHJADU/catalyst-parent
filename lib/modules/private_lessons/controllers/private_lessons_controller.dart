import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/services/private_booking_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivateLessonsController extends GetxController {
  final PrivateBookingService _service = Get.find<PrivateBookingService>();

  // ── State ──────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // ── Instructors ────────────────────────────────────────────────────────
  final instructors = <Map<String, dynamic>>[].obs;
  final danceStyles = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedStyleFilter = ''.obs;

  // ── My Bookings ────────────────────────────────────────────────────────
  final myBookings = <Map<String, dynamic>>[].obs;
  final isLoadingBookings = false.obs;

  // ── Students ───────────────────────────────────────────────────────────
  final students = <Map<String, dynamic>>[].obs;

  // ── Booking Form State ─────────────────────────────────────────────────
  final selectedInstructor = Rxn<Map<String, dynamic>>();
  final selectedStudentId = Rxn<int>();
  final selectedDate = Rxn<DateTime>();
  final selectedTime = ''.obs;
  final selectedDuration = 60.obs;
  final focusArea = ''.obs;
  final studentGoal = ''.obs;
  final notes = ''.obs;
  final availableSlots = <String>[].obs;
  final isLoadingSlots = false.obs;
  final calculatedPrice = Rxn<Map<String, dynamic>>();
  final isSubmitting = false.obs;

  // ── Tab ────────────────────────────────────────────────────────────────
  final currentTab = 0.obs; // 0 = Instructors, 1 = My Bookings

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        _service.getInstructors(),
        _service.getDanceStyles(),
        _service.getStudents(),
        _service.getMyBookings(),
      ]);
      instructors.value = results[0] as List<Map<String, dynamic>>;
      danceStyles.value = results[1] as List<Map<String, dynamic>>;
      students.value = results[2] as List<Map<String, dynamic>>;
      myBookings.value = results[3] as List<Map<String, dynamic>>;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBookings() async {
    isLoadingBookings.value = true;
    try {
      final data = await _service.getMyBookings();
      // Debug: print first booking to check actual field names
      if (data.isNotEmpty) {
        print('📋 [PRIVATE BOOKINGS] First booking keys: ${data.first.keys.toList()}');
        print('📋 [PRIVATE BOOKINGS] First booking data: ${data.first}');
      }
      myBookings.value = data;
    } catch (e) {
      print('❌ [PRIVATE BOOKINGS] refreshBookings error: $e');
    }
    isLoadingBookings.value = false;
  }

  // ── Filtered instructors ───────────────────────────────────────────────
  List<Map<String, dynamic>> get filteredInstructors {
    final _ = instructors.length;
    List<Map<String, dynamic>> result =
        List<Map<String, dynamic>>.from(instructors);

    // Style filter
    final style = selectedStyleFilter.value;
    if (style.isNotEmpty) {
      result = result.where((i) {
        final styles = i['styles']?.toString().toLowerCase() ?? '';
        final styleList = i['styleList'];
        if (styleList is List) {
          return styleList.any(
              (s) => s.toString().toLowerCase().contains(style.toLowerCase()));
        }
        return styles.contains(style.toLowerCase());
      }).toList();
    }

    // Search
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((i) {
        final name = i['name']?.toString().toLowerCase() ?? '';
        final styles = i['styles']?.toString().toLowerCase() ?? '';
        return name.contains(q) || styles.contains(q);
      }).toList();
    }

    return result;
  }

  // ── Fetch availability ─────────────────────────────────────────────────
  Future<void> fetchAvailability() async {
    if (selectedInstructor.value == null || selectedDate.value == null) return;
    isLoadingSlots.value = true;
    availableSlots.clear();
    selectedTime.value = '';
    try {
      final instructorId = selectedInstructor.value!['id'] as int;
      final dateStr =
          '${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}';
      final slots = await _service.getAvailability(instructorId, dateStr);
      availableSlots.value = slots;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } finally {
      isLoadingSlots.value = false;
    }
  }

  // ── Calculate price ────────────────────────────────────────────────────
  Future<void> calculatePrice() async {
    if (selectedInstructor.value == null) return;
    try {
      final result = await _service.calculatePrice(
        instructorId: selectedInstructor.value!['id'] as int,
        duration: selectedDuration.value,
      );
      calculatedPrice.value = result;
    } catch (_) {}
  }

  // ── Submit booking request ─────────────────────────────────────────────
  Future<bool> submitRequest() async {
    if (selectedStudentId.value == null ||
        selectedInstructor.value == null ||
        selectedDate.value == null ||
        selectedTime.value.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return false;
    }

    isSubmitting.value = true;
    try {
      final dateStr =
          '${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}';

      await _service.requestClass(
        studentId: selectedStudentId.value!,
        instructorId: selectedInstructor.value!['id'] as int,
        date: dateStr,
        startTime: selectedTime.value,
        duration: selectedDuration.value,
        focusArea: focusArea.value,
        studentGoal: studentGoal.value,
        notes: notes.value,
      );

      // Refresh bookings
      refreshBookings();

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar('Success', 'Private class request submitted!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white);
      });
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Reset booking form ─────────────────────────────────────────────────
  void resetBookingForm() {
    selectedDate.value = null;
    selectedTime.value = '';
    selectedDuration.value = 60;
    focusArea.value = '';
    studentGoal.value = '';
    notes.value = '';
    availableSlots.clear();
    calculatedPrice.value = null;
    if (students.isNotEmpty) {
      selectedStudentId.value = students.first['id'] as int?;
    }
  }

  // ── Select instructor for booking ──────────────────────────────────────
  void selectInstructorForBooking(Map<String, dynamic> instructor) {
    selectedInstructor.value = instructor;
    resetBookingForm();
  }

  // ── Pay for approved lesson ──────────────────────────────────────────────
  Future<void> payForLesson(int lessonId) async {
    try {
      Get.snackbar('Processing', 'Initiating payment...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));

      // Step 1: Checkout — get payment session
      final checkoutData = await _service.lessonCheckout(lessonId);

      final approvalUrl = checkoutData['approvalUrl']?.toString() ?? '';
      final gatewayOrderId = checkoutData['gatewayOrderId']?.toString() ?? '';

      if (approvalUrl.isNotEmpty) {
        // Open Stripe/PayPal hosted checkout page in browser
        await _openPaymentUrl(approvalUrl);

        // After user returns from payment, refresh bookings
        // (Status will be updated by backend webhook)
        Future.delayed(const Duration(seconds: 3), () {
          refreshBookings();
        });
      } else if (gatewayOrderId.isNotEmpty) {
        // Try direct capture (for backends that support it)
        try {
          await _service.lessonCapture(
            lessonId,
            gatewayOrderId: gatewayOrderId,
            paymentMethod: 'stripe',
          );
          await refreshBookings();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar('Payment Successful!',
                'Your private lesson has been confirmed.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success,
                colorText: Colors.white);
          });
        } catch (_) {
          // Capture failed — backend may need webhook instead
          Get.snackbar('Info',
              'Payment session created. Please complete payment if redirected.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.warning,
              colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Failed to initiate payment session.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white);
      }
    } on ApiException catch (e) {
      Get.snackbar('Payment Failed', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Payment could not be processed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  Future<void> _openPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }
}
