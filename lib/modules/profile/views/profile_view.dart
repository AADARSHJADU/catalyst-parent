import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Student Profile View
// ══════════════════════════════════════════════════════════════════════════════
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Student Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const SizedBox(height: 4),
          Text('Student Profile',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text('View and manage your personal information and enrollments.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),

          // ── Hero card ──────────────────────────────────────────────
          _HeroCard(),
          const SizedBox(height: 14),

          // ── Personal Info ──────────────────────────────────────────
          _PersonalInfoCard(),
          const SizedBox(height: 14),

          // ── Emergency Contacts ─────────────────────────────────────
          _EmergencyContactsCard(),
          const SizedBox(height: 14),

          // ── Medical Notes ──────────────────────────────────────────
          _MedicalNotesCard(),
          const SizedBox(height: 20),

          // Footer note
          _FooterNote(),
        ],
      ),
    );
  }
}

// ── Hero card ──────────────────────────────────────────────────────────────────
class _HeroCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      controller.studentName.value
                          .split(' ')
                          .map((p) => p[0])
                          .join(),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.border, width: 1.5),
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          size: 14, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => Text(
                                controller.studentName.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              )),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.success
                                    .withValues(alpha: 0.3)),
                          ),
                          child: const Text('Active',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Dancer ID: ${controller.studentId}',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text('Member since: ${controller.memberSince}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    // Edit Profile button
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showEditProfile(context),
                      icon: const Icon(Icons.edit_outlined,
                          size: 14, color: AppColors.primary),
                      label: const Text('Edit Profile',
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: Size.zero,
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              _StatTile(
                icon: Icons.cake_outlined,
                label: 'Date of Birth',
                value: controller.dob.value,
              ),
              _StatTile(
                icon: Icons.person_outlined,
                label: 'Age',
                value: controller.age,
              ),
              Obx(() => _StatTile(
                    icon: Icons.bar_chart_outlined,
                    label: 'Level',
                    value: controller.level.value,
                  )),
              Obx(() => _StatTile(
                    icon: Icons.checkroom_outlined,
                    label: 'T-Shirt Size',
                    value: controller.tShirtSize.value,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    Get.snackbar('Edit Profile',
        'Profile editing will be available with backend.',
        snackPosition: SnackPosition.BOTTOM);
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Personal Info card ─────────────────────────────────────────────────────────
class _PersonalInfoCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_outline,
                    size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal Information',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('View and update your personal details.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => Get.snackbar('Edit',
                    'Information editing available with backend.',
                    snackPosition: SnackPosition.BOTTOM),
                icon: const Icon(Icons.edit_outlined,
                    size: 14, color: AppColors.primary),
                label: const Text('Edit Information',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          // 2-column info grid
          Obx(() => _InfoGrid(items: [
                _InfoItem('Full Name', controller.studentName.value),
                _InfoItem('School', controller.school.value),
                _InfoItem('Date of Birth', controller.dob.value),
                _InfoItem('Grade', controller.grade.value),
                _InfoItem('Gender', controller.gender.value),
                _InfoItem('Allergies', controller.allergies.value),
                _InfoItem('Address', controller.studentAddress.value),
                _InfoItem('Birth City', controller.birthCity.value),
                _InfoItem('Phone', controller.studentPhone.value),
                _InfoItem('Preferred Contact', 'Email'),
                _InfoItem('Email', controller.studentEmail.value),
                _InfoItem('Parent/Guardian', controller.guardian.value),
              ])),
        ],
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);
  final String label;
  final String value;
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    // Pair items into rows of 2
    final rows = <List<_InfoItem>>[];
    for (int i = 0; i < items.length; i += 2) {
      rows.add([
        items[i],
        if (i + 1 < items.length) items[i + 1],
      ]);
    }
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: row.map((item) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 3),
                    Text(item.value,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textPrimary)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// ── Emergency Contacts card ────────────────────────────────────────────────────
class _EmergencyContactsCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite_border_outlined,
                    size: 16, color: AppColors.error),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency Contacts',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('Manage your emergency contacts.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => Get.snackbar(
                    'Add Contact', 'Contact management coming soon.',
                    snackPosition: SnackPosition.BOTTOM),
                icon: const Icon(Icons.add,
                    size: 14, color: AppColors.primary),
                label: const Text('Add Contact',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: controller.emergencyContacts
                    .map((c) => _ContactTile(contact: c))
                    .toList(),
              )),
          const Divider(height: 1, color: AppColors.border),
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text('View All Contacts',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              color: AppColors.textSecondary)),
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});
  final EmergencyContact contact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${contact.name} (${contact.relationship})',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textPrimary),
              ),
              if (contact.isPrimary) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primary
                            .withValues(alpha: 0.3)),
                  ),
                  child: const Text('Primary',
                      style: TextStyle(
                          color: AppColors.primary, fontSize: 10)),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: () => Get.snackbar('Edit',
                    'Contact editing coming soon.',
                    snackPosition: SnackPosition.BOTTOM),
                icon: const Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.textSecondary),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => Get.snackbar('Delete',
                    'Contact deletion coming soon.',
                    snackPosition: SnackPosition.BOTTOM),
                icon: const Icon(Icons.delete_outline,
                    size: 16, color: AppColors.error),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(contact.phone,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.email_outlined,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(contact.email,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Medical Notes card ─────────────────────────────────────────────────────────
class _MedicalNotesCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medical_information_outlined,
                    size: 16, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Medical Notes',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('Important medical information for your care.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => Get.snackbar(
                    'Edit Notes', 'Medical notes editing coming soon.',
                    snackPosition: SnackPosition.BOTTOM),
                icon: const Icon(Icons.edit_outlined,
                    size: 14, color: AppColors.primary),
                label: const Text('Edit Notes',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MedSection(
                      title: 'Medical Conditions',
                      content: controller.medicalConditions.value),
                  const SizedBox(height: 14),
                  _MedSection(
                      title: 'Medications',
                      content: controller.medications.value),
                  const SizedBox(height: 14),
                  _MedSection(
                      title: 'Additional Notes',
                      content: controller.additionalNotes.value),
                ],
              )),
        ],
      ),
    );
  }
}

class _MedSection extends StatelessWidget {
  const _MedSection({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(content,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                    color: AppColors.textSecondary, height: 1.6)),
      ],
    );
  }
}

// ── Footer note ────────────────────────────────────────────────────────────────
class _FooterNote extends StatelessWidget {
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
