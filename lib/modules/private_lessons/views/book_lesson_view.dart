import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Legacy view — booking is now handled through the new inline flow.
class BookLessonView extends GetView<PrivateLessonsController> {
  const BookLessonView({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to main private lessons screen (instructors tab)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.currentTab.value = 0;
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
