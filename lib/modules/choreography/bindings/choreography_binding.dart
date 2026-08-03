import 'package:catalyst/data/services/choreography_service.dart';
import 'package:catalyst/modules/choreography/controllers/choreography_controller.dart';
import 'package:get/get.dart';

class ChoreographyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ChoreographyService.new);
    Get.lazyPut(ChoreographyController.new);
  }
}
