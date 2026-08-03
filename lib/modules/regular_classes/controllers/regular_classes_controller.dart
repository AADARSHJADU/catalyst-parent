import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/core/services/stripe_payment_service.dart';
import 'package:catalyst/data/services/regular_class_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class RegularClassesController extends GetxController {
  final RegularClassService _service = Get.find<RegularClassService>();

  // ── State ──────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final currentTab = 0.obs; // 0=Browse, 1=My Enrollments

  // ── Data ───────────────────────────────────────────────────────────────
  final classes = <Map<String, dynamic>>[].obs;
  final myBookings = <Map<String, dynamic>>[].obs;
  final students = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final registrationFee = Rxn<Map<String, dynamic>>();
  final paymentGateways = <String>[].obs;

  // ── Booking form ───────────────────────────────────────────────────────
  final selectedClassId = Rxn<int>();
  final selectedStudentId = Rxn<int>();
  final joiningDate = Rxn<DateTime>();
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
        _service.getMyBookings(),
        _service.getStudents(),
        _service.getRegistrationFee(),
        _service.getPaymentMethods(),
      ]);
      classes.value = results[0] as List<Map<String, dynamic>>;
      myBookings.value = results[1] as List<Map<String, dynamic>>;
      students.value = results[2] as List<Map<String, dynamic>>;
      registrationFee.value = results[3] as Map<String, dynamic>;
      // Payment methods can be List<String> or Map
      final pm = results[4];
      if (pm is Map<String, dynamic>) {
        final gw = <String>[];
        if (pm['stripeEnabled'] == true) gw.add('stripe');
        if (pm['paypalEnabled'] == true) gw.add('paypal');
        if (pm['cashEnabled'] == true) gw.add('cash');
        paymentGateways.value = gw;
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBookings() async {
    try {
      myBookings.value = await _service.getMyBookings();
    } catch (_) {}
  }

  List<Map<String, dynamic>> get filteredClasses {
    final _ = classes.length;
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return List<Map<String, dynamic>>.from(classes);
    return classes.where((c) {
      final name = c['name']?.toString().toLowerCase() ?? '';
      final instructor = c['instructorName']?.toString().toLowerCase() ?? '';
      final style = c['danceStyle']?.toString().toLowerCase() ?? '';
      return name.contains(q) || instructor.contains(q) || style.contains(q);
    }).toList();
  }

  // ── Book with Pay Later (Cash) ─────────────────────────────────────────
  Future<bool> bookPayLater(int classId) async {
    if (selectedStudentId.value == null || joiningDate.value == null) {
      Get.snackbar('Error', 'Please select student and joining date',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
      return false;
    }
    isBooking.value = true;
    try {
      final dateStr =
          '${joiningDate.value!.year}-${joiningDate.value!.month.toString().padLeft(2, '0')}-${joiningDate.value!.day.toString().padLeft(2, '0')}';
      await _service.payLater(
        studentId: selectedStudentId.value!,
        classId: classId,
        joiningDate: dateStr,
      );
      await refreshBookings();
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar('Booked!', 'Class booked. Pay at the studio desk.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success, colorText: Colors.white);
      });
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
      return false;
    } finally {
      isBooking.value = false;
    }
  }

  // ── Book with Online Payment (Stripe) ──────────────────────────────────
  Future<bool> bookOnline(int classId) async {
    if (selectedStudentId.value == null || joiningDate.value == null) {
      Get.snackbar('Error', 'Please select student and joining date',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
      return false;
    }
    isBooking.value = true;
    try {
      final dateStr =
          '${joiningDate.value!.year}-${joiningDate.value!.month.toString().padLeft(2, '0')}-${joiningDate.value!.day.toString().padLeft(2, '0')}';

      final checkoutData = await _service.checkout(
        studentId: selectedStudentId.value!,
        classId: classId,
        paymentMethod: 'stripe',
        joiningDate: dateStr,
      );

      final clientSecret = checkoutData['clientSecret']?.toString() ?? '';
      final paymentId = checkoutData['paymentId'] as int?;
      final gatewayOrderId = checkoutData['gatewayOrderId']?.toString() ?? '';

      if (clientSecret.isNotEmpty) {
        // Use in-app Stripe Payment Sheet
        final success = await StripePaymentService.instance
            .presentPaymentSheet(clientSecret: clientSecret);

        if (success && paymentId != null) {
          // Capture payment on backend
          await _service.capture(
            paymentId: paymentId,
            paymentMethod: 'stripe',
            gatewayOrderId: gatewayOrderId,
            joiningDate: dateStr,
          );
          await refreshBookings();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar('Success', 'Class booked & payment confirmed!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success, colorText: Colors.white);
          });
          return true;
        }
        return false; // User cancelled
      }

      // Fallback: open approvalUrl in browser (if clientSecret not available)
      final approvalUrl = checkoutData['approvalUrl']?.toString() ?? '';
      if (approvalUrl.isNotEmpty) {
        final uri = Uri.parse(approvalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        Future.delayed(const Duration(seconds: 3), () => refreshBookings());
        return true;
      }

      Get.snackbar('Error', 'Could not initiate payment.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
      return false;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
      return false;
    } finally {
      isBooking.value = false;
    }
  }

  // ── Fee Calculation ──────────────────────────────────────────────────────
  double getExtraFeeTotal() {
    final fee = registrationFee.value;
    if (fee == null) return 0;
    final components = fee['feeComponents'];
    if (components is Map) {
      return components.values.fold<double>(
          0, (sum, v) => sum + (double.tryParse(v.toString()) ?? 0));
    }
    if (components is List) {
      return components.fold<double>(
          0, (sum, c) => sum + (double.tryParse(c['amount']?.toString() ?? '0') ?? 0));
    }
    return double.tryParse(fee['totalAmount']?.toString() ?? '0') ?? 0;
  }

  Map<String, double> get feeComponentsMap {
    final fee = registrationFee.value;
    if (fee == null) return {};
    final components = fee['feeComponents'];
    if (components is Map) {
      return components.map((k, v) =>
          MapEntry(k.toString(), double.tryParse(v.toString()) ?? 0));
    }
    if (components is List) {
      final map = <String, double>{};
      for (final c in components) {
        final name = c['name']?.toString() ?? 'Fee';
        final amount = double.tryParse(c['amount']?.toString() ?? '0') ?? 0;
        map[name] = amount;
      }
      return map;
    }
    return {};
  }

  double getGrandTotal(double baseCost) => baseCost + getExtraFeeTotal();

  // ── Drop Enrollment ────────────────────────────────────────────────────
  Future<void> dropEnrollment(int enrollmentId) async {
    try {
      await _service.dropEnrollment(enrollmentId);
      myBookings.removeWhere((b) => b['id'] == enrollmentId);
      Get.snackbar('Dropped', 'Enrollment cancelled successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success, colorText: Colors.white);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  // ── Pay Pending Class Invoice ──────────────────────────────────────────
  Future<void> payClassInvoice(int paymentId) async {
    isBooking.value = true;
    try {
      final result = await _service.payClassInvoice(paymentId);
      final clientSecret = result['clientSecret']?.toString() ?? '';
      final gatewayOrderId = result['gatewayOrderId']?.toString() ??
          result['transactionId']?.toString() ?? '';

      if (clientSecret.isNotEmpty) {
        final success = await StripePaymentService.instance
            .presentPaymentSheet(clientSecret: clientSecret);
        if (success) {
          await refreshBookings();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar('Success', 'Payment confirmed!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success, colorText: Colors.white);
          });
        }
        return;
      }

      // Fallback: approvalUrl for browser
      final approvalUrl = result['approvalUrl']?.toString() ?? '';
      if (approvalUrl.isNotEmpty) {
        final uri = Uri.parse(approvalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        Future.delayed(const Duration(seconds: 3), () => refreshBookings());
      } else {
        await refreshBookings();
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Success', 'Payment processed!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.success, colorText: Colors.white);
        });
      }
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isBooking.value = false;
    }
  }
}
