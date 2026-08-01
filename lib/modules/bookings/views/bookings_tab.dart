import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/bookings/controllers/bookings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingsTab extends GetView<MyBookingsController> {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('My Bookings'),
      ),
      body: Column(
        children: [
          // ── Tabs ─────────────────────────────────────────
          _TabsRow(),
          // ── Search + Filter ──────────────────────────────
          _SearchFilterRow(),
          // ── Content ──────────────────────────────────────
          Expanded(child: _BookingsList()),
        ],
      ),
    );
  }
}

// ── Tabs Row ──────────────────────────────────────────────────────────────────
class _TabsRow extends GetView<MyBookingsController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final active = controller.selectedTab.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: controller.tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final isActive = active == i;
            return GestureDetector(
              onTap: () => controller.selectTab(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  controller.tabs[i],
                  style: TextStyle(
                    color:
                        isActive ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Search + Filter Row ───────────────────────────────────────────────────────
class _SearchFilterRow extends GetView<MyBookingsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.setSearch,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search bookings...',
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => _FilterChip(
                value: controller.paymentStatusFilter.value,
                options: controller.paymentStatuses,
                onChanged: controller.setPaymentStatus,
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String value;
  final List<String> options;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Payment Status',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 16)),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...options.map((opt) => ListTile(
                  dense: true,
                  title: Text(opt,
                      style: TextStyle(
                          color: opt == value
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 14)),
                  trailing: opt == value
                      ? const Icon(Icons.check,
                          color: AppColors.primary, size: 16)
                      : null,
                  onTap: () {
                    onChanged(opt);
                    Get.back();
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── Bookings List ─────────────────────────────────────────────────────────────
class _BookingsList extends GetView<MyBookingsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2));
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.items.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 40, color: AppColors.error),
              const SizedBox(height: 12),
              Text(controller.errorMessage.value,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.fetchData,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      final bookings = controller.items.toList();
      if (bookings.isEmpty) {
        return const Center(
          child: Text('No bookings found.',
              style: TextStyle(color: AppColors.textSecondary)),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchData,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _BookingItemCard(item: bookings[i]),
        ),
      );
    });
  }
}

// ── Booking Item Card ─────────────────────────────────────────────────────────
class _BookingItemCard extends StatelessWidget {
  const _BookingItemCard({required this.item});
  final Map<String, dynamic> item;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'refunded':
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.toString() ??
        item['lessonType']?.toString() ??
        'Booking';
    final instructor = item['instructor']?.toString() ?? '';
    final studentName = item['studentName']?.toString() ?? '';
    final paymentStatus = item['paymentStatus']?.toString() ?? '';
    final paymentMethod = item['paymentMethod']?.toString() ?? '';
    final cost = item['cost'] ?? item['amountPaid'];
    final dateStr = item['dateString'] ??
        item['paidAt'] ??
        item['joiningDate'] ??
        item['startDate'] ??
        '';
    final timeRange = item['timeRange']?.toString() ?? '';
    final statusColor = _statusColor(paymentStatus);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + status
          Row(
            children: [
              Expanded(
                child: Text(name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              if (paymentStatus.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(paymentStatus,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Info rows
          if (instructor.isNotEmpty)
            _infoRow(Icons.person_outline, instructor),
          if (studentName.isNotEmpty)
            _infoRow(Icons.child_care_outlined, studentName),
          if (dateStr.toString().isNotEmpty)
            _infoRow(Icons.calendar_today_outlined, dateStr.toString()),
          if (timeRange.isNotEmpty)
            _infoRow(Icons.access_time_outlined, timeRange),
          if (paymentMethod.isNotEmpty)
            _infoRow(Icons.payment_outlined, paymentMethod.capitalize!),
          // Cost
          if (cost != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${(cost as num).toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
