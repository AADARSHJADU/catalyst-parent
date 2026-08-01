import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Legacy view — detail is now shown inline.
class PrivateLessonDetailView extends GetView<PrivateLessonsController> {
  const PrivateLessonDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Lesson Detail'),
      ),
      body: const Center(
        child: Text('This screen has been replaced by the new booking flow.',
            style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
