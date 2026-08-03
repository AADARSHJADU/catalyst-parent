import 'package:catalyst/data/services/schedule_service.dart';
import 'package:catalyst/modules/schedule_parent/controllers/parent_schedule_controller.dart';
import 'package:get/get.dart';

class ParentScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ScheduleApiService.new);
    Get.lazyPut(ParentScheduleController.new);
  }
}
