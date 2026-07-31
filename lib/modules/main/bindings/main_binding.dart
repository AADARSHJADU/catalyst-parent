import 'package:catalyst/modules/auth/controllers/auth_controller.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:catalyst/modules/messages/controllers/messages_controller.dart';
import 'package:get/get.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(MainController.new);
    Get.lazyPut(HomeController.new);
    Get.lazyPut(ScheduleController.new);
    Get.lazyPut(BookingsController.new);
    Get.lazyPut(MessagesController.new);
    Get.lazyPut(MoreController.new);
    // Needed for sign-out from the More tab
    Get.lazyPut(AuthController.new);
  }
}
