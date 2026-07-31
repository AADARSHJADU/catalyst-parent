import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/core/services/fcm_service.dart';
import 'package:catalyst/data/models/api_user_model.dart';
import 'package:catalyst/data/services/auth_service.dart';
import 'package:catalyst/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  // ── Text controllers ───────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // OTP & reset password
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  // ── Observables ────────────────────────────────────────────────────────────
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmNewPasswordVisible = false.obs;
  final isLoading = false.obs;

  /// Logged-in user from API (null when unauthenticated)
  final currentUser = Rxn<ApiUserModel>();

  // ── Services ───────────────────────────────────────────────────────────────
  final _authService = AuthService();
  final _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
  }

  // ── Visibility toggles ─────────────────────────────────────────────────────
  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  void toggleNewPasswordVisibility() =>
      isNewPasswordVisible.value = !isNewPasswordVisible.value;

  void toggleConfirmNewPasswordVisibility() =>
      isConfirmNewPasswordVisible.value = !isConfirmNewPasswordVisible.value;

  // ── Sign In ────────────────────────────────────────────────────────────────
  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      await _storage.saveToken(result.token);
      await _storage.saveUser(result.user.toJson());
      currentUser.value = result.user;
      // Upload FCM token to backend after successful login
      await FcmService.instance.uploadTokenToBackend();
      Get.offAllNamed(AppRoutes.main);
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill all required fields');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authService.register(
        fullName: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        // role: 'parent' is sent internally by AuthService — not passed here
      );
      await _storage.saveToken(result.token);
      await _storage.saveUser(result.user.toJson());
      currentUser.value = result.user;
      // Upload FCM token to backend after successful registration
      await FcmService.instance.uploadTokenToBackend();
      Get.offAllNamed(AppRoutes.main);
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────────────
  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.forgotPassword(email: email);
      Get.toNamed(AppRoutes.verifyOtp);
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Verify OTP ─────────────────────────────────────────────────────────────
  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      _showError('Please enter the OTP');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.verifyOtp(token: otp);
      Get.toNamed(AppRoutes.resetPassword);
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Reset Password (with token) ────────────────────────────────────────────
  Future<void> confirmResetPassword() async {
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text;
    final confirmNewPassword = confirmNewPasswordController.text;

    if (newPassword.isEmpty || confirmNewPassword.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    if (newPassword != confirmNewPassword) {
      _showError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.resetPassword(token: otp, password: newPassword);
      Get.snackbar(
        'Success',
        'Password reset successfully. Please sign in.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.login);
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _storage.clearAll();   // token + saara local data clear
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);  // stack clear karke login pe le jao
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void browseSchedule() => Get.toNamed(AppRoutes.classSchedule);

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }
}
