import 'package:catalyst/data/services/wellness_api_service.dart';
import 'package:catalyst/modules/wellness_new/controllers/wellness_controller.dart';
import 'package:get/get.dart';

class WellnessNewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(WellnessApiService.new);
    Get.lazyPut(WellnessNewController.new);
  }
}
