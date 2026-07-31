import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/data/services/storage_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    // If a token is already saved → go directly to main screen
    final storage = Get.find<StorageService>();
    if (storage.hasToken) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
