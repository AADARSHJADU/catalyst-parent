import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivateLessonsView extends GetView<PrivateLessonsController> {
  const PrivateLessonsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
        title: null,
      ),
      // ── Fixed bottom FAB ───────────────────────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () {
              controller.resetBookingFlow();
              Get.toNamed(AppRoutes.bookLesson);
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: const Text(
              'Book a New Private Lesson',
              style: TextStyle(fontSize: 14, letterSpacing: 0.3),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          // ── Page title ─────────────────────────────────────────────
          Text('Private Lessons',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text('View and manage private lessons for your dancers.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),

          // ── Filters ────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
                  children: [
                    _DropdownFilterChip(
                      icon: Icons.calendar_today_outlined,
                      value: controller.filterDateRange.value,
                      options: controller.dateRangeOptions,
                      onChanged: (v) =>
                          controller.filterDateRange.value = v,
                    ),
                    const SizedBox(width: 8),
                    _DropdownFilterChip(
                      icon: Icons.person_outline,
                      value: controller.filterStudent.value,
                      options: controller.studentOptions,
                      onChanged: (v) =>
                          controller.filterStudent.value = v,
                    ),
                    const SizedBox(width: 8),
                    _DropdownFilterChip(
                      icon: Icons.face_outlined,
                      value: controller.filterInstructor.value,
                      options: controller.instructorOptions,
                      onChanged: (v) =>
                          controller.filterInstructor.value = v,
                    ),
                    const SizedBox(width: 8),
                    _DropdownFilterChip(
                      icon: Icons.view_week_outlined,
                      value: controller.filterViewMode.value,
                      options: controller.viewModeOptions,
                      onChanged: (v) =>
                          controller.filterViewMode.value = v,
                    ),
                  ],
                )),
          ),
          const SizedBox(height: 28),

          // ── Upcoming ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text('Upcoming Private Lessons',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View Calendar',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.calendar_view_month_outlined,
                        size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final lessons = controller.upcomingFiltered;
            if (lessons.isEmpty) {
              return _EmptyState(
                  message: 'No upcoming lessons match your filters.');
            }
            return Column(
              children: lessons
                  .map((l) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UpcomingLessonCard(lesson: l),
                      ))
                  .toList(),
            );
          }),

          const SizedBox(height: 28),

          // ── Past ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text('Past Private Lessons',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.lessonHistory),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All History',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward,
                        size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final lessons = controller.pastPreview;
            if (lessons.isEmpty) {
              return _EmptyState(
                  message: 'No past lessons match your filters.');
            }
            return _PastLessonsTable(lessons: lessons);
          }),
        ],
      ),
    );
  }
}

// ── Upcoming lesson card ───────────────────────────────────────────────────────
class _UpcomingLessonCard extends StatelessWidget {
  const _UpcomingLessonCard({required this.lesson});
  final PrivateLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PrivateLessonsController>();
    return AppCard(
      onTap: () {
        ctrl.selectLesson(lesson);
        Get.toNamed(AppRoutes.privateLessonDetail);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date column
              SizedBox(
                width: 52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(lesson.month,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            letterSpacing: 1)),
                    Text(lesson.dayNum,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.1)),
                    Text(lesson.dayName,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(lesson.time,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  lesson.student.split(' ').first[0],
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(lesson.student,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(lesson.studio,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Duration: ${lesson.durationMins} mins',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              // ⋮ menu
              IconButton(
                onPressed: () => _showOptions(context, lesson),
                icon: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.textSecondary),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(left: 4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // ── Bottom row ───────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Instructor',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted)),
                    Text(lesson.instructor,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMuted)),
                  _StatusDot(status: lesson.status),
                ],
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  ctrl.selectLesson(lesson);
                  Get.toNamed(AppRoutes.privateLessonDetail);
                },
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
                child: const Text('View Details',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, PrivateLessonModel lesson) {
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
          children: [
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined,
                  color: AppColors.textPrimary),
              title: const Text('Reschedule',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Get.back();
                Get.snackbar('Reschedule', 'Request sent',
                    snackPosition: SnackPosition.BOTTOM);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined,
                  color: AppColors.error),
              title: const Text('Cancel Lesson',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Get.back();
                Get.snackbar('Cancelled', 'Lesson cancelled',
                    snackPosition: SnackPosition.BOTTOM);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Past lessons table ─────────────────────────────────────────────────────────
class _PastLessonsTable extends StatelessWidget {
  const _PastLessonsTable({required this.lessons});

  final List<PrivateLessonModel> lessons;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PrivateLessonsController>();

    return Column(
      children: lessons.map((lesson) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () {
              ctrl.selectLesson(lesson);
              Get.toNamed(AppRoutes.privateLessonDetail);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                    ),
                    _StatusDot(status: lesson.status),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        lesson.fullDate,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${lesson.dayName}, ${lesson.time}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        lesson.instructor,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /*Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      ctrl.selectLesson(lesson);
                      Get.toNamed(
                          AppRoutes.privateLessonDetail);
                    },
                    child: const Text('View Details'),
                  ),
                ),*/
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Center(
        child: Text(message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
      ),
    );
  }
}

// ── Status dot ─────────────────────────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});
  final String status;

  Color get _color {
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'confirmed':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
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
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            status,
            style: TextStyle(color: _color, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Dropdown filter chip ───────────────────────────────────────────────────────
class _DropdownFilterChip extends StatelessWidget {
  const _DropdownFilterChip({
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('Select Filter',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 16)),
            ),
            const Divider(height: 1, color: AppColors.border),
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

// ── Table header cell ──────────────────────────────────────────────────────────
class _TH extends StatelessWidget {
  const _TH({required this.label, required this.flex});
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted)),
    );
  }
}