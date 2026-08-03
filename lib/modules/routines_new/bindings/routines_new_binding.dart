import 'package:catalyst/data/services/routine_service.dart';
import 'package:catalyst/modules/routines_new/controllers/routines_controller.dart';
import 'package:get/get.dart';

class RoutinesNewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(RoutineService.new);
    Get.lazyPut(RoutinesNewController.new);
  }
}
