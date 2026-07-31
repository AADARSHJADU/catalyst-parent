import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:get/get.dart';

class BookingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingsController>()) {
      Get.lazyPut(BookingsController.new);
    }
  }
}
