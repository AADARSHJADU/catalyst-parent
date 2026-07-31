import 'package:catalyst/data/services/announcement_service.dart';
import 'package:catalyst/modules/announcements/controllers/announcements_controller.dart';
import 'package:get/get.dart';

class AnnouncementsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AnnouncementService.new);
    Get.lazyPut(AnnouncementsController.new);
  }
}
