import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/core/widgets/primary_button.dart';
import 'package:catalyst/core/widgets/status_badge.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingDetailView extends GetView<BookingsController> {
  const BookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = controller.selectedBooking;
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking')),
        body: const Center(child: Text('Booking not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      StatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.type,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  _Row(Icons.calendar_today, 'Date', booking.date),
                  const Divider(height: 24),
                  _Row(Icons.access_time, 'Time', booking.time),
                  const Divider(height: 24),
                  _Row(Icons.person_outline, 'Instructor', booking.instructor),
                  const Divider(height: 24),
                  _Row(Icons.child_care, 'Dancer', booking.dancerName),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (booking.type == 'Private Lesson') ...[
              PrimaryButton(
                label: 'Reschedule',
                onPressed: () {
                  Get.snackbar(
                    'Reschedule',
                    'Reschedule request sent for ${booking.title}',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Get.snackbar(
                    'Cancelled',
                    'Booking cancelled successfully',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('CANCEL BOOKING'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
