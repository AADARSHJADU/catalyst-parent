import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:get/get.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ScheduleController>()) {
      Get.lazyPut(ScheduleController.new);
    }
  }
}
