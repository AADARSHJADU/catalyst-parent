import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstructorDetailView extends GetView<ScheduleController> {
  const InstructorDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final instructor = controller.selectedInstructor;
    if (instructor == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Instructor Profile')),
        body: const Center(child: Text('Instructor not found')),
      );
    }

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
        title: const Text('Instructor Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ──────────────────────────────────────────────
            _HeroCard(instructor: instructor),
            const SizedBox(height: 16),

            // ── Stats row ──────────────────────────────────────────────
            _StatsRow(instructor: instructor),
            const SizedBox(height: 16),

            // ── About ──────────────────────────────────────────────────
            if (instructor.bio.isNotEmpty) ...[
              _SectionCard(
                title: 'About',
                child: Text(
                  instructor.bio,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.7,
                      ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Dance styles ───────────────────────────────────────────
            if (instructor.styles.isNotEmpty) ...[
              _SectionCard(
                title: 'Dance Styles',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: instructor.styles
                      .map((s) => _StyleChip(label: s))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Certifications ─────────────────────────────────────────
            if (instructor.certifications.isNotEmpty) ...[
              _SectionCard(
                title: 'Certifications & Training',
                child: Column(
                  children: instructor.certifications
                      .map((c) => _CertItem(text: c))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Available slots ────────────────────────────────────────
            if (instructor.availableSlots.isNotEmpty) ...[
              _SectionCard(
                title: 'Available Time Slots',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: instructor.availableSlots
                      .map((slot) => _SlotChip(label: slot))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Classes taught ─────────────────────────────────────────
            _ClassesTaughtCard(instructorName: instructor.name),
            const SizedBox(height: 24),

            // ── CTA buttons ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Ensure PrivateLessonsController is available
                  if (!Get.isRegistered<PrivateLessonsController>()) {
                    Get.put(PrivateLessonsController());
                  }
                  final plCtrl = Get.find<PrivateLessonsController>();
                  plCtrl.resetBookingFlow();
                  // Pre-select this instructor and skip straight to step 1 (Date & Time)
                  plCtrl.selectedInstructor.value = instructor;
                  plCtrl.bookingStep.value = 1;
                  Get.toNamed(AppRoutes.bookLesson);
                },
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('Book a Private Lesson'),
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
                  Get.snackbar(
                    'Message Sent',
                    'Your message has been sent to ${instructor.name}',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.message_outlined,
                    size: 18, color: AppColors.textPrimary),
                label: const Text('Send Message',
                    style: TextStyle(color: AppColors.textPrimary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero card ──────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.instructor});
  final InstructorModel instructor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      _initials(instructor.name),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                            BorderSide(color: AppColors.card, width: 2)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instructor.specialty,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    if (instructor.experience.isNotEmpty)
                      Text(
                        instructor.experience,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 10),
                    // Rating row
                    /*Row(
                      children: [
                        ...List.generate(5, (i) {
                          final full = i < instructor.rating.floor();
                          final half = !full &&
                              i < instructor.rating &&
                              instructor.rating - i >= 0.5;
                          return Icon(
                            full
                                ? Icons.star
                                : half
                                    ? Icons.star_half
                                    : Icons.star_border,
                            size: 16,
                            color: AppColors.warning,
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          instructor.rating.toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${instructor.reviewCount} reviews)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '\$${instructor.hourlyRate.toInt()} / hr',
                            style: const TextStyle(
                                color: AppColors.primary, fontSize: 11),
                          ),
                        ),
                      ],
                    ),*/
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              ...List.generate(5, (i) {
                final full = i < instructor.rating.floor();
                final half = !full &&
                    i < instructor.rating &&
                    instructor.rating - i >= 0.5;
                return Icon(
                  full
                      ? Icons.star
                      : half
                      ? Icons.star_half
                      : Icons.star_border,
                  size: 16,
                  color: AppColors.warning,
                );
              }),
              const SizedBox(width: 6),
              Text(
                instructor.rating.toStringAsFixed(1),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(
                '(${instructor.reviewCount} reviews)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '\$${instructor.hourlyRate.toInt()} / hr',
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 11),
                ),
              ),
            ],
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

// ── Stats row ──────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.instructor});
  final InstructorModel instructor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people_outline,
            value: '${instructor.totalStudents}+',
            label: 'Students',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            value: '${instructor.classesPerWeek}',
            label: 'Classes/Week',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.workspace_premium_outlined,
            value: '${instructor.yearsExperience}yrs',
            label: 'Experience',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Section card ───────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Classes taught card ────────────────────────────────────────────────────────
class _ClassesTaughtCard extends StatelessWidget {
  const _ClassesTaughtCard({required this.instructorName});
  final String instructorName;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();
    final classes = controller.allClasses
        .where((c) =>
            c.instructor.toLowerCase() == instructorName.toLowerCase())
        .toList();

    if (classes.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Classes Taught',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          ...classes.map((cls) => _ClassRow(cls: cls)),
        ],
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Get.find<ScheduleController>().selectClass(cls);
          Get.toNamed(AppRoutes.classDetail);
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(Icons.sports_gymnastics,
                    size: 20,
                    color: AppColors.primary.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cls.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          )),
                  Text(
                    '${cls.day} · ${cls.startTime} – ${cls.endTime}  •  ${cls.room}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _LevelBadge(level: cls.level),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
class _StyleChip extends StatelessWidget {
  const _StyleChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontSize: 12),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_outlined,
              size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CertItem extends StatelessWidget {
  const _CertItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final String level;

  Color get _color {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFF9C27B0);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        level,
        style: TextStyle(color: _color, fontSize: 10),
      ),
    );
  }
}
