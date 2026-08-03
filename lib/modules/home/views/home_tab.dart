import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_assets.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/core/widgets/section_header.dart';
import 'package:catalyst/core/widgets/status_badge.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          controller.user.name.split(' ').first,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.notifications),
                              icon: const Icon(Icons.notifications_outlined),
                            ),
                            if (controller.unreadNotifications > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Image.asset(AppAssets.logo, height: 36),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuickActions(),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'My Dancers',
                      actionLabel: 'View All',
                      action: () => Get.toNamed(AppRoutes.family),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.dancers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final dancer = controller.dancers[index];
                          return AppCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () => Get.toNamed(AppRoutes.family),
                            child: SizedBox(
                              width: 140,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      dancer.avatarInitials ?? dancer.name[0],
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dancer.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    dancer.level,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                    SectionHeader(
                      title: 'Upcoming',
                      actionLabel: 'See All',
                      action: () {
                        final main = Get.find<MainController>();
                        main.changeTab(2);
                      },
                    ),
                    SizedBox(height: 12),
                    ...controller.upcomingBookings.map(
                      (booking) => Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          onTap: () {
                            Get.toNamed(AppRoutes.bookingDetail);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  booking.type == 'Private Lesson'
                                      ? Icons.person_outline
                                      : Icons.groups_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      '${booking.date} · ${booking.time}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(status: booking.status),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.school_outlined,
        label: 'Classes',
        route: AppRoutes.regularClasses,
      ),
      _ActionItem(
        icon: Icons.person_pin,
        label: 'Private Lessons',
        route: AppRoutes.privateLessons,
      ),
      _ActionItem(
        icon: Icons.music_note,
        label: 'Choreography',
        route: AppRoutes.choreography,
      ),
      _ActionItem(
        icon: Icons.payment,
        label: 'Payments',
        route: AppRoutes.payments,
      ),
    ];

    return Row(
      children: actions
          .map(
            (action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onTap: () => Get.toNamed(action.route),
                  child: Column(
                    children: [
                      Icon(action.icon, color: AppColors.primary, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        action.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
