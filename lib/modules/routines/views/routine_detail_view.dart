import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/core/widgets/flow_app_bar.dart';
import 'package:catalyst/core/widgets/network_image_box.dart';
import 'package:catalyst/core/widgets/primary_button.dart';
import 'package:catalyst/modules/routines/controllers/routines_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoutineDetailView extends GetView<RoutinesController> {
  const RoutineDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final routine = controller.selectedRoutine.value;
    if (routine == null) {
      return Scaffold(
        appBar: const FlowAppBar(title: 'Select Routine'),
        body: const Center(child: Text('Routine not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FlowAppBar(title: 'Select Routine'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Row(
                children: [
                  NetworkImageBox(
                    imageUrl: routine.imageUrl,
                    width: 90,
                    height: 120,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        _MetaRow(
                          icon: Icons.music_note,
                          text: routine.song,
                          color: AppColors.wellness,
                        ),
                        _MetaRow(
                          icon: Icons.access_time,
                          text: routine.duration,
                          color: AppColors.wellness,
                        ),
                        _MetaRow(
                          icon: Icons.calendar_today,
                          text: routine.lastUpdated,
                          color: AppColors.wellness,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: routine.spotlightColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            routine.category,
                            style: TextStyle(
                              color: routine.spotlightColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Routine Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _DetailTile(
              icon: Icons.track_changes,
              iconColor: AppColors.primary,
              title: 'Focus',
              subtitle: routine.focus,
            ),
            _DetailTile(
              icon: Icons.bar_chart,
              iconColor: AppColors.primary,
              title: 'Level',
              subtitle: routine.level,
            ),
            _DetailTile(
              icon: Icons.person_outline,
              iconColor: AppColors.primary,
              title: 'Choreographer',
              subtitle: routine.choreographer,
            ),
            _DetailTile(
              icon: Icons.event,
              iconColor: AppColors.primary,
              title: 'Performance Date',
              subtitle: routine.performanceDate,
            ),
            const SizedBox(height: 16),
            AppCard(
              onTap: () {
                Get.snackbar(
                  'Practice',
                  'Opening practice mode for ${routine.name}',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.wellness),
                    ),
                    child: Icon(
                        Icons.home_outlined,
                        color: AppColors.wellness,
                        size: 20,
                    ),
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
                  Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Play Music',
              useGradient: true,
              onPressed: () {
                Get.snackbar(
                  'Playing',
                  'Playing ${routine.song}',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Download',
                  'Downloading ${routine.song}',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: const Icon(Icons.download, color: AppColors.primary),
              label: const Text('DOWNLOAD MUSIC'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
              icon,
              size: 12,
              color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                     color: Colors.white,
                      fontSize: 14
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11
                  )
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
