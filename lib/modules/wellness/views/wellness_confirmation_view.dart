import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/mock/wellness_mock_data.dart';
import 'package:catalyst/modules/wellness/controllers/wellness_controller.dart';
import 'package:catalyst/modules/wellness/widgets/wellness_app_bar.dart';
import 'package:catalyst/modules/wellness/widgets/wellness_stepper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WellnessConfirmationView extends GetView<WellnessController> {
  const WellnessConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final pass = controller.selectedPass;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const WellnessAppBar(showBack: true, showMenu: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirmation',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your purchase was successful!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            const WellnessStepper(currentStep: 2),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.success,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.success,
                          size: 40,
                        ),
                      ),
                      ...List.generate(8, (i) {
                        final angle = i * 45.0;
                        return Transform.rotate(
                          angle: angle * 3.14159 / 180,
                          child: Transform.translate(
                            offset: const Offset(0, -50),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i.isEven
                                    ? AppColors.primary
                                    : AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Successful!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thank you for your purchase.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.confirmation_number,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pass.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              pass.subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (pass.isPopular) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Popular',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        controller.formattedSubtotal,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: AppColors.border),
                  _DetailRow(
                    label: 'Order Number',
                    value: WellnessMockData.orderNumber,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Date',
                    value: WellnessMockData.orderDate,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Payment Method',
                    value: WellnessMockData.paymentMethod,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Paid',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        controller.formattedTotal,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "What's Next?",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _WhatsNextItem(
              icon: Icons.calendar_today,
              title: 'View My Bookings',
              subtitle: 'See your upcoming classes',
              onTap: () {
                Get.until((route) => route.settings.name == AppRoutes.wellness);
                controller.goToMyBookings();
              },
            ),
            const SizedBox(height: 8),
            _WhatsNextItem(
              icon: Icons.credit_card,
              title: 'View Memberships',
              subtitle: 'Check your active passes',
              onTap: () {
                Get.until((route) => route.settings.name == AppRoutes.wellness);
                controller.goToMemberships();
              },
            ),
            const SizedBox(height: 8),
            _WhatsNextItem(
              icon: Icons.confirmation_number_outlined,
              title: 'Explore Classes',
              subtitle: 'Discover more classes to join',
              onTap: () {
                Get.until((route) => route.settings.name == AppRoutes.wellness);
                controller.goToClasses();
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Get.until((route) => route.settings.name == AppRoutes.wellness);
                  controller.goToMyBookings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Flexible(
                      child: Text(
                        'Go to My Bookings',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: Colors.black),
                  ],
                ),
                /*child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Go to My Bookings',
                      style: TextStyle(
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.black),
                  ],
                ),*/
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _WhatsNextItem extends StatelessWidget {
  const _WhatsNextItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
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
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
