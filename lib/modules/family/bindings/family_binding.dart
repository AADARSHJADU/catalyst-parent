import 'package:catalyst/modules/family/controllers/family_controller.dart';
import 'package:get/get.dart';

class FamilyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(FamilyController.new);
  }
}
