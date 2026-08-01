import 'package:catalyst/data/services/bookings_history_service.dart';
import 'package:catalyst/modules/bookings/controllers/bookings_controller.dart';
import 'package:get/get.dart';

class BookingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingsHistoryService>()) {
      Get.lazyPut(BookingsHistoryService.new);
    }
    if (!Get.isRegistered<MyBookingsController>()) {
      Get.lazyPut(MyBookingsController.new);
    }
  }
}
