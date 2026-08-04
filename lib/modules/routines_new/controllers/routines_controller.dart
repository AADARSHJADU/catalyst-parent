import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/core/services/stripe_payment_service.dart';
import 'package:catalyst/data/services/routine_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class RoutinesNewController extends GetxController {
  final RoutineService _service = Get.find<RoutineService>();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final routines = <Map<String, dynamic>>[].obs;
  final students = <Map<String, dynamic>>[].obs;
  final registrationFee = Rxn<Map<String, dynamic>>();
  final paymentMethods = <String>[].obs;
  final isPaying = false.obs;

  // Filters
  final selectedStudentId = 'All'.obs;
  final selectedPaymentFilter = 'All'.obs;
  final paymentFilters = const ['All', 'Pending', 'Paid'];

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
        _service.getMyRoutines(),
        _service.getStudents(),
        _service.getRegistrationFee(),
        _service.getPaymentMethods(),
      ]);
      routines.value = results[0] as List<Map<String, dynamic>>;
      students.value = results[1] as List<Map<String, dynamic>>;
      registrationFee.value = results[2] as Map<String, dynamic>;
      paymentMethods.value = results[3] as List<String>;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Failed to load routines.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    try {
      routines.value = await _service.getMyRoutines();
    } catch (_) {}
  }

  List<Map<String, dynamic>> get filteredRoutines {
    final _ = routines.length;
    return routines.where((r) {
      // Student filter
      if (selectedStudentId.value != 'All') {
        if (r['studentId']?.toString() != selectedStudentId.value) return false;
      }
      // Payment filter
      if (selectedPaymentFilter.value != 'All') {
        final payStatus =
            r['payment']?['paymentStatus']?.toString().toLowerCase() ?? '';
        if (selectedPaymentFilter.value == 'Paid' && payStatus != 'paid') {
          return false;
        }
        if (selectedPaymentFilter.value == 'Pending' && payStatus == 'paid') {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // Fee calculation
  double getGrandTotal(Map<String, dynamic> routine) {
    final payment = routine['payment'] as Map<String, dynamic>? ?? {};
    // amountDue from API already includes registration fee (calculated by backend)
    final amountDue = double.tryParse(payment['amountDue']?.toString() ?? '0') ?? 0;
    if (amountDue > 0) return amountDue; // Use backend-calculated total directly
    
    // Fallback: calculate from routineFee + extra
    final baseFee = double.tryParse(
        routine['routine']?['routineFee']?.toString() ?? '0') ?? 0;
    return baseFee + _extraFeeTotal();
  }

  double _extraFeeTotal() {
    final fee = registrationFee.value;
    if (fee == null) return 0;
    final components = fee['feeComponents'];
    if (components is List) {
      return components.fold<double>(
          0, (sum, c) => sum + (double.tryParse(c['amount']?.toString() ?? '0') ?? 0));
    }
    return double.tryParse(fee['totalAmount']?.toString() ?? '0') ?? 0;
  }

  List<Map<String, dynamic>> get feeComponentsList {
    final fee = registrationFee.value;
    if (fee == null) return [];
    final components = fee['feeComponents'];
    if (components is List) return List<Map<String, dynamic>>.from(components);
    return [];
  }

  // Pay routine
  Future<void> payRoutine(int paymentId) async {
    isPaying.value = true;
    try {
      final method = paymentMethods.isNotEmpty ? paymentMethods.first : 'stripe';
      final result = await _service.payRoutine(paymentId, paymentMethod: method);

      print('💰 [ROUTINE PAY] Response: $result');

      // Doc says: transactionId contains the clientSecret (has _secret_ in it)
      final clientSecret = result['clientSecret']?.toString() ??
          result['transactionId']?.toString() ?? '';
      final approvalUrl = result['approvalUrl']?.toString() ?? '';
      final orderId = result['orderId']?.toString() ??
          result['paymentIntentId']?.toString() ??
          result['transactionId']?.toString() ?? '';

      // Check clientSecret is actually valid
      final hasValidSecret = clientSecret.isNotEmpty &&
          clientSecret != 'null' &&
          clientSecret.contains('_secret_');

      if (hasValidSecret) {
        // In-app Stripe Payment Sheet
        final success = await StripePaymentService.instance
            .presentPaymentSheet(clientSecret: clientSecret);
        if (success) {
          try {
            // For capture, use the full transactionId as orderId
            await _service.capturePayment(orderId: clientSecret, paymentId: paymentId);
          } catch (_) {}
          await refresh();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar('Success', 'Routine payment confirmed!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success, colorText: Colors.white);
          });
        }
      } else if (approvalUrl.isNotEmpty) {
        // This should NOT happen if backend returns clientSecret properly
        print('⚠️ [ROUTINE PAY] clientSecret was empty! Got approvalUrl instead. Check backend.');
        final uri = Uri.parse(approvalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        Future.delayed(const Duration(seconds: 3), () => refresh());
      } else {
        await refresh();
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Success', 'Routine payment processed!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.success, colorText: Colors.white);
        });
      }
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isPaying.value = false;
    }
  }
}
