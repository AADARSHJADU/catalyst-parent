import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleTab extends GetView<ScheduleController> {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View classes, private lessons, and attendance.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section title + filter row ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class Schedule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Browse all group classes for the selected time period.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  // Filter row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _DropdownFilterChip(
                            icon: Icons.person_outline,
                            label: 'All Students'),
                        const SizedBox(width: 8),
                        _DropdownFilterChip(
                            icon: Icons.location_on_outlined,
                            label: 'All Studios'),
                        const SizedBox(width: 8),
                        _DropdownFilterChip(
                            icon: Icons.calendar_today_outlined,
                            label: 'May 19 – May 25, 2025'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Day filter chips ─────────────────────────────────────────
            SizedBox(
              height: 36,
              child: Obx(() {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = controller.days[index];

                    return Obx(() {
                      final isSelected =
                          controller.selectedDay.value == day;

                      return GestureDetector(
                        onTap: () {
                          controller.selectedDay.value = day;
                        },
                        child: Container(
                          key: ValueKey(day),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 12),

            // ── Class list ───────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final grouped = controller.classesGroupedByDate;
                if (grouped.isEmpty) {
                  return const Center(
                    child: Text(
                      'No classes found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                final dateKeys = grouped.keys.toList();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: dateKeys.length + 1,
                  itemBuilder: (context, index) {
                    if (index == dateKeys.length) {
                      return _FooterBanner();
                    }
                    final dateKey = dateKeys[index];
                    final classes = grouped[dateKey]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DateHeader(dateKey: dateKey),
                        ...classes.map((cls) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ClassCard(cls: cls),
                            )),
                        const SizedBox(height: 6),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date header ──────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.dateKey});
  final String dateKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            dateKey,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Class card ───────────────────────────────────────────────────────────────
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    final isFull = cls.spotsLeft == 0;
    final controller = Get.find<ScheduleController>();
    return AppCard(
      padding: const EdgeInsets.all(0),
      onTap: () {
        controller.selectClass(cls);
        Get.toNamed(AppRoutes.classDetail);
      },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Thumbnail Container
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.sports_gymnastics,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),


                  const SizedBox(width: 14),

                  // 2. Center Content (Information Area)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Level Dot Row
                        Row(
                          children: [
                            _LevelDot(level: cls.level),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                cls.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold, // Bold title stands out better
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Time with Icon
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${cls.startTime} - ${cls.endTime}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Instructor with Icon
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                cls.instructor,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Tags Layer
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (cls.ageRange.isNotEmpty) _MiniTag(label: cls.ageRange),
                            _MiniTag(label: 'Level ${cls.level}'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 3. Right Side (Stats & Action Button)
                  SizedBox(
                    width: 85,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Enrollment Count
                        Text(
                          '${cls.enrolled}/${cls.capacity}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Enrolled',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),

                        const SizedBox(height: 12), // Balanced spacing before button
                        // Styled Action Button
                        SizedBox(
                          height: 28,
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              controller.selectClass(cls);
                              Get.toNamed(AppRoutes.classDetail);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary, width: 1.2),
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              isFull ? 'Full' : 'Details',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}

// ── Footer banner ─────────────────────────────────────────────────────────────
class _FooterBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Don't see a class you're looking for?",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'New classes are added regularly.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.classSchedule),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('View Full Schedule',
                style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _LevelDot extends StatelessWidget {
  const _LevelDot({required this.level});
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
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style:
            const TextStyle(color: AppColors.textSecondary, fontSize: 10),
      ),
    );
  }
}

class _DropdownFilterChip extends StatelessWidget {
  const _DropdownFilterChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down,
              size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
