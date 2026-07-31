import 'package:catalyst/data/services/settings_service.dart';
import 'package:catalyst/modules/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(SettingsService.new);
    Get.lazyPut(ProfileController.new);
  }
}
