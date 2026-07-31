import 'package:catalyst/data/services/notification_service.dart';
import 'package:catalyst/modules/notifications/controllers/notifications_controller.dart';
import 'package:get/get.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(NotificationApiService.new);
    Get.lazyPut(NotificationsController.new);
  }
}
