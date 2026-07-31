import 'dart:io';

import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/parent_profile_model.dart';
import 'package:catalyst/data/services/settings_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmergencyContact {
  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.email,
    this.isPrimary = false,
  });
  String name;
  String relationship;
  String phone;
  String email;
  bool isPrimary;
}

class ProfileController extends GetxController {
  final SettingsService _service = Get.find<SettingsService>();

  // ── Loading / Error states ─────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final isSaving = false.obs;

  // ── Profile data ───────────────────────────────────────────────────────
  final Rxn<ParentProfileModel> profile = Rxn<ParentProfileModel>();

  // ── Account settings (reactive for UI binding) ─────────────────────────
  final fullName = ''.obs;
  final firstName = ''.obs;
  final lastName = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final relationship = ''.obs;
  final address = ''.obs;
  final city = ''.obs;
  final state = ''.obs;
  final zip = ''.obs;
  final emergencyContact = ''.obs;
  final preferredContact = ''.obs;
  final language = ''.obs;
  final dateOfBirth = ''.obs;
  final notes = ''.obs;
  final profilePicUrl = ''.obs;
  final selectedImagePath = ''.obs;

  // ── Notifications ──────────────────────────────────────────────────────
  final notifyBookingRequests = true.obs;
  final notifyScheduleChanges = true.obs;
  final notifyAttendanceAlerts = false.obs;
  final notifyStudioUpdates = true.obs;
  final emailNotifications = true.obs;
  final smsNotifications = false.obs;
  final pushNotifications = true.obs;

  // ── Password & Security ────────────────────────────────────────────────
  final twoFactorEnabled = false.obs;
  final lastPasswordChange = '';
  final isChangingPassword = false.obs;

  // ── Lookup data ────────────────────────────────────────────────────────
  final relationships = <LookupItem>[].obs;
  final languages = <LookupItem>[].obs;
  int? selectedRelationshipId;
  int? selectedLanguageId;

  // ── Dropdown options (derived from API lookups) ────────────────────────
  List<String> get relationshipOptions =>
      relationships.map((r) => r.name).toList();

  List<String> get languageOptions =>
      languages.map((l) => l.name).toList();

  final contactOptions = const ['Email', 'Phone', 'SMS', 'WhatsApp'];

  // Legacy alias used in other profile views
  final timezone = '(GMT-05:00) Eastern Time (US & Canada)'.obs;

  // ── Student profile (used by ProfileView / StudentProfile) ─────────────
  final studentName = 'Jasmine Johnson'.obs;
  final studentId = 'CD-2024-1047';
  final memberSince = 'Aug 15, 2023';
  final dob = 'May 12, 2012'.obs;
  final age = '12';
  final level = 'Intermediate'.obs;
  final tShirtSize = 'Youth M'.obs;
  final gender = 'Female'.obs;
  final studentAddress = '123 Dance Lane, Orlando, FL 32801'.obs;
  final studentPhone = '(555) 123-4567'.obs;
  final studentEmail = 'jasmine.johnson@email.com'.obs;
  final school = 'Orlando Middle School'.obs;
  final grade = '7th Grade'.obs;
  final allergies = 'Peanuts'.obs;
  final birthCity = 'Orlando, FL'.obs;
  final guardian = 'Sarah Johnson'.obs;

  // Medical notes
  final medicalConditions =
      'Mild asthma (exercise-induced)\nUses inhaler as needed.'.obs;
  final medications = 'Albuterol inhaler as needed'.obs;
  final additionalNotes =
      'Please ensure hydration during long rehearsals and notify if any breathing issues occur.'
          .obs;

  // Emergency contacts
  final emergencyContacts = <EmergencyContact>[
    EmergencyContact(
      name: 'Sarah Johnson',
      relationship: 'Mother',
      phone: '(555) 123-4567',
      email: 'sarah.johnson@email.com',
      isPrimary: true,
    ),
    EmergencyContact(
      name: 'Michael Johnson',
      relationship: 'Father',
      phone: '(555) 987-6543',
      email: 'michael.johnson@email.com',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  // ── Load everything on init ────────────────────────────────────────────
  Future<void> _loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Fetch lookups and profile in parallel
      final results = await Future.wait([
        _service.getRelationships(),
        _service.getLanguages(),
        _service.getProfile(),
      ]);

      relationships.value = results[0] as List<LookupItem>;
      languages.value = results[1] as List<LookupItem>;
      final profileData = results[2] as ParentProfileModel;
      _applyProfile(profileData);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh profile data (can be called on pull-to-refresh)
  Future<void> refreshProfile() async {
    try {
      final profileData = await _service.getProfile();
      _applyProfile(profileData);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  // ── Apply profile data to reactive variables ───────────────────────────
  void _applyProfile(ParentProfileModel data) {
    profile.value = data;
    firstName.value = data.user.firstName;
    lastName.value = data.user.lastName;
    fullName.value = data.user.fullName;
    email.value = data.user.email;
    phone.value = data.user.phone ?? '';
    profilePicUrl.value = data.user.profilePic ?? '';
    selectedImagePath.value = ''; // Clear local pick after server update

    selectedRelationshipId = data.relationshipId;
    selectedLanguageId = data.languageId;

    // Resolve relationship name from lookup
    if (data.relationshipId != null && relationships.isNotEmpty) {
      final match = relationships.firstWhereOrNull(
          (r) => r.id == data.relationshipId);
      relationship.value = match?.name ?? '';
    }

    // Resolve language name from lookup
    if (data.languageId != null && languages.isNotEmpty) {
      final match =
          languages.firstWhereOrNull((l) => l.id == data.languageId);
      language.value = match?.name ?? '';
    }

    // Date of birth
    if (data.dateOfBirth != null && data.dateOfBirth!.isNotEmpty) {
      dateOfBirth.value = data.dateOfBirth!.split('T').first;
    }

    // Address
    final parts = <String>[];
    if (data.address1 != null && data.address1!.isNotEmpty) {
      parts.add(data.address1!);
    }
    if (data.city != null && data.city!.isNotEmpty) parts.add(data.city!);
    if (data.state != null && data.state!.isNotEmpty) parts.add(data.state!);
    if (data.zip != null && data.zip!.isNotEmpty) parts.add(data.zip!);
    address.value = parts.join(', ');
    city.value = data.city ?? '';
    state.value = data.state ?? '';
    zip.value = data.zip ?? '';

    emergencyContact.value = data.emergencyContact ?? '';
    preferredContact.value = data.preferredContactMethod ?? 'Email';
    notes.value = data.notes ?? '';

    // Notifications
    notifyBookingRequests.value = data.notifyBookingRequests;
    notifyScheduleChanges.value = data.notifyScheduleChanges;
    notifyAttendanceAlerts.value = data.notifyAttendanceAlerts;
    notifyStudioUpdates.value = data.notifyStudioUpdates;
    emailNotifications.value = data.emailNotifications;
    smsNotifications.value = data.smsNotifications;
    pushNotifications.value = data.pushNotifications;
  }

  // ── Save Account Settings ──────────────────────────────────────────────
  Future<void> saveAccountSettings({File? profilePicFile}) async {
    isSaving.value = true;
    try {
      ParentProfileModel updatedProfile;

      if (profilePicFile != null) {
        // Use FormData for file upload
        final formData = dio.FormData.fromMap({
          'first_name': firstName.value,
          'last_name': lastName.value,
          'email': email.value,
          'phone': phone.value,
          'date_of_birth': dateOfBirth.value,
          'relationship_id': selectedRelationshipId,
          'language_id': selectedLanguageId,
          'address1': _extractAddress1(),
          'city': city.value,
          'state': state.value,
          'zip': zip.value,
          'emergency_contact': emergencyContact.value,
          'preferred_contact_method': preferredContact.value,
          'notes': notes.value,
          'profile_pic': await dio.MultipartFile.fromFile(
            profilePicFile.path,
            filename: profilePicFile.path.split('/').last,
          ),
        });
        updatedProfile = await _service.updateProfileWithFormData(formData);
      } else {
        // JSON body (no file)
        final body = <String, dynamic>{
          'first_name': firstName.value,
          'last_name': lastName.value,
          'email': email.value,
          'phone': phone.value,
          'date_of_birth': dateOfBirth.value,
          'relationship_id': selectedRelationshipId,
          'language_id': selectedLanguageId,
          'address1': _extractAddress1(),
          'city': city.value,
          'state': state.value,
          'zip': zip.value,
          'emergency_contact': emergencyContact.value,
          'preferred_contact_method': preferredContact.value,
          'notes': notes.value,
        };
        updatedProfile = await _service.updateProfile(body);
      }

      _applyProfile(updatedProfile);
      Get.snackbar('Success', 'Profile updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  // ── Save Notification Preferences ─────────────────────────────────────
  Future<void> saveNotificationPreferences() async {
    try {
      final body = <String, dynamic>{
        'notify_booking_requests': notifyBookingRequests.value,
        'notify_schedule_changes': notifyScheduleChanges.value,
        'notify_attendance_alerts': notifyAttendanceAlerts.value,
        'notify_studio_updates': notifyStudioUpdates.value,
        'email_notifications': emailNotifications.value,
        'sms_notifications': smsNotifications.value,
        'push_notifications': pushNotifications.value,
      };
      final updatedProfile = await _service.updateProfile(body);
      _applyProfile(updatedProfile);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  // ── Change Password ────────────────────────────────────────────────────
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    isChangingPassword.value = true;
    try {
      final message = await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      // Delay snackbar so bottom sheet closes first
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar('Success', message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white);
      });
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  String _extractAddress1() {
    // If address contains commas (city/state already in separate fields), take first part
    final addr = address.value;
    if (addr.contains(',')) return addr.split(',').first.trim();
    return addr;
  }

  /// Update selected relationship by name and store the id
  void setRelationship(String name) {
    relationship.value = name;
    final match = relationships.firstWhereOrNull((r) => r.name == name);
    selectedRelationshipId = match?.id;
  }

  /// Update selected language by name and store the id
  void setLanguage(String name) {
    language.value = name;
    final match = languages.firstWhereOrNull((l) => l.name == name);
    selectedLanguageId = match?.id;
  }
}
