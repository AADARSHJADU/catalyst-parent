import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/core/widgets/app_text_field.dart';
import 'package:catalyst/core/widgets/primary_button.dart';
import 'package:catalyst/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyOtpView extends GetView<AuthController> {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify OTP'),
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
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_outlined,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 16),

                Text(
                  'Check Your Email',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ve sent a 6-digit OTP to your email. Enter it below to continue.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                AppTextField(
                  controller: controller.otpController,
                  label: 'OTP Code',
                  hint: 'Enter the 6-digit code',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                Obx(
                  () => PrimaryButton(
                    label: 'Verify OTP',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.verifyOtp,
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
