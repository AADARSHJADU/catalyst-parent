import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Legacy view — history is now shown in My Bookings tab.
class LessonHistoryView extends GetView<PrivateLessonsController> {
  const LessonHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.currentTab.value = 1;
      Get.back();
    });
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
