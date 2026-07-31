import 'package:catalyst/modules/routines/controllers/routines_controller.dart';
import 'package:get/get.dart';

class RoutinesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(RoutinesController.new);
  }
}
