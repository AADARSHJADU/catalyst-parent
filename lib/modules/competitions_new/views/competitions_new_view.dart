import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/competitions_new/controllers/competitions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CompetitionsNewView extends GetView<CompetitionsNewController> {
  const CompetitionsNewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Competitions & Events'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.errorMessage.value.isNotEmpty && controller.competitions.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(controller.errorMessage.value, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: controller.refresh,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Retry')),
          ]));
        }
        return Column(children: [
          _Tabs(),
          Expanded(child: _buildTab()),
        ]);
      }),
    );
  }

  Widget _buildTab() {
    return Obx(() {
      switch (controller.currentTab.value) {
        case 0: return _UpcomingList();
        case 1: return _RegistrationsList();
        case 2: return _PastResultsList();
        default: return _UpcomingList();
      }
    });
  }
}

class _Tabs extends GetView<CompetitionsNewController> {
  @override
  Widget build(BuildContext context) {
    final labels = ['Upcoming', 'My Registrations', 'Past Results'];
    return SizedBox(height: 40, child: Obx(() {
      final active = controller.currentTab.value;
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = active == i;
          return GestureDetector(
            onTap: () => controller.currentTab.value = i,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? AppColors.primary : AppColors.border)),
              child: Text(labels[i], style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
            ),
          );
        },
      );
    }));
  }
}

// ── Upcoming Competitions ─────────────────────────────────────────────────────
class _UpcomingList extends GetView<CompetitionsNewController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.competitions.toList();
      if (items.isEmpty) return const Center(child: Text('No upcoming competitions.', style: TextStyle(color: AppColors.textSecondary)));
      return RefreshIndicator(
        onRefresh: controller.refresh, color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _CompetitionCard(data: items[i]),
        ),
      );
    });
  }
}

class _CompetitionCard extends GetView<CompetitionsNewController> {
  const _CompetitionCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = data['name']?.toString() ?? '';
    final venue = data['venueName']?.toString() ?? '';
    final city = data['city']?.toString() ?? '';
    final state = data['state']?.toString() ?? '';
    final startDate = data['startDate']?.toString() ?? '';
    final endDate = data['endDate']?.toString() ?? '';
    final deadline = data['registrationDeadline']?.toString() ?? '';
    final entryFee = double.tryParse(data['entryFee']?.toString() ?? '0') ?? 0;
    final description = data['description']?.toString() ?? '';
    final rawTags = data['tags'];
    final List<dynamic> tags;
    if (rawTags is List) {
      tags = rawTags;
    } else if (rawTags is String && rawTags.isNotEmpty) {
      tags = rawTags.split(',').map((s) => s.trim()).toList();
    } else {
      tags = [];
    }
    final compId = data['id'] as int;
    final status = controller.registrationStatus(compId);
    final isRegistered = status.toLowerCase() == 'registered';

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.emoji_events, size: 20, color: AppColors.warning)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: (isRegistered ? AppColors.success : AppColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: TextStyle(
                color: isRegistered ? AppColors.success : AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 10),
        // Details
        _info(Icons.location_on_outlined, '$venue, $city, $state'),
        _info(Icons.calendar_today_outlined, '${_fmt(startDate)} - ${_fmt(endDate)}'),
        if (deadline.isNotEmpty) _info(Icons.timer_outlined, 'Deadline: ${_fmt(deadline)}'),
        _info(Icons.attach_money, 'Entry Fee: \$${entryFee.toStringAsFixed(2)}'),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4)),
        ],
        // Tags
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: tags.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border)),
            child: Text(t.toString(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
          )).toList()),
        ],
        // Register button
        if (!isRegistered) ...[
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => _showPaySheet(context, compId, entryFee),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Register & Pay'),
          )),
        ],
      ]),
    );
  }

  Widget _info(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Icon(icon, size: 13, color: AppColors.textMuted), const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
    ]));

  String _fmt(String? d) {
    if (d == null || d.isEmpty) return '';
    try { return DateFormat('MMM d, yyyy').format(DateTime.parse(d)); }
    catch (_) { return d; }
  }

  void _showPaySheet(BuildContext context, int compId, double entryFee) {
    final grandTotal = controller.getGrandTotal(entryFee);
    final selectedStudent = Rxn<int>(
        controller.students.isNotEmpty ? controller.students.first['id'] as int : null);

    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Register & Pay', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          // Student selector
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border)),
            child: DropdownButtonHideUnderline(child: DropdownButton<int>(
              value: selectedStudent.value,
              isExpanded: true, dropdownColor: AppColors.card,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              hint: const Text('Select Dancer'),
              items: controller.students.map((s) => DropdownMenuItem<int>(
                value: s['id'] as int,
                child: Text('${s['firstName'] ?? ''} ${s['lastName'] ?? ''}'.trim()),
              )).toList(),
              onChanged: (v) => selectedStudent.value = v,
            )),
          )),
          const SizedBox(height: 14),
          // Fee breakdown
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Entry Fee:', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            Text('\$${entryFee.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
          ]),
          ...controller.feeComponents.map((fc) => Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(fc['name']?.toString() ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text('\$${_n(fc['amount'])}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
            ]),
          )),
          const Divider(color: AppColors.border, height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Grand Total:', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            Text('\$${grandTotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.success, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          Obx(() => SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: controller.isPaying.value ? null : () {
              Get.back();
              controller.payCompetition(compId, studentId: selectedStudent.value);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: controller.isPaying.value
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Pay Online & Confirm Registration'),
          ))),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  String _n(dynamic v) {
    if (v is num) return v.toStringAsFixed(2);
    return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
  }
}

// ── My Registrations ──────────────────────────────────────────────────────────
class _RegistrationsList extends GetView<CompetitionsNewController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.myRegistrations.toList();
      if (items.isEmpty) return const Center(child: Text('No registrations yet.', style: TextStyle(color: AppColors.textSecondary)));
      return RefreshIndicator(
        onRefresh: controller.refresh, color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _RegistrationCard(data: items[i]),
        ),
      );
    });
  }
}

class _RegistrationCard extends GetView<CompetitionsNewController> {
  const _RegistrationCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = data['competitionName']?.toString() ?? '';
    final venue = data['venueName']?.toString() ?? '';
    final startDate = data['startDate']?.toString() ?? '';
    final status = data['status']?.toString() ?? '';
    final students = data['students'] as List? ?? [];
    final routineCount = data['routineCount'] ?? 0;
    final amountPaid = data['amountPaid'];
    final paymentMethod = data['paymentMethod']?.toString() ?? '';
    final isRegistered = status.toLowerCase() == 'registered';
    final payments = data['payments'] as List? ?? [];
    final compId = data['competitionId'] as int? ?? 0;
    final paymentId = data['paymentId'] as int?;

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.emoji_events, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: (isRegistered ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: TextStyle(
                color: isRegistered ? AppColors.success : AppColors.warning, fontSize: 9, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 8),
        if (venue.isNotEmpty) _r(Icons.location_on_outlined, venue),
        if (startDate.isNotEmpty) _r(Icons.calendar_today_outlined, startDate),
        if (students.isNotEmpty) _r(Icons.child_care, 'Dancers: ${students.join(", ")}'),
        _r(Icons.music_note, 'Routines: $routineCount'),
        if (amountPaid != null) _r(Icons.payment_outlined, 'Paid: \$${_n(amountPaid)} via $paymentMethod'),
        // Per-student payments
        if (payments.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Divider(color: AppColors.border),
          ...payments.map((p) {
            final pm = p as Map<String, dynamic>;
            final sName = pm['studentName']?.toString() ?? '';
            final pStatus = pm['paymentStatus']?.toString() ?? '';
            final isPaid = pStatus.toLowerCase() == 'paid';
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const Icon(Icons.person, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(child: Text(sName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: (isPaid ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(pStatus, style: TextStyle(color: isPaid ? AppColors.success : AppColors.warning, fontSize: 9)),
                ),
                if (!isPaid) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      final sId = pm['studentId'] as int?;
                      controller.payCompetition(compId, studentId: sId);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                      child: const Text('Pay', style: TextStyle(color: Colors.white, fontSize: 9)),
                    ),
                  ),
                ],
              ]),
            );
          }),
        ],
        // If overall not registered/paid, show pay button
        if (!isRegistered && payments.isEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: Obx(() => ElevatedButton(
            onPressed: controller.isPaying.value ? null : () => controller.payCompetition(compId),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Pay & Register', style: TextStyle(fontSize: 12)),
          ))),
        ],
      ]),
    );
  }

  Widget _r(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(children: [
      Icon(icon, size: 13, color: AppColors.textMuted), const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
    ]));

  String _n(dynamic v) {
    if (v is num) return v.toStringAsFixed(2);
    return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
  }
}

// ── Past Results ──────────────────────────────────────────────────────────────
class _PastResultsList extends GetView<CompetitionsNewController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.pastResults.toList();
      if (items.isEmpty) return const Center(child: Text('No past results.', style: TextStyle(color: AppColors.textSecondary)));
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final d = items[i];
          final name = d['name']?.toString() ?? '';
          final venue = d['venueName']?.toString() ?? '';
          final city = d['city']?.toString() ?? '';
          final routines = d['routines'] as List? ?? [];
          return AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.emoji_events, size: 18, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
              ]),
              const SizedBox(height: 6),
              if (venue.isNotEmpty) Text('$venue, $city', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              if (routines.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...routines.map((r) {
                  final rm = r as Map<String, dynamic>;
                  final rName = rm['routineName']?.toString() ?? '';
                  final placement = rm['placement']?.toString() ?? '';
                  final score = rm['score'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      const Icon(Icons.star, size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Expanded(child: Text(rName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                      if (placement.isNotEmpty) Text(placement, style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                      if (score != null) Text(' ($score)', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    ]),
                  );
                }),
              ],
            ]),
          );
        },
      );
    });
  }
}
