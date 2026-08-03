import 'package:catalyst/data/services/regular_class_service.dart';
import 'package:catalyst/modules/regular_classes/controllers/regular_classes_controller.dart';
import 'package:get/get.dart';

class RegularClassesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(RegularClassService.new);
    Get.lazyPut(RegularClassesController.new);
  }
}
