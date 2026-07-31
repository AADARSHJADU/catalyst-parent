import 'package:catalyst/data/services/student_service.dart';
import 'package:catalyst/modules/student_profile/controllers/student_profile_controller.dart';
import 'package:get/get.dart';

class StudentProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(StudentService.new);
    Get.lazyPut(StudentProfileController.new);
  }
}
