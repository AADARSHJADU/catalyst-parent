import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/core/widgets/flow_app_bar.dart';
import 'package:catalyst/core/widgets/network_image_box.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:catalyst/modules/routines/controllers/routines_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoutinesListView extends GetView<RoutinesController> {
  const RoutinesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FlowAppBar(title: 'Routines'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.wellness.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.wellness.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: AppColors.wellness,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Routines',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'View all routines assigned to Emma.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _TabChip(
                    label: 'Active (${controller.activeRoutines.length})',
                    selected: controller.tabIndex.value == 0,
                    onTap: () => controller.selectTab(0),
                  ),
                  const SizedBox(width: 24),
                  _TabChip(
                    label: 'Completed (${controller.completedRoutines.length})',
                    selected: controller.tabIndex.value == 1,
                    onTap: () => controller.selectTab(1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final list = controller.tabIndex.value == 0
                  ? controller.activeRoutines
                  : controller.completedRoutines;
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: list.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == list.length) {
                    return _PracticeAtHomeCard(
                      onTap: () {
                        if (list.isNotEmpty) {
                          controller.selectRoutine(list.first);
                          Get.toNamed(AppRoutes.routineDetail);
                        }
                      },
                    );
                  }
                  final routine = list[index];
                  return _RoutineCard(
                    routine: routine,
                    onTap: () {
                      controller.selectRoutine(routine);
                      Get.toNamed(AppRoutes.routineDetail);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 80,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine, required this.onTap});

  final RoutineModel routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          NetworkImageBox(
            imageUrl: routine.imageUrl,
            width: 72,
            height: 72,
            borderRadius: 10,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 12,
                      color: routine.spotlightColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        routine.song,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      routine.duration,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: routine.spotlightColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: routine.spotlightColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        routine.category,
                        style: TextStyle(
                          color: routine.spotlightColor,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _PracticeAtHomeCard extends StatelessWidget {
  const _PracticeAtHomeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: const Icon(Icons.home_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice at Home',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Use your music and routine details to practice and perfect your performance!',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
