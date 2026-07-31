import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/core/widgets/status_badge.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingsTab extends GetView<BookingsController> {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.privateLessons),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: Obx(() {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: controller.filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = controller.filters[index];

                  return Obx(() {
                    final isSelected =
                        controller.selectedFilter.value == filter;

                    return FilterChip(
                      key: ValueKey(filter),
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) {
                        controller.selectedFilter.value = filter;
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.card,
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    );
                  });
                },
              );
            }),
          ),
          Expanded(
            child: Obx(
              () {
                final bookings = controller.filteredBookings;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return AppCard(
                      onTap: () {
                        controller.selectBooking(booking);
                        Get.toNamed(AppRoutes.bookingDetail);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  booking.title,
                                  style:
                                      Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              StatusBadge(status: booking.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            booking.type,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                '${booking.date} · ${booking.time}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                '${booking.dancerName} · ${booking.instructor}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
