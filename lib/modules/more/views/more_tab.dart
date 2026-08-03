import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_assets.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/auth/controllers/auth_controller.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoreTab extends GetView<MoreController> {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(Icons.family_restroom, 'Family & Dancers', AppRoutes.family),
      _MenuItem(Icons.music_note, 'Routines', AppRoutes.routines),
      _MenuItem(Icons.spa, 'Wellness', AppRoutes.wellness),
      _MenuItem(Icons.trending_up, 'Student Progress', AppRoutes.studentProgress),
      _MenuItem(Icons.emoji_events_outlined, 'Competitions & Events', AppRoutes.competitions),
      _MenuItem(Icons.folder_outlined, 'Documents', AppRoutes.documents),
      _MenuItem(Icons.person_pin, 'Private Lessons', AppRoutes.privateLessons),
      _MenuItem(Icons.school_outlined, 'Regular Classes', AppRoutes.regularClasses),
      _MenuItem(Icons.theater_comedy_outlined, 'Choreography', AppRoutes.choreography),
      _MenuItem(Icons.payment, 'Payments & Billing', AppRoutes.payments),
      _MenuItem(Icons.notifications_outlined, 'Notifications', AppRoutes.notifications),
      _MenuItem(Icons.person_outline, 'Student Profile', AppRoutes.studentProfile),
      _MenuItem(Icons.settings_outlined, 'Settings', AppRoutes.settings),
      _MenuItem(Icons.campaign_outlined, 'Announcements', AppRoutes.announcements),
      _MenuItem(Icons.calendar_month, 'Full Class Schedule', AppRoutes.classSchedule),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Obx(() {
                final name = controller.userName.value;
                final email = controller.userEmail.value;
                final role = controller.userRole.value;
                final picUrl = controller.profilePicUrl.value;
                final initials = name.isNotEmpty
                    ? name
                        .split(' ')
                        .where((p) => p.isNotEmpty)
                        .map((p) => p[0])
                        .take(2)
                        .join()
                    : '?';

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      backgroundImage: picUrl.isNotEmpty && picUrl.startsWith('http')
                          ? NetworkImage(picUrl)
                          : null,
                      child: picUrl.isEmpty || !picUrl.startsWith('http')
                          ? Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isNotEmpty ? name : 'Loading...',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            role,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(AppAssets.logo, height: 40),
                  ],
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(
              'Menu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...menuItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onTap: () async {
                    await Get.toNamed(item.route);
                    // Refresh profile when returning from Settings
                    if (item.route == AppRoutes.settings) {
                      controller.refreshProfile();
                    }
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(item.icon, color: AppColors.primary),
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  // Clears token from storage then navigates to login
                  await Get.find<AuthController>().signOut();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('SIGN OUT'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.title, this.route);

  final IconData icon;
  final String title;
  final String route;
}
