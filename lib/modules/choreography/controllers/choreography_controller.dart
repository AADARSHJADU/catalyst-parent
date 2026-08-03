import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/services/choreography_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ChoreographyController extends GetxController {
  final ChoreographyService _service = Get.find<ChoreographyService>();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final choreographies = <Map<String, dynamic>>[].obs;
  final students = <Map<String, dynamic>>[].obs;
  final isBooking = false.obs;

  // ── Filters ────────────────────────────────────────────────────────────
  final selectedFilter = 'All'.obs;
  final filters = const ['All', 'Pending Payment', 'Paid'];

  // ── Stats ──────────────────────────────────────────────────────────────
  int get pendingCount {
    int count = 0;
    for (final c in choreographies) {
      final students = c['students'] as List? ?? [];
      for (final s in students) {
        final pay = (s as Map)['paymentStatus']?.toString().toLowerCase() ?? '';
        if (pay != 'paid') count++;
      }
    }
    return count;
  }

  int get completedCount {
    int count = 0;
    for (final c in choreographies) {
      final students = c['students'] as List? ?? [];
      for (final s in students) {
        final pay = (s as Map)['paymentStatus']?.toString().toLowerCase() ?? '';
        if (pay == 'paid') count++;
      }
    }
    return count;
  }

  // ── Filtered list ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> get filteredChoreographies {
    final _ = choreographies.length;
    final filter = selectedFilter.value;
    if (filter == 'All') return List<Map<String, dynamic>>.from(choreographies);
    if (filter == 'Paid') {
      return choreographies.where((c) {
        final overall = c['overallPaymentStatus']?.toString().toLowerCase() ?? '';
        return overall == 'paid';
      }).toList();
    }
    // Pending Payment
    return choreographies.where((c) {
      final overall = c['overallPaymentStatus']?.toString().toLowerCase() ?? '';
      return overall != 'paid';
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        _service.getMyChoreographies(),
        _service.getStudents(),
      ]);
      choreographies.value = results[0] as List<Map<String, dynamic>>;
      students.value = results[1] as List<Map<String, dynamic>>;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    try {
      choreographies.value = await _service.getMyChoreographies();
    } catch (_) {}
  }

  Future<void> payOnline(int choreographyId, int studentId) async {
    isBooking.value = true;
    try {
      final data = await _service.checkout(
        choreographyId: choreographyId,
        studentId: studentId,
        paymentMethod: 'stripe',
      );
      final approvalUrl = data['approvalUrl']?.toString() ?? '';
      if (approvalUrl.isNotEmpty) {
        final uri = Uri.parse(approvalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        Future.delayed(const Duration(seconds: 3), () => refresh());
      } else {
        Get.snackbar('Info', 'Payment session created.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> payLater(int choreographyId, int studentId) async {
    isBooking.value = true;
    try {
      await _service.payLater(
          choreographyId: choreographyId, studentId: studentId);
      await refresh();
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar('Booked', 'Pay at the studio desk.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success, colorText: Colors.white);
      });
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isBooking.value = false;
    }
  }
}
