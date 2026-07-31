import 'dart:io';

import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/student_model.dart';
import 'package:catalyst/modules/student_profile/controllers/student_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class StudentProfileView extends GetView<StudentProfileController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primary),
            tooltip: 'Add Student',
            onPressed: () => _showStudentForm(context, null),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildError(context);
        }
        if (controller.students.isEmpty) {
          return _buildEmpty(context);
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _StudentCard(student: controller.students[i]),
          ),
        );
      }),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.refresh,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_add_outlined,
              size: 56, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No students added yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Tap + to add your first student',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showStudentForm(context, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Student'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentForm(BuildContext context, StudentModel? student) {
    Get.to(() => _StudentFormPage(student: student));
  }
}

// ── Student Card ──────────────────────────────────────────────────────────────
class _StudentCard extends GetView<StudentProfileController> {
  const _StudentCard({required this.student});
  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (student.studentCode != null)
                      Text('ID: ${student.studentCode}',
                          style: Theme.of(context).textTheme.bodySmall),
                    if (student.ageGroup != null || student.level != null)
                      Text(
                        [
                          student.ageGroup?.name,
                          student.level?.name,
                        ].where((e) => e != null).join(' • '),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.primary),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (student.status ? AppColors.success : AppColors.textMuted)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  student.status ? 'Active' : 'Inactive',
                  style: TextStyle(
                      color: student.status
                          ? AppColors.success
                          : AppColors.textMuted,
                      fontSize: 11),
                ),
              ),
            ],
          ),
          if (student.danceStyles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: student.danceStyles
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(s.name,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (student.dobFormatted.isNotEmpty)
                      _infoChip(Icons.cake_outlined, student.dobFormatted),
                    if (student.gender != null)
                      _infoChip(Icons.person_outline, student.gender!),
                    if (student.studio != null)
                      _infoChip(Icons.location_on_outlined, student.studio!.name),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    Get.to(() => _StudentFormPage(student: student)),
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primary),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final pic = student.profilePicture;
    if (pic != null && pic.isNotEmpty && pic.startsWith('http')) {
      return CircleAvatar(
          radius: 26, backgroundImage: NetworkImage(pic));
    }
    final initials = student.fullName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join();
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      child: Text(
        initials,
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
          ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Student Form Page (Create / Edit) ─────────────────────────────────────────
class _StudentFormPage extends GetView<StudentProfileController> {
  const _StudentFormPage({this.student});
  final StudentModel? student;

  bool get isEditing => student != null;

  @override
  Widget build(BuildContext context) {
    final firstNameCtrl = TextEditingController(text: student?.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: student?.lastName ?? '');
    final dobCtrl = TextEditingController(text: student?.dobFormatted ?? '');
    final emailCtrl = TextEditingController(text: student?.email ?? '');
    final mobileCtrl = TextEditingController(text: student?.mobileNumber ?? '');
    final ec1Ctrl = TextEditingController(text: student?.emergencyContact1 ?? '');
    final ec2Ctrl = TextEditingController(text: student?.emergencyContact2 ?? '');
    final medicalCtrl = TextEditingController(text: student?.medicalNotes ?? '');
    final notesCtrl = TextEditingController(text: student?.notes ?? '');

    final selectedGender = (student?.gender ?? 'Female').obs;
    final selectedAgeGroupId = Rxn<int>(student?.ageGroupId);
    final selectedLevelId = Rxn<int>(student?.levelId);
    final selectedStudioId = Rxn<int>(student?.studioId);
    final selectedStyleIds = <int>[
      ...?student?.danceStyles.map((s) => s.id),
    ].obs;
    final pickedImage = Rxn<File>();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: Text(isEditing ? 'Edit Student' : 'Add Student'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Profile pic ────────────────────────────
            Center(
              child: GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (picked != null) pickedImage.value = File(picked.path);
                },
                child: Obx(() {
                  final file = pickedImage.value;
                  if (file != null) {
                    return CircleAvatar(
                        radius: 40, backgroundImage: FileImage(file));
                  }
                  final url = student?.profilePicture ?? '';
                  if (url.isNotEmpty && url.startsWith('http')) {
                    return CircleAvatar(
                        radius: 40, backgroundImage: NetworkImage(url));
                  }
                  return CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.primary, size: 28),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Tap to upload photo',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ),
            const SizedBox(height: 20),

            // ── Text fields ────────────────────────────
            _FormField(label: 'First Name *', ctrl: firstNameCtrl,
                validator: _required),
            _FormField(label: 'Last Name *', ctrl: lastNameCtrl,
                validator: _required),
            _FormField(
                label: 'Date of Birth * (YYYY-MM-DD)',
                ctrl: dobCtrl,
                validator: _required),
            // Gender
            Obx(() => _DropdownField<String>(
                  label: 'Gender *',
                  value: selectedGender.value,
                  items: const ['Male', 'Female', 'Other'],
                  itemLabel: (v) => v,
                  onChanged: (v) => selectedGender.value = v!,
                )),
            const SizedBox(height: 14),
            _FormField(label: 'Email', ctrl: emailCtrl),
            _FormField(label: 'Mobile Number', ctrl: mobileCtrl),
            _FormField(label: 'Emergency Contact 1', ctrl: ec1Ctrl),
            _FormField(label: 'Emergency Contact 2', ctrl: ec2Ctrl),
            _FormField(label: 'Medical Notes', ctrl: medicalCtrl, maxLines: 2),
            _FormField(label: 'Notes', ctrl: notesCtrl, maxLines: 2),

            const SizedBox(height: 8),
            // ── Dropdowns ──────────────────────────────
            Obx(() => _DropdownField<int>(
                  label: 'Age Group',
                  value: selectedAgeGroupId.value,
                  items: controller.ageGroups.map((a) => a.id).toList(),
                  itemLabel: (id) =>
                      controller.ageGroups
                          .firstWhereOrNull((a) => a.id == id)
                          ?.name ??
                      '',
                  onChanged: (v) => selectedAgeGroupId.value = v,
                )),
            const SizedBox(height: 14),
            Obx(() => _DropdownField<int>(
                  label: 'Skill Level',
                  value: selectedLevelId.value,
                  items: controller.skillLevels.map((l) => l.id).toList(),
                  itemLabel: (id) =>
                      controller.skillLevels
                          .firstWhereOrNull((l) => l.id == id)
                          ?.name ??
                      '',
                  onChanged: (v) => selectedLevelId.value = v,
                )),
            const SizedBox(height: 14),
            Obx(() => _DropdownField<int>(
                  label: 'Studio',
                  value: selectedStudioId.value,
                  items: controller.studios.map((s) => s.id).toList(),
                  itemLabel: (id) =>
                      controller.studios
                          .firstWhereOrNull((s) => s.id == id)
                          ?.name ??
                      '',
                  onChanged: (v) => selectedStudioId.value = v,
                )),
            const SizedBox(height: 14),

            // ── Dance Styles (multi-select) ────────────
            Text('Dance Styles',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 6),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: controller.danceStyles.map((style) {
                    final selected = selectedStyleIds.contains(style.id);
                    return FilterChip(
                      label: Text(style.name,
                          style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontSize: 12)),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border),
                      onSelected: (_) {
                        if (selected) {
                          selectedStyleIds.remove(style.id);
                        } else {
                          selectedStyleIds.add(style.id);
                        }
                      },
                    );
                  }).toList(),
                )),

            const SizedBox(height: 28),
            // ── Save button ────────────────────────────
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            bool success;
                            if (isEditing) {
                              success = await controller.updateStudent(
                                id: student!.id,
                                firstName: firstNameCtrl.text.trim(),
                                lastName: lastNameCtrl.text.trim(),
                                dateOfBirth: dobCtrl.text.trim(),
                                gender: selectedGender.value,
                                email: emailCtrl.text.trim(),
                                mobileNumber: mobileCtrl.text.trim(),
                                emergencyContact1: ec1Ctrl.text.trim(),
                                emergencyContact2: ec2Ctrl.text.trim(),
                                medicalNotes: medicalCtrl.text.trim(),
                                notes: notesCtrl.text.trim(),
                                ageGroupId: selectedAgeGroupId.value,
                                levelId: selectedLevelId.value,
                                studioId: selectedStudioId.value,
                                danceStyleIds: selectedStyleIds.toList(),
                                profilePic: pickedImage.value,
                              );
                            } else {
                              success = await controller.createStudent(
                                firstName: firstNameCtrl.text.trim(),
                                lastName: lastNameCtrl.text.trim(),
                                dateOfBirth: dobCtrl.text.trim(),
                                gender: selectedGender.value,
                                email: emailCtrl.text.trim(),
                                mobileNumber: mobileCtrl.text.trim(),
                                emergencyContact1: ec1Ctrl.text.trim(),
                                emergencyContact2: ec2Ctrl.text.trim(),
                                medicalNotes: medicalCtrl.text.trim(),
                                notes: notesCtrl.text.trim(),
                                ageGroupId: selectedAgeGroupId.value,
                                levelId: selectedLevelId.value,
                                studioId: selectedStudioId.value,
                                danceStyleIds: selectedStyleIds.toList(),
                                profilePic: pickedImage.value,
                              );
                            }
                            if (success) Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(isEditing ? 'Update Student' : 'Create Student'),
                  ),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

// ── Reusable form field ───────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.ctrl,
    this.maxLines = 1,
    this.validator,
  });
  final String label;
  final TextEditingController ctrl;
  final int maxLines;
  final String? Function(String?)? validator;

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
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            validator: validator,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable dropdown field ───────────────────────────────────────────────────
class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              dropdownColor: AppColors.card,
              hint: Text('Select $label',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 14)),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              items: items
                  .map((item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(itemLabel(item)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
