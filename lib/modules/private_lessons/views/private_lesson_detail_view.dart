import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivateLessonDetailView
    extends GetView<PrivateLessonsController> {
  const PrivateLessonDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final lesson = controller.selectedLesson;
    if (lesson == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Lesson Details')),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    final isPast = lesson.isPast;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: TextButton.icon(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back,
              size: 18, color: AppColors.textSecondary),
          label: const Text(
            'Back',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        leadingWidth: 90,
        title: const Text('Lesson Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lesson Details',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            Text(
              isPast
                  ? 'Review details and notes from this session.'
                  : 'View full information about this upcoming lesson.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // ── Main layout ──────────────────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 680;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(children: [
                        _HeaderCard(lesson: lesson),
                        const SizedBox(height: 16),
                        _FocusAreasCard(lesson: lesson),
                        if (lesson.notes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _NotesCard(lesson: lesson),
                        ],
                      ]),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 270,
                      child: Column(children: [
                        _InstructorCard(lesson: lesson),
                        const SizedBox(height: 16),
                        _DetailsCard(lesson: lesson),
                        const SizedBox(height: 16),
                        _ActionButtons(lesson: lesson),
                      ]),
                    ),
                  ],
                );
              }
              return Column(children: [
                _HeaderCard(lesson: lesson),
                const SizedBox(height: 16),
                _InstructorCard(lesson: lesson),
                const SizedBox(height: 16),
                _DetailsCard(lesson: lesson),
                const SizedBox(height: 16),
                _FocusAreasCard(lesson: lesson),
                if (lesson.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _NotesCard(lesson: lesson),
                ],
                const SizedBox(height: 16),
                _ActionButtons(lesson: lesson),
              ]);
            }),
          ],
        ),
      ),
    );
  }
}

// ── Header card ────────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.lesson});
  final lesson;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date badge
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(lesson.month,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            letterSpacing: 1)),
                    Text(lesson.dayNum,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            height: 1.1)),
                    Text(lesson.dayName,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypeBadge(type: lesson.lessonType),
                        const Spacer(),
                        _StatusBadge(status: lesson.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(lesson.title,
                        style:
                            Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(lesson.student,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.access_time_outlined,
                  label: 'Time',
                  value: lesson.time,
                ),
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: '${lesson.durationMins} mins',
                ),
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Studio',
                  value: lesson.studio,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Instructor card ────────────────────────────────────────────────────────────
class _InstructorCard extends StatelessWidget {
  const _InstructorCard({required this.lesson});
  final lesson;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Instructor',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  _initials(lesson.instructor),
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.instructor,
                        style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 13, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text('5.0',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: AppColors.textPrimary)),
                        const SizedBox(width: 4),
                        Text('(128 reviews)',
                            style:
                                Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final ctrl = Get.find<ScheduleController>();
                ctrl.selectInstructorByName(lesson.instructor);
                Get.toNamed(AppRoutes.instructorDetail);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('View Instructor Profile',
                  style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}';
    }
    return name.substring(0, 2);
  }
}

// ── Details card ───────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.lesson});
  final lesson;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lesson Details',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.category_outlined,
              label: 'Type',
              value: lesson.lessonType),
          _DetailRow(
              icon: Icons.person_outline,
              label: 'Student',
              value: lesson.student),
          _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: '${lesson.durationMins} minutes'),
          _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Studio',
              value: lesson.studio),
          _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: lesson.fullDate),
          _DetailRow(
              icon: Icons.access_time_outlined,
              label: 'Time',
              value: lesson.time),
        ],
      ),
    );
  }
}

// ── Focus areas card ───────────────────────────────────────────────────────────
class _FocusAreasCard extends StatelessWidget {
  const _FocusAreasCard({required this.lesson});
  final lesson;

  @override
  Widget build(BuildContext context) {
    final areas = lesson.focusAreas as List<String>;
    if (areas.isEmpty) return const SizedBox.shrink();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.isPast ? 'Areas Covered' : 'Focus Areas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          ...areas.map((area) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(area,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Notes card ─────────────────────────────────────────────────────────────────
class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.lesson});
  final lesson;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                lesson.isPast ? 'Session Notes' : 'Lesson Notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              lesson.notes,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action buttons ─────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.lesson});
  final lesson;

  @override
  Widget build(BuildContext context) {
    if (lesson.isPast) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar('Book Again',
                    'Booking a follow-up lesson with ${lesson.instructor}',
                    snackPosition: SnackPosition.BOTTOM);
              },
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: const Text('Book Follow-Up Lesson'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.snackbar('Reschedule',
                  'Reschedule request sent for ${lesson.title}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.card,
                  colorText: AppColors.textPrimary);
            },
            icon: const Icon(Icons.edit_calendar_outlined, size: 18),
            label: const Text('Reschedule Lesson'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.snackbar('Cancelled', 'Lesson cancellation requested',
                  snackPosition: SnackPosition.BOTTOM);
              Get.back();
            },
            icon: const Icon(Icons.cancel_outlined,
                size: 18, color: AppColors.error),
            label: const Text('Cancel Lesson',
                style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodySmall)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(type,
          style: const TextStyle(color: AppColors.primary, fontSize: 11)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: _color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(status,
              style: TextStyle(color: _color, fontSize: 11)),
        ],
      ),
    );
  }
}
