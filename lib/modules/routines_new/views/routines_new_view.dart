import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/routines_new/controllers/routines_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String _fixImg(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.contains('localhost') || url.contains('127.0.0.1')) {
    return url.replaceAll('http://localhost:8080',
        'https://darksalmon-dragonfly-928313.hostingersite.com');
  }
  if (!url.startsWith('http')) {
    return 'https://darksalmon-dragonfly-928313.hostingersite.com$url';
  }
  return url;
}

class RoutinesNewView extends GetView<RoutinesNewController> {
  const RoutinesNewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Routines'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
              onPressed: controller.refresh),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.routines.isEmpty) {
          return _buildError();
        }
        return Column(children: [
          _Filters(),
          Expanded(child: _RoutinesList()),
        ]);
      }),
    );
  }

  Widget _buildError() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
      const SizedBox(height: 12),
      Obx(() => Text(controller.errorMessage.value,
          style: const TextStyle(color: AppColors.textSecondary))),
      const SizedBox(height: 12),
      ElevatedButton(
          onPressed: controller.refresh,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Retry')),
    ]));
  }
}

// ── Filters ───────────────────────────────────────────────────────────────────
class _Filters extends GetView<RoutinesNewController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(children: [
        // Student dropdown
        Expanded(child: Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedStudentId.value,
              isExpanded: true,
              dropdownColor: AppColors.card,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
              items: [
                const DropdownMenuItem(value: 'All', child: Text('All Dancers')),
                ...controller.students.map((s) => DropdownMenuItem(
                  value: s['id'].toString(),
                  child: Text('${s['firstName'] ?? ''} ${s['lastName'] ?? ''}'.trim()),
                )),
              ],
              onChanged: (v) => controller.selectedStudentId.value = v ?? 'All',
            ),
          ),
        ))),
        const SizedBox(width: 8),
        // Payment filter
        Obx(() {
          final active = controller.selectedPaymentFilter.value;
          return Row(children: controller.paymentFilters.map((f) {
            final isActive = active == f;
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () => controller.selectedPaymentFilter.value = f,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isActive ? AppColors.primary : AppColors.border)),
                  child: Text(f, style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary, fontSize: 11)),
                ),
              ),
            );
          }).toList());
        }),
      ]),
    );
  }
}

// ── Routines List ─────────────────────────────────────────────────────────────
class _RoutinesList extends GetView<RoutinesNewController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredRoutines;
      if (items.isEmpty) {
        return const Center(child: Text('No routines found.',
            style: TextStyle(color: AppColors.textSecondary)));
      }
      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _RoutineCard(data: items[i]),
        ),
      );
    });
  }
}

// ── Routine Card ──────────────────────────────────────────────────────────────
class _RoutineCard extends GetView<RoutinesNewController> {
  const _RoutineCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final routine = data['routine'] as Map<String, dynamic>? ?? {};
    final payment = data['payment'] as Map<String, dynamic>? ?? {};
    final student = data['student'] as Map<String, dynamic>? ?? {};

    final name = routine['name']?.toString() ?? 'Routine';
    final fee = routine['routineFee']?.toString() ?? '';
    final recurrence = routine['recurrence']?.toString() ?? '';
    final timeStart = routine['timeStart']?.toString() ?? '';
    final timeEnd = routine['timeEnd']?.toString() ?? '';
    final sessionDate = routine['sessionDate']?.toString() ?? '';
    final danceStyle = routine['danceStyle']?['name']?.toString() ?? '';
    final competition = routine['competition']?['name']?.toString() ?? '';
    final instructor = routine['instructor']?['user'] ?? {};
    final instName = '${instructor['firstName'] ?? ''} ${instructor['lastName'] ?? ''}'.trim();
    final room = routine['room']?['name']?.toString() ?? '';
    final studio = routine['room']?['studio']?['name']?.toString() ?? '';

    final studentName = '${student['firstName'] ?? ''} ${student['lastName'] ?? ''}'.trim();
    final studentPic = _fixImg(student['profilePicture']?.toString());

    final payStatus = payment['paymentStatus']?.toString().toLowerCase() ?? '';
    final amountDue = payment['amountDue']?.toString() ?? '';
    final amountPaid = payment['amountPaid']?.toString() ?? '0';
    final paymentId = (payment['id'] ?? data['paymentId'] ?? data['id']) as int?;
    final isPaid = payStatus == 'paid';
    final grandTotal = controller.getGrandTotal(data);

    // Debug
    print('🎵 [ROUTINE] name=$name payStatus=$payStatus paymentId=$paymentId isPaid=$isPaid amountDue=$amountDue fee=$fee grandTotal=$grandTotal');

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: name + payment badge
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.music_note, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: (isPaid ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text(isPaid ? 'PAID' : 'PENDING',
                style: TextStyle(
                    color: isPaid ? AppColors.success : AppColors.warning,
                    fontSize: 9, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 10),

        // Details
        if (danceStyle.isNotEmpty) _info(Icons.category_outlined, 'Style: $danceStyle'),
        if (competition.isNotEmpty) _info(Icons.emoji_events_outlined, 'Competition: $competition'),
        if (instName.isNotEmpty) _info(Icons.person_outline, 'Instructor: $instName'),
        if (room.isNotEmpty) _info(Icons.location_on_outlined, '$room${studio.isNotEmpty ? ', $studio' : ''}'),
        if (recurrence.isNotEmpty) _info(Icons.repeat, 'Recurrence: ${recurrence.capitalize}'),
        if (timeStart.isNotEmpty) _info(Icons.access_time, 'Time: ${_fmt24to12(timeStart)} - ${_fmt24to12(timeEnd)}'),
        if (sessionDate.isNotEmpty) _info(Icons.calendar_today_outlined, 'Next Session: $sessionDate'),

        // Student
        const SizedBox(height: 8),
        Row(children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            backgroundImage: studentPic.isNotEmpty ? NetworkImage(studentPic) : null,
            child: studentPic.isEmpty ? const Icon(Icons.person, size: 14, color: AppColors.primary) : null,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(studentName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
        ]),

        // Fee breakdown (only show what API returns)
        const SizedBox(height: 10),
        const Divider(color: AppColors.border),
        const SizedBox(height: 8),
        // Base routine fee
        Row(children: [
          const Text('Routine Fee:', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const Spacer(),
          Text('\$$fee', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
        ]),
        // If amountDue > routineFee, show the extra as registration fees
        Builder(builder: (_) {
          final baseFeeNum = double.tryParse(fee) ?? 0;
          final extraAmount = grandTotal - baseFeeNum;
          if (extraAmount > 0.01) {
            return Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(children: [
                const Text('Registration & Processing Fees:', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const Spacer(),
                Text('\$${extraAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
              ]),
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 4),
        Row(children: [
          const Text('Grand Total:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('\$${grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.success, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),

        // Pay button
        if (!isPaid) ...[
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: Obx(() => ElevatedButton(
            onPressed: controller.isPaying.value
                ? null
                : () {
                    final id = paymentId ?? data['id'] as int?;
                    if (id != null) controller.payRoutine(id);
                  },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: controller.isPaying.value
                ? const SizedBox(height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Pay Routine Fee Now'),
          ))),
        ],
        if (isPaid) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.check_circle, size: 14, color: AppColors.success),
            const SizedBox(width: 6),
            Text('Paid: \$$amountPaid', style: const TextStyle(color: AppColors.success, fontSize: 11)),
          ]),
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

  String _fmt24to12(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      final parts = time.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1];
      final p = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:$m $p';
    } catch (_) { return time; }
  }

  String _n(dynamic v) {
    if (v is num) return v.toStringAsFixed(2);
    return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
  }
}
