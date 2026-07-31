import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_assets.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/constants/app_strings.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/core/widgets/app_text_field.dart';
import 'package:catalyst/core/widgets/primary_button.dart';
import 'package:catalyst/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo Section
                Image.asset(
                  AppAssets.logo,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),

                // Description text
                Text(
                  AppStrings.heroDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Main Login Card
                AppCard(
                  padding: const EdgeInsets.all(24), // Internal padding for clean look
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Inputs card ke andar stretch honge (jo sahi hai)
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to manage your dancers, schedules, and bookings.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Email Field
                      AppTextField(
                        controller: controller.emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      // Password Field
                      Obx(
                            () => AppTextField(
                          controller: controller.passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          obscureText: !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password Link (Right aligned for better UX)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign In Button
                      Obx(
                            () => PrimaryButton(
                          label: 'Sign In',
                          isLoading: controller.isLoading.value,
                          useGradient: true,
                          onPressed: controller.signIn,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Create Account Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.register),
                            child: Text(
                              'Create one',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),

                      // Browsing Schedule Link
                      /*GestureDetector(
                        onTap: controller.browseSchedule,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: const [
                              TextSpan(text: 'Just browsing? '),
                              TextSpan(
                                text: 'See class schedule →',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),*/
                    ],
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