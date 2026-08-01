import 'package:catalyst/modules/student_progress/controllers/student_progress_controller.dart';
import 'package:get/get.dart';

class StudentProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentProgressController>(
      () => StudentProgressController(),
    );
  }
}
