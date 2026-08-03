import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/core/services/stripe_payment_service.dart';
import 'package:catalyst/data/services/wellness_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class WellnessNewController extends GetxController {
  final WellnessApiService _service = Get.find<WellnessApiService>();

  // ── State ──────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final currentTab = 0.obs; // 0=Browse,1=Buy Pass,2=Membership,3=Bookings

  // ── Classes ────────────────────────────────────────────────────────────
  final classes = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;
  final categories = const ['', 'Yoga', 'Pilates', 'Meditation', 'Sound Healing', 'Barre', 'Breathwork'];
  final categoryLabels = const ['All', 'Yoga', 'Pilates', 'Meditation', 'Sound Healing', 'Barre', 'Breathwork'];

  // ── Products ───────────────────────────────────────────────────────────
  final products = <Map<String, dynamic>>[].obs;

  // ── Membership ─────────────────────────────────────────────────────────
  final membershipData = Rxn<Map<String, dynamic>>();
  final creditsRemaining = 0.obs;
  final creditsLedger = <Map<String, dynamic>>[].obs;

  // ── Bookings ───────────────────────────────────────────────────────────
  final upcomingBookings = <Map<String, dynamic>>[].obs;
  final pastBookings = <Map<String, dynamic>>[].obs;
  final waitlistBookings = <Map<String, dynamic>>[].obs;
  final bookingsSubTab = 0.obs; // 0=upcoming,1=past,2=waitlist

  // ── Actions ────────────────────────────────────────────────────────────
  final isBooking = false.obs;

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
        _service.getClasses(),
        _service.getProducts(),
        _service.getMyMemberships(),
        _service.getMyBookings(),
      ]);
      classes.value = results[0] as List<Map<String, dynamic>>;
      products.value = results[1] as List<Map<String, dynamic>>;
      _parseMembership(results[2] as Map<String, dynamic>);
      _parseBookings(results[3] as Map<String, dynamic>);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Failed to load wellness data.';
    } finally {
      isLoading.value = false;
    }
  }

  void _parseMembership(Map<String, dynamic> data) {
    final memberships = data['memberships'] as List? ?? [];
    if (memberships.isNotEmpty) {
      membershipData.value = memberships.first as Map<String, dynamic>;
    }
    creditsRemaining.value = (data['creditsRemaining'] as num?)?.toInt() ?? 0;
    creditsLedger.value =
        List<Map<String, dynamic>>.from(data['creditsLedger'] ?? []);
  }

  void _parseBookings(Map<String, dynamic> data) {
    upcomingBookings.value =
        List<Map<String, dynamic>>.from(data['upcoming'] ?? []);
    pastBookings.value =
        List<Map<String, dynamic>>.from(data['past'] ?? []);
    waitlistBookings.value =
        List<Map<String, dynamic>>.from(data['waitlist'] ?? []);
  }

  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _service.getClasses(search: searchQuery.value, category: selectedCategory.value),
        _service.getMyMemberships(),
        _service.getMyBookings(),
      ]);
      classes.value = results[0] as List<Map<String, dynamic>>;
      _parseMembership(results[1] as Map<String, dynamic>);
      _parseBookings(results[2] as Map<String, dynamic>);
    } catch (_) {}
  }

  Future<void> refreshClasses() async {
    try {
      classes.value = await _service.getClasses(
          search: searchQuery.value, category: selectedCategory.value);
    } catch (_) {}
  }

  // ── Filtered classes ───────────────────────────────────────────────────
  List<Map<String, dynamic>> get filteredClasses {
    final _ = classes.length;
    final q = searchQuery.value.toLowerCase();
    final cat = selectedCategory.value;
    return classes.where((c) {
      if (cat.isNotEmpty &&
          c['category']?.toString().toLowerCase() != cat.toLowerCase()) {
        return false;
      }
      if (q.isNotEmpty) {
        final name = c['name']?.toString().toLowerCase() ?? '';
        final inst = c['instructor']?.toString().toLowerCase() ?? '';
        if (!name.contains(q) && !inst.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  // ── Book with Pass Credit ──────────────────────────────────────────────
  Future<void> bookWithCredit(int classId, List<String> dates) async {
    isBooking.value = true;
    try {
      final result =
          await _service.bookClass(classId: classId, sessionDates: dates);
      final status = result['status']?.toString() ?? '';
      final msg = result['message']?.toString() ?? 'Booking processed.';
      final remaining = result['creditsRemaining'];
      if (remaining != null) creditsRemaining.value = (remaining as num).toInt();

      await refresh();
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          status == 'waitlisted' ? 'Waitlisted' : 'Booked!',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor:
              status == 'waitlisted' ? AppColors.warning : AppColors.success,
          colorText: Colors.white,
        );
      });
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } finally {
      isBooking.value = false;
    }
  }

  // ── Drop-in Payment ────────────────────────────────────────────────────
  Future<void> payDropIn(int classId, List<String> dates, double price) async {
    isBooking.value = true;
    try {
      final result = await _service.dropinCheckout(
          classId: classId, sessionDates: dates);
      final approvalUrl = result['approvalUrl']?.toString() ?? '';
      if (approvalUrl.isNotEmpty) {
        final uri = Uri.parse(approvalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        // After return, confirm
        Future.delayed(const Duration(seconds: 3), () => refresh());
      }
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } finally {
      isBooking.value = false;
    }
  }

  // ── Cancel Booking ─────────────────────────────────────────────────────
  Future<void> cancelBooking(int bookingId) async {
    try {
      final result = await _service.cancelBooking(bookingId);
      final remaining = result['creditsRemaining'];
      if (remaining != null) creditsRemaining.value = (remaining as num).toInt();
      await refresh();
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar('Cancelled', 'Booking cancelled & credit refunded.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white);
      });
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  // ── Buy Pass ───────────────────────────────────────────────────────────
  Future<void> buyPass(int productId) async {
    isBooking.value = true;
    try {
      final result = await _service.membershipCheckout(productId: productId);
      final clientSecret = result['clientSecret']?.toString() ?? '';
      final approvalUrl = result['approvalUrl']?.toString() ?? '';

      if (clientSecret.isNotEmpty) {
        final success = await StripePaymentService.instance
            .presentPaymentSheet(clientSecret: clientSecret);
        if (success) {
          final paymentId = result['paymentId'] as int?;
          if (paymentId != null) {
            try {
              await _service.membershipCapture(
                paymentId: paymentId,
                gatewayOrderId: result['gatewayOrderId']?.toString(),
              );
            } catch (_) {}
          }
          await refresh();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar('Success', 'Pass purchased! Credits added.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success, colorText: Colors.white);
          });
        }
      } else if (approvalUrl.isNotEmpty) {
        final uri = Uri.parse(approvalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        Future.delayed(const Duration(seconds: 3), () => refresh());
      }
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } finally {
      isBooking.value = false;
    }
  }
}
