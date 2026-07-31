import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LessonHistoryView extends GetView<PrivateLessonsController> {
  const LessonHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: TextButton.icon(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back,
              size: 18, color: AppColors.textSecondary),
          label: const Text('Back',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
        leadingWidth: 90,
        title: const Text('Lesson History'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All Past Lessons',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 4),
                Text('Complete history of private lessons.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                // Filter row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() => Row(
                        children: [
                          _DropdownFilter(
                            icon: Icons.person_outline,
                            value: controller.filterStudent.value,
                            options: controller.studentOptions,
                            onChanged: (v) =>
                                controller.filterStudent.value = v,
                          ),
                          const SizedBox(width: 8),
                          _DropdownFilter(
                            icon: Icons.face_outlined,
                            value: controller.filterInstructor.value,
                            options: controller.instructorOptions,
                            onChanged: (v) =>
                                controller.filterInstructor.value = v,
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          // ── List ──────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final lessons = controller.pastFiltered;
              if (lessons.isEmpty) {
                return const Center(
                  child: Text('No past lessons found',
                      style:
                          TextStyle(color: AppColors.textSecondary)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: lessons.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, i) =>
                    _HistoryCard(lesson: lessons[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.lesson});
  final PrivateLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PrivateLessonsController>();
    return AppCard(
      onTap: () {
        ctrl.selectLesson(lesson);
        Get.toNamed(AppRoutes.privateLessonDetail);
      },
      child: Row(
        children: [
          // Date badge
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(lesson.month,
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        letterSpacing: 1)),
                Text(lesson.dayNum,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        height: 1.1)),
                Text(lesson.dayName,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              lesson.student.split(' ').first[0],
              style: const TextStyle(
                  color: AppColors.primary, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis),
                Text(
                    '${lesson.student} · ${lesson.instructor}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
                Text('${lesson.time} · ${lesson.durationMins} mins',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status + chevron
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusDot(status: lesson.status),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});
  final String status;

  Color get _color {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: _color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(status,
            style: TextStyle(color: _color, fontSize: 11)),
      ],
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final IconData icon;
  final String value;
  final List<String> options;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Filter',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 16)),
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
          ],
        ),
      ),
    );
  }
}
