import 'package:catalyst/data/services/private_booking_service.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:get/get.dart';

class PrivateLessonsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(PrivateBookingService.new);
    Get.lazyPut(PrivateLessonsController.new);
  }
}
