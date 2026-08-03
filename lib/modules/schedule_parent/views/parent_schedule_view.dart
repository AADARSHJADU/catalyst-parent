import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/schedule_parent/controllers/parent_schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ParentScheduleView extends GetView<ParentScheduleController> {
  const ParentScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return _buildError();
          }
          return Column(
            children: [
              _Header(),
              _WeekStrip(),
              _Filters(),
              _TabRow(),
              Expanded(child: _ScheduleList()),
            ],
          );
        }),
      ),
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

// ── Header with date nav ──────────────────────────────────────────────────────
class _Header extends GetView<ParentScheduleController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Schedule', style: Theme.of(context).textTheme.titleLarge),
                Obx(() => Text(controller.dateLabel,
                    style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: controller.prevDay,
          ),
          GestureDetector(
            onTap: controller.goToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
              child: const Text('Today',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: controller.nextDay,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined,
                color: AppColors.textMuted, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2024),
                lastDate: DateTime(2028),
              );
              if (picked != null) controller.setDate(picked);
            },
          ),
        ],
      ),
    );
  }
}

// ── Week strip ────────────────────────────────────────────────────────────────
class _WeekStrip extends GetView<ParentScheduleController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Obx(() {
        final days = controller.weekDays;
        final selected = controller.selectedDate.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 7,
          itemBuilder: (_, i) {
            final day = days[i];
            final isActive = day.day == selected.day &&
                day.month == selected.month &&
                day.year == selected.year;
            return GestureDetector(
              onTap: () => controller.setDate(day),
              child: Container(
                width: 44,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('E').format(day).substring(0, 2),
                        style: TextStyle(
                            color: isActive ? Colors.white : AppColors.textMuted,
                            fontSize: 10)),
                    const SizedBox(height: 2),
                    Text('${day.day}',
                        style: TextStyle(
                            color: isActive ? Colors.white : AppColors.textPrimary,
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Filters (Student + Studio) ────────────────────────────────────────────────
class _Filters extends GetView<ParentScheduleController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(child: Obx(() => _dropdown(
            value: controller.selectedStudentId.value,
            hint: 'All Children',
            items: [
              const DropdownMenuItem(value: 'All', child: Text('All Children')),
              ...controller.students.map((s) => DropdownMenuItem(
                value: s['id'].toString(),
                child: Text('${s['firstName'] ?? s['first_name'] ?? ''} ${s['lastName'] ?? s['last_name'] ?? ''}'.trim()),
              )),
            ],
            onChanged: (v) => controller.selectedStudentId.value = v ?? 'All',
          ))),
          const SizedBox(width: 8),
          Expanded(child: Obx(() => _dropdown(
            value: controller.selectedStudioId.value,
            hint: 'All Studios',
            items: [
              const DropdownMenuItem(value: 'All', child: Text('All Studios')),
              ...controller.studios.map((s) => DropdownMenuItem(
                value: s['id'].toString(),
                child: Text(s['name']?.toString() ?? ''),
              )),
            ],
            onChanged: (v) => controller.selectedStudioId.value = v ?? 'All',
          ))),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.card,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Tab Row ───────────────────────────────────────────────────────────────────
class _TabRow extends GetView<ParentScheduleController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Obx(() {
        final active = controller.activeTab.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          itemCount: controller.tabLabels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final isActive = active == i;
            return GestureDetector(
              onTap: () => controller.activeTab.value = i,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border),
                ),
                child: Text(controller.tabLabels[i],
                    style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Schedule List ─────────────────────────────────────────────────────────────
class _ScheduleList extends GetView<ParentScheduleController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredItems;
      if (items.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('No events scheduled for this day.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ScheduleCard(
            item: items[i], tab: controller.activeTab.value),
      );
    });
  }
}

// ── Schedule Card (renders differently per tab) ───────────────────────────────
class _ScheduleCard extends GetView<ParentScheduleController> {
  const _ScheduleCard({required this.item, required this.tab});
  final Map<String, dynamic> item;
  final int tab;

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case 0: return _classCard(context);
      case 1: return _privateCard(context);
      case 2: return _wellnessCard(context);
      case 3: return _choreographyCard(context);
      case 4: return _routineCard(context);
      default: return const SizedBox.shrink();
    }
  }

  Widget _classCard(BuildContext context) {
    final cls = item['class'] as Map<String, dynamic>? ?? {};
    final name = cls['name']?.toString() ?? '';
    final instructor = cls['instructor']?['user'] ?? {};
    final instName = '${instructor['firstName'] ?? ''} ${instructor['lastName'] ?? ''}'.trim();
    final schedules = cls['schedules'] as List? ?? [];
    final schedule = schedules.isNotEmpty ? schedules.first as Map<String, dynamic> : {};
    final startTime = controller.formatTime24to12(schedule['startTime']?.toString());
    final endTime = controller.formatTime24to12(schedule['endTime']?.toString());
    final room = cls['room']?['name']?.toString() ?? '';
    final studio = cls['room']?['studio']?['name']?.toString() ?? '';
    final student = item['student'] as Map<String, dynamic>? ?? {};
    final studentName = '${student['first_name'] ?? ''} ${student['last_name'] ?? ''}'.trim();
    final isCompleted = item['_isCompleted'] == true;

    return GestureDetector(
      onTap: () => Get.to(() => _ClassDetailSheet(item: item, controller: controller)),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Text(startTime, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
              const Text('to', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
              Text(endTime, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ]),
            const SizedBox(width: 12),
            Container(width: 3, height: 50, decoration: BoxDecoration(
              color: isCompleted ? AppColors.info : AppColors.primary,
              borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isCompleted ? AppColors.info : AppColors.primary).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4)),
                    child: Text(isCompleted ? 'Completed' : 'Regular Class',
                        style: TextStyle(color: isCompleted ? AppColors.info : AppColors.primary, fontSize: 9)),
                  ),
                ]),
                const SizedBox(height: 4),
                if (instName.isNotEmpty) _row(Icons.person_outline, instName),
                if (room.isNotEmpty) _row(Icons.location_on_outlined, '$room, $studio'),
                if (studentName.isNotEmpty) _row(Icons.child_care, studentName),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _privateCard(BuildContext context) {
    final lesson = item['lesson'] as Map<String, dynamic>? ?? {};
    final instructor = lesson['instructor']?['user'] ?? {};
    final instName = '${instructor['firstName'] ?? ''} ${instructor['lastName'] ?? ''}'.trim();
    final startTime = controller.formatTime24to12(lesson['startTime']?.toString());
    final endTime = controller.formatTime24to12(lesson['endTime']?.toString());
    final studio = lesson['studio']?['name']?.toString() ?? '';
    final student = item['student'] as Map<String, dynamic>? ?? {};
    final studentName = '${student['first_name'] ?? ''} ${student['last_name'] ?? ''}'.trim();

    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Text(startTime, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          const Text('to', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
          Text(endTime, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ]),
        const SizedBox(width: 12),
        Container(width: 3, height: 50, decoration: BoxDecoration(
          color: AppColors.success, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Private Lesson', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
              child: const Text('Private', style: TextStyle(color: AppColors.success, fontSize: 9)),
            ),
          ]),
          const SizedBox(height: 4),
          if (instName.isNotEmpty) _row(Icons.person_outline, instName),
          if (studio.isNotEmpty) _row(Icons.location_on_outlined, studio),
          if (studentName.isNotEmpty) _row(Icons.child_care, studentName),
        ])),
      ]),
    );
  }

  Widget _wellnessCard(BuildContext context) {
    final name = item['name']?.toString() ?? '';
    final instructor = item['instructor']?['user'] ?? {};
    final instName = '${instructor['firstName'] ?? ''} ${instructor['lastName'] ?? ''}'.trim();
    final startTime = controller.formatTime24to12(item['time_start']?.toString());
    final endTime = controller.formatTime24to12(item['time_end']?.toString());
    final studio = item['studio']?['name']?.toString() ?? '';
    final type = item['wellnessType']?['name']?.toString() ?? '';

    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Text(startTime, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          const Text('to', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
          Text(endTime, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ]),
        const SizedBox(width: 12),
        Container(width: 3, height: 50, decoration: BoxDecoration(
          color: AppColors.wellness, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
            if (type.isNotEmpty) Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.wellness.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
              child: Text(type, style: const TextStyle(color: AppColors.wellness, fontSize: 9)),
            ),
          ]),
          const SizedBox(height: 4),
          if (instName.isNotEmpty) _row(Icons.person_outline, instName),
          if (studio.isNotEmpty) _row(Icons.location_on_outlined, studio),
        ])),
      ]),
    );
  }

  Widget _choreographyCard(BuildContext context) {
    final name = item['className']?.toString() ?? item['choreographyName']?.toString() ?? '';
    final studio = item['studio']?['name']?.toString() ?? '';

    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 3, height: 40, margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(2))),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
              child: const Text('Choreography', style: TextStyle(color: AppColors.warning, fontSize: 9)),
            ),
          ]),
          if (studio.isNotEmpty) _row(Icons.location_on_outlined, studio),
        ])),
      ]),
    );
  }

  Widget _routineCard(BuildContext context) {
    return AppCard(
      child: Row(children: [
        Container(width: 3, height: 30, margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(2))),
        const Expanded(child: Text('Routine Session', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
          child: const Text('Routine', style: TextStyle(color: AppColors.info, fontSize: 9)),
        ),
      ]),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Class Detail Page (opens on tap)
// ══════════════════════════════════════════════════════════════════════════════
class _ClassDetailSheet extends StatelessWidget {
  const _ClassDetailSheet({required this.item, required this.controller});
  final Map<String, dynamic> item;
  final ParentScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final cls = item['class'] as Map<String, dynamic>? ?? {};
    final name = cls['name']?.toString() ?? 'Class';
    final programType = cls['programType']?.toString() ?? '';
    final description = cls['description']?.toString() ?? '';
    final level = cls['level']?.toString() ?? '';
    final danceStyle = cls['danceStyle']?.toString() ?? '';
    final ageGroup = cls['ageGroup']?.toString() ?? '';
    final capacity = cls['capacity']?.toString() ?? '';
    final billingType = cls['billingType']?.toString() ?? '';
    final monthlyPrice = cls['monthlyPrice'];
    final dropInFee = cls['dropInFee'];
    final instructor = cls['instructor']?['user'] as Map<String, dynamic>? ?? {};
    final instName = '${instructor['firstName'] ?? ''} ${instructor['lastName'] ?? ''}'.trim();
    final instEmail = instructor['email']?.toString() ?? '';
    final instPhone = instructor['phone']?.toString() ?? '';
    final room = cls['room'] as Map<String, dynamic>? ?? {};
    final roomName = room['name']?.toString() ?? room['room_name']?.toString() ?? '';
    final studio = room['studio'] as Map<String, dynamic>? ?? {};
    final studioName = studio['name']?.toString() ?? '';
    final studioAddress = studio['address']?.toString() ?? '';
    final schedules = cls['schedules'] as List? ?? [];
    final student = item['student'] as Map<String, dynamic>? ?? {};
    final studentName = '${student['first_name'] ?? student['firstName'] ?? ''} ${student['last_name'] ?? student['lastName'] ?? ''}'.trim();
    final joiningDate = item['joiningDate']?.toString() ?? '';
    final enrollmentId = item['id']?.toString() ?? '';
    final isCompleted = item['_isCompleted'] == true;

    // Build schedule text
    String scheduleText = '';
    if (schedules.isNotEmpty) {
      final s = schedules.first as Map<String, dynamic>;
      final days = <String>[];
      if (s['monday'] == true) days.add('Mon');
      if (s['tuesday'] == true) days.add('Tue');
      if (s['wednesday'] == true) days.add('Wed');
      if (s['thursday'] == true) days.add('Thu');
      if (s['friday'] == true) days.add('Fri');
      if (s['saturday'] == true) days.add('Sat');
      if (s['sunday'] == true) days.add('Sun');
      final startTime = controller.formatTime24to12(s['startTime']?.toString());
      final endTime = controller.formatTime24to12(s['endTime']?.toString());
      scheduleText = '${days.join(", ")} • $startTime - $endTime';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isCompleted ? AppColors.info : AppColors.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted ? '✓ Completed Today' : 'Regular Class',
                  style: TextStyle(
                      color: isCompleted ? AppColors.info : AppColors.primary,
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              if (programType.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(programType,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 10)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Class name large
          Text(name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Class Info
          _detailCard(context, 'Class Information', Icons.info_outline, [
            _detailRow('Class Name', name),
            if (programType.isNotEmpty) _detailRow('Program Type', programType),
            if (danceStyle.isNotEmpty) _detailRow('Dance Style', danceStyle),
            if (level.isNotEmpty) _detailRow('Level', level),
            if (ageGroup.isNotEmpty) _detailRow('Age Group', ageGroup),
            if (capacity.isNotEmpty) _detailRow('Capacity', capacity),
            if (billingType.isNotEmpty) _detailRow('Billing Type', billingType),
            if (monthlyPrice != null)
              _detailRow('Monthly Price', '\$${_toPrice(monthlyPrice)}'),
            if (dropInFee != null)
              _detailRow('Drop-in Fee', '\$${_toPrice(dropInFee)}'),
            if (description.isNotEmpty) _detailRow('Description', description),
          ]),

          // Schedule
          if (scheduleText.isNotEmpty)
            _detailCard(context, 'Schedule', Icons.schedule, [
              _detailRow('Days & Time', scheduleText),
              if (schedules.isNotEmpty) ...[
                _detailRow('Start Date', (schedules.first as Map)['startDate']?.toString() ?? ''),
                _detailRow('End Date', (schedules.first as Map)['endDate']?.toString() ?? ''),
              ],
            ]),

          // Instructor
          if (instName.isNotEmpty)
            _detailCard(context, 'Instructor', Icons.person_outline, [
              _detailRow('Name', instName),
              if (instEmail.isNotEmpty) _detailRow('Email', instEmail),
              if (instPhone.isNotEmpty) _detailRow('Phone', instPhone),
            ]),

          // Location
          if (roomName.isNotEmpty || studioName.isNotEmpty)
            _detailCard(context, 'Location', Icons.location_on_outlined, [
              if (roomName.isNotEmpty) _detailRow('Room', roomName),
              if (studioName.isNotEmpty) _detailRow('Studio', studioName),
              if (studioAddress.isNotEmpty) _detailRow('Address', studioAddress),
            ]),

          // Student & Enrollment
          _detailCard(context, 'Enrollment', Icons.check_circle_outline, [
            if (enrollmentId.isNotEmpty) _detailRow('Enrollment ID', enrollmentId),
            if (studentName.isNotEmpty) _detailRow('Student', studentName),
            if (joiningDate.isNotEmpty) _detailRow('Joined', joiningDate),
            _detailRow('Status', isCompleted ? 'Completed Today' : 'Active'),
          ]),
        ],
      ),
    );
  }

  String _toPrice(dynamic val) {
    if (val == null) return '0.00';
    if (val is num) return val.toStringAsFixed(2);
    final parsed = double.tryParse(val.toString());
    return parsed?.toStringAsFixed(2) ?? val.toString();
  }

  Widget _detailCard(BuildContext context, String title, IconData icon,
      List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ]),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
