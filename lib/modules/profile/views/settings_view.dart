import 'dart:io';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Settings View — Full API Integration
// ══════════════════════════════════════════════════════════════════════════════
class SettingsView extends GetView<ProfileController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Settings'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: controller.refreshProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              const SizedBox(height: 4),
              Text('Settings',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(
                'Manage your account, preferences, and security settings.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _AccountSettingsCard(),
              const SizedBox(height: 14),
              _NotificationsCard(),
              const SizedBox(height: 14),
              _SecurityCard(),
              const SizedBox(height: 20),
              _FooterInfo(),
            ],
          ),
        );
      }),
    );
  }
}

// ── Footer Info ────────────────────────────────────────────────────────────────
class _FooterInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please contact the front desk or email support@catalystdance.com to update any information.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Account Settings card ──────────────────────────────────────────────────────
class _AccountSettingsCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Account Settings',
            subtitle:
                'Update your personal information and account preferences.',
            onEdit: () => _showEditSheet(context),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          // Avatar row
          Row(
            children: [
              GestureDetector(
                onTap: () => _pickProfileImage(),
                child: Stack(
                  children: [
                    Obx(() {
                      final picPath = controller.selectedImagePath.value;
                      if (picPath.isNotEmpty) {
                        return CircleAvatar(
                          radius: 34,
                          backgroundImage: FileImage(File(picPath)),
                        );
                      }
                      final picUrl = controller.profilePicUrl.value;
                      if (picUrl.isNotEmpty && picUrl.startsWith('http')) {
                        return CircleAvatar(
                          radius: 34,
                          backgroundImage: NetworkImage(picUrl),
                        );
                      }
                      final name = controller.fullName.value;
                      final initials = name.isNotEmpty
                          ? name
                              .split(' ')
                              .where((p) => p.isNotEmpty)
                              .map((p) => p[0])
                              .take(2)
                              .join()
                          : '?';
                      return CircleAvatar(
                        radius: 34,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          initials,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.border, width: 1.5),
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.fullName.value,
                            style:
                                Theme.of(context).textTheme.titleMedium),
                        Text(controller.email.value,
                            style:
                                Theme.of(context).textTheme.bodySmall),
                        Text(controller.relationship.value,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.primary)),
                      ],
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          // Fields
          Obx(() => Column(
                children: [
                  _FieldRow(
                      label: 'Full Name',
                      value: controller.fullName.value),
                  _FieldRow(
                      label: 'Email', value: controller.email.value),
                  _FieldRow(
                      label: 'Phone', value: controller.phone.value),
                  _FieldRow(
                      label: 'Preferred Contact',
                      value: controller.preferredContact.value),
                  _FieldRow(
                      label: 'Relationship',
                      value: controller.relationship.value),
                  _FieldRow(
                      label: 'Address',
                      value: controller.address.value),
                  _FieldRow(
                      label: 'Date of Birth',
                      value: controller.dateOfBirth.value),
                  _FieldRow(
                      label: 'Language',
                      value: controller.language.value),
                ],
              )),
        ],
      ),
    );
  }

  void _pickProfileImage() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update Profile Photo',
                style: Get.textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () async {
                Get.back();
                final picked = await ImagePicker()
                    .pickImage(source: ImageSource.camera, imageQuality: 80);
                if (picked != null) {
                  controller.selectedImagePath.value = picked.path;
                  controller.saveAccountSettings(
                      profilePicFile: File(picked.path));
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () async {
                Get.back();
                final picked = await ImagePicker()
                    .pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) {
                  controller.selectedImagePath.value = picked.path;
                  controller.saveAccountSettings(
                      profilePicFile: File(picked.path));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final firstNameCtrl =
        TextEditingController(text: controller.firstName.value);
    final lastNameCtrl =
        TextEditingController(text: controller.lastName.value);
    final emailCtrl =
        TextEditingController(text: controller.email.value);
    final phoneCtrl =
        TextEditingController(text: controller.phone.value);
    final address1Ctrl =
        TextEditingController(text: controller.profile.value?.address1 ?? '');
    final cityCtrl =
        TextEditingController(text: controller.city.value);
    final stateCtrl =
        TextEditingController(text: controller.state.value);
    final zipCtrl =
        TextEditingController(text: controller.zip.value);
    final emergencyCtrl =
        TextEditingController(text: controller.emergencyContact.value);
    final dobCtrl =
        TextEditingController(text: controller.dateOfBirth.value);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (_, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.all(20),
            children: [
              _DragHandle(),
              Text('Edit Account Settings',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              _EditField(label: 'First Name', controller: firstNameCtrl),
              _EditField(label: 'Last Name', controller: lastNameCtrl),
              _EditField(label: 'Email', controller: emailCtrl),
              _EditField(label: 'Phone', controller: phoneCtrl),
              _EditField(label: 'Date of Birth (YYYY-MM-DD)', controller: dobCtrl),
              _EditField(label: 'Address', controller: address1Ctrl),
              _EditField(label: 'City', controller: cityCtrl),
              _EditField(label: 'State', controller: stateCtrl),
              _EditField(label: 'Zip', controller: zipCtrl),
              _EditField(label: 'Emergency Contact', controller: emergencyCtrl),
              const SizedBox(height: 8),
              // Preferred Contact picker
              Obx(() => _PickerField(
                    label: 'Preferred Contact',
                    value: controller.preferredContact.value,
                    options: controller.contactOptions,
                    onChanged: (v) =>
                        controller.preferredContact.value = v,
                  )),
              const SizedBox(height: 8),
              Obx(() => _PickerField(
                    label: 'Relationship',
                    value: controller.relationship.value,
                    options: controller.relationshipOptions,
                    onChanged: (v) => controller.setRelationship(v),
                  )),
              const SizedBox(height: 8),
              Obx(() => _PickerField(
                    label: 'Language',
                    value: controller.language.value,
                    options: controller.languageOptions,
                    onChanged: (v) => controller.setLanguage(v),
                  )),
              const SizedBox(height: 20),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () {
                              controller.firstName.value =
                                  firstNameCtrl.text.trim();
                              controller.lastName.value =
                                  lastNameCtrl.text.trim();
                              controller.fullName.value =
                                  '${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}';
                              controller.email.value =
                                  emailCtrl.text.trim();
                              controller.phone.value =
                                  phoneCtrl.text.trim();
                              controller.dateOfBirth.value =
                                  dobCtrl.text.trim();
                              controller.address.value =
                                  address1Ctrl.text.trim();
                              controller.city.value =
                                  cityCtrl.text.trim();
                              controller.state.value =
                                  stateCtrl.text.trim();
                              controller.zip.value =
                                  zipCtrl.text.trim();
                              controller.emergencyContact.value =
                                  emergencyCtrl.text.trim();
                              Get.back();
                              controller.saveAccountSettings();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Notification Preferences card ─────────────────────────────────────────────
class _NotificationsCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Notification Preferences',
            subtitle:
                'Choose how and when you want to receive notifications.',
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          Obx(() => _NotifRow(
                icon: Icons.calendar_today_outlined,
                title: 'Booking Requests',
                subtitle: 'Notifications about booking confirmations and requests.',
                value: controller.notifyBookingRequests.value,
                onChanged: (v) {
                  controller.notifyBookingRequests.value = v;
                  controller.saveNotificationPreferences();
                },
              )),
          const Divider(height: 1, color: AppColors.border),
          Obx(() => _NotifRow(
                icon: Icons.schedule_outlined,
                title: 'Schedule Changes',
                subtitle: 'Alerts about class schedule changes or cancellations.',
                value: controller.notifyScheduleChanges.value,
                onChanged: (v) {
                  controller.notifyScheduleChanges.value = v;
                  controller.saveNotificationPreferences();
                },
              )),
          const Divider(height: 1, color: AppColors.border),
          Obx(() => _NotifRow(
                icon: Icons.how_to_reg_outlined,
                title: 'Attendance Alerts',
                subtitle: 'Notifications about student attendance records.',
                value: controller.notifyAttendanceAlerts.value,
                onChanged: (v) {
                  controller.notifyAttendanceAlerts.value = v;
                  controller.saveNotificationPreferences();
                },
              )),
          const Divider(height: 1, color: AppColors.border),
          Obx(() => _NotifRow(
                icon: Icons.campaign_outlined,
                title: 'Studio Updates',
                subtitle: 'General announcements and studio news.',
                value: controller.notifyStudioUpdates.value,
                onChanged: (v) {
                  controller.notifyStudioUpdates.value = v;
                  controller.saveNotificationPreferences();
                },
              )),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text('Delivery Channels',
                style: Theme.of(context).textTheme.titleSmall),
          ),
          Obx(() => _NotifRow(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle:
                    'Receive important updates and notifications via email.',
                value: controller.emailNotifications.value,
                onChanged: (v) {
                  controller.emailNotifications.value = v;
                  controller.saveNotificationPreferences();
                },
              )),
          const Divider(height: 1, color: AppColors.border),
          Obx(() => _NotifRow(
                icon: Icons.sms_outlined,
                title: 'SMS Notifications',
                subtitle: 'Receive important updates via text message.',
                value: controller.smsNotifications.value,
                onChanged: (v) {
                  controller.smsNotifications.value = v;
                  controller.saveNotificationPreferences();
                },
              )),
          const Divider(height: 1, color: AppColors.border),
          Obx(() => _NotifRow(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle:
                    'Receive important updates in your browser or app.',
                value: controller.pushNotifications.value,
                onChanged: (v) {
                  controller.pushNotifications.value = v;
                  controller.saveNotificationPreferences();
                },
              )),
        ],
      ),
    );
  }
}

// ── Notification Row ──────────────────────────────────────────────────────────
class _NotifRow extends StatelessWidget {
  const _NotifRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textPrimary)),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Text(
                value ? 'On' : 'Off',
                style: TextStyle(
                    color:
                        value ? AppColors.success : AppColors.textMuted,
                    fontSize: 12),
              ),
              const SizedBox(width: 6),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.success,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.textMuted,
                  materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Password & Security card ───────────────────────────────────────────────────
class _SecurityCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Password & Security',
            subtitle: 'Manage your password and security settings.',
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          // Password row
          Row(
            children: [
              const Icon(Icons.lock_outline,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Password',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textPrimary)),
                    const Text('••••••••',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            letterSpacing: 3)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => _showChangePasswordSheet(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Change Password',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          // 2FA row
          Row(
            children: [
              const Icon(Icons.security_outlined,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Two-Factor Authentication',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textPrimary)),
                    Text(
                        'Add an extra layer of security to your account.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (controller.twoFactorEnabled.value
                              ? AppColors.success
                              : AppColors.textMuted)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                        controller.twoFactorEnabled.value
                            ? 'Enabled'
                            : 'Disabled',
                        style: TextStyle(
                            color: controller.twoFactorEnabled.value
                                ? AppColors.success
                                : AppColors.textMuted,
                            fontSize: 11)),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final obscureCurrent = true.obs;
    final obscureNew = true.obs;
    final obscureConfirm = true.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          builder: (_, scroll) => Form(
            key: formKey,
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              children: [
                _DragHandle(),
                Text('Change Password',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Enter your current password and choose a new one.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Obx(() => _PasswordField(
                      label: 'Current Password',
                      controller: currentPwCtrl,
                      obscure: obscureCurrent.value,
                      onToggle: () =>
                          obscureCurrent.value = !obscureCurrent.value,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter current password'
                          : null,
                    )),
                const SizedBox(height: 14),
                Obx(() => _PasswordField(
                      label: 'New Password',
                      controller: newPwCtrl,
                      obscure: obscureNew.value,
                      onToggle: () =>
                          obscureNew.value = !obscureNew.value,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter new password';
                        }
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 14),
                Obx(() => _PasswordField(
                      label: 'Confirm New Password',
                      controller: confirmPwCtrl,
                      obscure: obscureConfirm.value,
                      onToggle: () =>
                          obscureConfirm.value = !obscureConfirm.value,
                      validator: (v) {
                        if (v != newPwCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 24),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isChangingPassword.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                final success =
                                    await controller.changePassword(
                                  currentPassword:
                                      currentPwCtrl.text.trim(),
                                  newPassword: newPwCtrl.text.trim(),
                                );
                                if (success && Get.isBottomSheetOpen == true) {
                                  Get.back();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: controller.isChangingPassword.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Text('Update Password'),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Password Field widget ─────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onEdit,
  });
  final String title;
  final String subtitle;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (onEdit != null)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined,
                size: 14, color: AppColors.primary),
            label: const Text('Edit',
                style:
                    TextStyle(color: AppColors.primary, fontSize: 12)),
          ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
                value.isEmpty ? '—' : value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> options;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _pick(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(value.isEmpty ? 'Select...' : value,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textPrimary)),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pick(BuildContext context) {
    if (options.isEmpty) {
      Get.snackbar('Info', 'No options available',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ...options.map((opt) => ListTile(
                dense: true,
                title: Text(opt,
                    style: TextStyle(
                        color: opt == value
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 14)),
                trailing: opt == value
                    ? const Icon(Icons.check,
                        color: AppColors.primary, size: 16)
                    : null,
                onTap: () {
                  onChanged(opt);
                  Get.back();
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}
