import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/choreography/controllers/choreography_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChoreographyView extends GetView<ChoreographyController> {
  const ChoreographyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Choreography'),
        actions: [
          TextButton.icon(
            onPressed: controller.refresh,
            icon: const Icon(Icons.refresh, size: 16, color: AppColors.primary),
            label: const Text('Refresh',
                style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.choreographies.isEmpty) {
          return _buildError();
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              // Header
              Text('Assigned Choreography Sessions',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'View choreographies assigned by studio choreographers to your children and complete tuition checkout.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              // Stats cards
              _StatsRow(),
              const SizedBox(height: 16),
              // Filter tabs
              _FilterTabs(),
              const SizedBox(height: 12),
              // Choreography cards
              Obx(() {
                final items = controller.filteredChoreographies;
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                        child: Text('No choreographies found.',
                            style: TextStyle(color: AppColors.textSecondary))),
                  );
                }
                return Column(
                  children: items
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ChoreographyCard(data: c),
                          ))
                      .toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Obx(() => Text(controller.errorMessage.value,
            style: const TextStyle(color: AppColors.textSecondary))),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: controller.refresh,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Retry'),
        ),
      ]),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────
class _StatsRow extends GetView<ChoreographyController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.choreographies.length;
      final pending = controller.pendingCount;
      final completed = controller.completedCount;
      return Row(
        children: [
          _StatBox(label: 'ASSIGNED SESSIONS', value: '$total',
              icon: Icons.music_note, color: AppColors.primary),
          const SizedBox(width: 8),
          _StatBox(label: 'PENDING PAYMENTS', value: '$pending',
              icon: Icons.access_time, color: AppColors.warning),
          const SizedBox(width: 8),
          _StatBox(label: 'COMPLETED PAYMENTS', value: '$completed',
              icon: Icons.check_circle_outline, color: AppColors.success),
        ],
      );
    });
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 9)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Icon(icon, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}

// ── Filter Tabs ───────────────────────────────────────────────────────────────
class _FilterTabs extends GetView<ChoreographyController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Obx(() {
        final active = controller.selectedFilter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final filter = controller.filters[i];
            final isActive = active == filter;
            return GestureDetector(
              onTap: () => controller.selectedFilter.value = filter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border),
                ),
                child: Text(filter,
                    style: TextStyle(
                        color:
                            isActive ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal)),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Choreography Card (detailed) ──────────────────────────────────────────────
class _ChoreographyCard extends GetView<ChoreographyController> {
  const _ChoreographyCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = data['className']?.toString() ?? '';
    final type = data['lessonType']?.toString() ?? '';
    final instructor = data['instructor']?.toString() ?? '';
    final danceStyle = data['danceStyle']?.toString() ?? '';
    final room = data['room']?.toString() ?? '';
    final startDate = data['startDate']?.toString() ?? '';
    final endDate = data['endDate']?.toString() ?? '';
    final startTime = data['startTime']?.toString() ?? '';
    final endTime = data['endTime']?.toString() ?? '';
    final duration = data['duration'];
    final price = data['price'];
    final status = data['status']?.toString() ?? '';
    final focusArea = data['focusArea']?.toString() ?? '';
    final studentGoal = data['studentGoal']?.toString() ?? '';
    final musicLink = data['musicLink']?.toString() ?? '';
    final students = data['students'] as List? ?? [];
    final choreographyId = data['id'] as int;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Name + Type badge + Style badge ────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Music icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.music_note,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(name,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    // Badges row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (type.isNotEmpty) _badge(type, AppColors.primary),
                        if (danceStyle.isNotEmpty)
                          _badge(danceStyle, AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
              // Price
              if (price != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TUITION FEE',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 9)),
                    Text('\$${(price as num).toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Info row: Instructor, Room, Time, Dates ────────────
          if (instructor.isNotEmpty)
            _infoRow(Icons.person_outline,
                'Instructor: $instructor${room.isNotEmpty ? ' · Room: $room' : ''}'),
          if (startTime.isNotEmpty || duration != null)
            _infoRow(Icons.access_time,
                '$startTime – $endTime${duration != null ? ' ($duration mins)' : ''}'),
          if (startDate.isNotEmpty)
            _infoRow(Icons.calendar_today_outlined,
                '$startDate to ${endDate.isNotEmpty ? endDate : 'Ongoing'}'),

          // ── Focus Area & Goal ──────────────────────────────────
          if (focusArea.isNotEmpty || studentGoal.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (focusArea.isNotEmpty)
                    Text('Focus Area: $focusArea',
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 12)),
                  if (studentGoal.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text('Performance Goal: $studentGoal',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],

          // ── Assigned Dancers & Payment Status ──────────────────
          if (students.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            const Text('ASSIGNED DANCERS & PAYMENT STATUS',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            ...students.map((s) {
              final sMap = s as Map<String, dynamic>;
              return _StudentPaymentRow(
                sMap: sMap,
                choreographyId: choreographyId,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12))),
      ]),
    );
  }
}

// ── Student Payment Row ───────────────────────────────────────────────────────
class _StudentPaymentRow extends GetView<ChoreographyController> {
  const _StudentPaymentRow({
    required this.sMap,
    required this.choreographyId,
  });
  final Map<String, dynamic> sMap;
  final int choreographyId;

  @override
  Widget build(BuildContext context) {
    final name = sMap['studentName']?.toString() ?? '';
    final payStatus = sMap['paymentStatus']?.toString().toLowerCase() ?? '';
    final amountDue = sMap['amountDue'];
    final amountPaid = sMap['amountPaid'];
    final studentId = sMap['studentId'] as int? ?? 0;
    final isPaid = payStatus == 'paid';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: const Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            // Name + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const Text('Assigned Student',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            // Payment badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isPaid ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: (isPaid ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.3)),
              ),
              child: Text(
                isPaid ? 'PAID' : 'PENDING',
                style: TextStyle(
                    color: isPaid ? AppColors.success : AppColors.warning,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            // Action badge
            if (isPaid)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check, size: 12, color: AppColors.success),
                    SizedBox(width: 3),
                    Text('Paid',
                        style: TextStyle(
                            color: AppColors.success, fontSize: 10)),
                  ],
                ),
              )
            else if (studentId > 0)
              GestureDetector(
                onTap: () => _showPayOptions(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Pay Now',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPayOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pay Choreography Fee',
                style: Theme.of(context).textTheme.titleMedium),
            if (sMap['amountDue'] != null) ...[
              const SizedBox(height: 6),
              Text(
                  '\$${(sMap['amountDue'] as num).toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 16),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isBooking.value
                        ? null
                        : () {
                            Get.back();
                            controller.payOnline(
                                choreographyId, sMap['studentId'] as int);
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: controller.isBooking.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Pay Online (Stripe)'),
                  ),
                )),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.back();
                  controller.payLater(
                      choreographyId, sMap['studentId'] as int);
                },
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Pay Later / Cash'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
