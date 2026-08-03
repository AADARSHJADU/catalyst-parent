import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/core/services/stripe_payment_service.dart';
import 'package:catalyst/data/services/competition_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CompetitionsNewController extends GetxController {
  final CompetitionService _service = Get.find<CompetitionService>();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final currentTab = 0.obs; // 0=Upcoming, 1=My Registrations, 2=Past Results
  final isPaying = false.obs;

  final competitions = <Map<String, dynamic>>[].obs;
  final myRegistrations = <Map<String, dynamic>>[].obs;
  final pastResults = <Map<String, dynamic>>[].obs;
  final students = <Map<String, dynamic>>[].obs;
  final registrationFee = Rxn<Map<String, dynamic>>();

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
        _service.getCompetitions(),
        _service.getMyRegistrations(),
        _service.getPastResults(),
        _service.getStudents(),
        _service.getRegistrationFee(),
      ]);
      competitions.value = results[0] as List<Map<String, dynamic>>;
      myRegistrations.value = results[1] as List<Map<String, dynamic>>;
      pastResults.value = results[2] as List<Map<String, dynamic>>;
      students.value = results[3] as List<Map<String, dynamic>>;
      registrationFee.value = results[4] as Map<String, dynamic>;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Failed to load competitions.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => _loadAll();

  double getGrandTotal(double entryFee) {
    final fee = registrationFee.value;
    double extra = 0;
    if (fee != null) {
      final components = fee['feeComponents'];
      if (components is List) {
        extra = components.fold<double>(0, (s, c) =>
            s + (double.tryParse(c['amount']?.toString() ?? '0') ?? 0));
      } else {
        extra = double.tryParse(fee['totalAmount']?.toString() ?? '0') ?? 0;
      }
    }
    return entryFee + extra;
  }

  List<Map<String, dynamic>> get feeComponents {
    final fee = registrationFee.value;
    if (fee == null) return [];
    final c = fee['feeComponents'];
    if (c is List) return List<Map<String, dynamic>>.from(c);
    return [];
  }

  String registrationStatus(int competitionId) {
    final reg = myRegistrations.firstWhereOrNull(
        (r) => r['competitionId'] == competitionId);
    return reg?['status']?.toString() ?? 'Not Registered';
  }

  Future<void> payCompetition(int id, {int? studentId}) async {
    isPaying.value = true;
    try {
      final result = await _service.payCompetition(id,
          paymentMethod: 'stripe', studentId: studentId);

      final clientSecret = result['clientSecret']?.toString() ?? '';
      final approvalUrl = result['approvalUrl']?.toString() ?? '';
      final orderId = result['orderId']?.toString() ??
          result['gatewayOrderId']?.toString() ??
          result['paymentIntentId']?.toString() ?? '';

      if (clientSecret.isNotEmpty) {
        // In-app Stripe Payment Sheet
        final success = await StripePaymentService.instance
            .presentPaymentSheet(clientSecret: clientSecret);
        if (success) {
          // Capture on backend
          try {
            final paymentId = result['paymentId'] as int? ?? id;
            await _service.capturePayment(orderId: orderId, paymentId: paymentId);
          } catch (_) {}
          await refresh();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar('Success', 'Competition registration confirmed!',
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
      } else {
        await refresh();
        Get.snackbar('Success', 'Competition payment processed!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success, colorText: Colors.white);
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
