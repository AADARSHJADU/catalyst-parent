import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/core/widgets/app_text_field.dart';
import 'package:catalyst/core/widgets/primary_button.dart';
import 'package:catalyst/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordView extends GetView<AuthController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Set New Password',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your new password below.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                Obx(
                  () => AppTextField(
                    controller: controller.newPasswordController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    obscureText: !controller.isNewPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isNewPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: controller.toggleNewPasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Obx(
                  () => AppTextField(
                    controller: controller.confirmNewPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Re-enter new password',
                    obscureText:
                        !controller.isConfirmNewPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmNewPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed:
                          controller.toggleConfirmNewPasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Obx(
                  () => PrimaryButton(
                    label: 'Reset Password',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.confirmResetPassword,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
