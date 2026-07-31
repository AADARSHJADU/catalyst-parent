import 'package:cached_network_image/cached_network_image.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/mock/wellness_mock_data.dart';
import 'package:catalyst/modules/wellness/controllers/wellness_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WellnessAccountTab extends GetView<WellnessController> {
  const WellnessAccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final overview = controller.accountOverview;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            onTap: () {},
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surface,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: WellnessMockData.profileImageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const Icon(Icons.person, color: AppColors.textMuted),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.person, color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.user.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        controller.user.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.edit,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Edit Profile',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Account Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _OverviewItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Credits',
                  subtitle: 'Use credits to book classes',
                  value: '${overview.credits} classes',
                  showDivider: true,
                ),
                _OverviewItem(
                  icon: Icons.event_available_outlined,
                  title: 'Pass Expiry',
                  subtitle: overview.passName,
                  value: overview.passExpiry,
                  showDivider: true,
                ),
                _OverviewItem(
                  icon: Icons.bar_chart_outlined,
                  title: 'Attendance This Month',
                  subtitle: 'Keep it up!',
                  value: '${overview.monthlyAttendance} classes',
                  showDivider: true,
                ),
                _OverviewItem(
                  icon: Icons.emoji_events_outlined,
                  title: 'Lifetime Attendance',
                  subtitle: 'Total classes attended',
                  value: '${overview.lifetimeAttendance} classes',
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.showDivider,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.border, indent: 68),
      ],
    );
  }
}
