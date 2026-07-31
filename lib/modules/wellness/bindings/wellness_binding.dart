import 'package:catalyst/modules/wellness/controllers/wellness_controller.dart';
import 'package:get/get.dart';

class WellnessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WellnessController>(() => WellnessController(), fenix: true);
  }
}
