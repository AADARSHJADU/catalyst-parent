import 'package:catalyst/data/services/bookings_history_service.dart';
import 'package:catalyst/data/services/schedule_service.dart';
import 'package:catalyst/modules/auth/controllers/auth_controller.dart';
import 'package:catalyst/modules/bookings/controllers/bookings_controller.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:catalyst/modules/messages/controllers/messages_controller.dart';
import 'package:catalyst/modules/schedule_parent/controllers/parent_schedule_controller.dart';
import 'package:get/get.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(MainController.new);
    Get.lazyPut(HomeController.new);
    Get.lazyPut(ScheduleApiService.new);
    Get.lazyPut(ParentScheduleController.new);
    Get.lazyPut(BookingsHistoryService.new);
    Get.lazyPut(MyBookingsController.new);
    Get.lazyPut(MessagesController.new);
    Get.lazyPut(MoreController.new);
    Get.lazyPut(AuthController.new);
  }
}
