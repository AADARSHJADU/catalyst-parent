import 'package:catalyst/data/services/billing_service.dart';
import 'package:catalyst/modules/payments/controllers/payments_controller.dart';
import 'package:get/get.dart';

class PaymentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(BillingService.new);
    Get.lazyPut(PaymentsController.new);
  }
}
