import 'package:catalyst/data/services/competition_service.dart';
import 'package:catalyst/modules/competitions_new/controllers/competitions_controller.dart';
import 'package:get/get.dart';

class CompetitionsNewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(CompetitionService.new);
    Get.lazyPut(CompetitionsNewController.new);
  }
}
