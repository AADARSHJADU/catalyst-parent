import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/data/mock/mock_data.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookClassView extends GetView<ScheduleController> {
  const BookClassView({super.key});

  @override
  Widget build(BuildContext context) {
    final cls = controller.selectedClass;
    if (cls == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Book Class')),
        body: const Center(child: Text('Class not found')),
      );
    }

    return Obx(() {
      final step = controller.classBookingStep.value;
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (step == 0) {
                Get.back();
              } else {
                controller.classBookingStep.value = step - 1;
              }
            },
          ),
          title: Text(_stepTitle(step)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: _ProgressBar(step: step, total: 3),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(step),
            child: _stepBody(cls, step),
          ),
        ),
        bottomNavigationBar: _BottomBar(cls: cls, step: step),
      );
    });
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Select Student';
      case 1:
        return 'Choose Date & Time';
      case 2:
        return 'Confirm Booking';
      default:
        return '';
    }
  }

  Widget _stepBody(ClassScheduleModel cls, int step) {
    switch (step) {
      case 0:
        return _StepSelectStudent(cls: cls);
      case 1:
        return _StepDateTime(cls: cls);
      case 2:
        return _StepConfirm(cls: cls);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Progress bar ───────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i < total - 1 ? 2 : 0),
            color: i <= step ? AppColors.primary : AppColors.border,
          ),
        );
      }),
    );
  }
}

// ── Bottom action bar ──────────────────────────────────────────────────────────
class _BottomBar extends GetView<ScheduleController> {
  const _BottomBar({required this.cls, required this.step});
  final ClassScheduleModel cls;
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Obx(() {
        final canNext = _canProceed();
        final isLast = step == 2;
        return Row(
          children: [
            if (step > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      controller.classBookingStep.value = step - 1,
                  icon: const Icon(Icons.arrow_back,
                      size: 16, color: AppColors.textPrimary),
                  label: Text(
                    _backLabel(),
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: canNext
                    ? (isLast
                        ? () => controller.confirmClassBooking()
                        : () =>
                            controller.classBookingStep.value = step + 1)
                    : null,
                icon: isLast
                    ? Obx(() => controller.isConfirmingClass.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline, size: 16))
                    : const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  isLast ? 'Confirm & Book' : _nextLabel(),
                  style: const TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canNext ? AppColors.primary : AppColors.border,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  bool _canProceed() {
    switch (step) {
      case 0:
        return controller.classBookingDancer.value.isNotEmpty;
      case 1:
        return controller.classBookingDate.value != null &&
            controller.classBookingTime.value.isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  String _backLabel() {
    switch (step) {
      case 1:
        return 'Student';
      case 2:
        return 'Date & Time';
      default:
        return 'Back';
    }
  }

  String _nextLabel() {
    switch (step) {
      case 0:
        return 'Next: Date & Time';
      case 1:
        return 'Next: Confirm';
      default:
        return 'Next';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 1 — Select Student
// ═══════════════════════════════════════════════════════════════════════════════
class _StepSelectStudent extends GetView<ScheduleController> {
  const _StepSelectStudent({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class summary card
          _ClassSummaryCard(cls: cls),
          const SizedBox(height: 24),

          Text('Who is this class for?',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Select the dancer you are booking for.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),

          // Dancer cards
          ...MockData.dancers.map((dancer) => Obx(() {
                final selected =
                    controller.classBookingDancer.value == dancer.name;
                return GestureDetector(
                  onTap: () =>
                      controller.classBookingDancer.value = dancer.name,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: selected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.surface,
                          child: Text(
                            dancer.avatarInitials ??
                                dancer.name.substring(0, 2),
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dancer.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              Text(
                                'Age ${dancer.age} · ${dancer.level}',
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: dancer.programs
                                    .take(2)
                                    .map((p) => _MiniChip(label: p))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                );
              })),

          const SizedBox(height: 20),

          // Spots remaining info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cls.spotsLeft <= 3
                  ? AppColors.warning.withValues(alpha: 0.08)
                  : AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cls.spotsLeft <= 3
                    ? AppColors.warning.withValues(alpha: 0.3)
                    : AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  cls.spotsLeft <= 3
                      ? Icons.warning_amber_outlined
                      : Icons.check_circle_outline,
                  size: 18,
                  color: cls.spotsLeft <= 3
                      ? AppColors.warning
                      : AppColors.success,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cls.spotsLeft == 0
                        ? 'This class is full. You can join the waitlist.'
                        : cls.spotsLeft <= 3
                            ? 'Only ${cls.spotsLeft} spots left — book quickly!'
                            : '${cls.spotsLeft} spots available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cls.spotsLeft <= 3
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 2 — Date & Time
// ═══════════════════════════════════════════════════════════════════════════════
class _StepDateTime extends GetView<ScheduleController> {
  const _StepDateTime({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recurring note if applicable
          if (cls.isRecurring)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.repeat,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recurring class · ${cls.recurringNote}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

          Text('Select a Start Date',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const _ClassCalendar(),
          const SizedBox(height: 24),

          Row(
            children: [
              Text('Select a Time',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              const Icon(Icons.info_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Times are in ${cls.timezone}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: controller.classTimeSlots.length,
            itemBuilder: (_, i) {
              final slot = controller.classTimeSlots[i];
              return _ClassTimeSlot(slot: slot);
            },
          ),
        ],
      ),
    );
  }
}

// ── Inline calendar for class booking ─────────────────────────────────────────
class _ClassCalendar extends GetView<ScheduleController> {
  const _ClassCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final viewMonth = controller.classBookingCalendarMonth.value;
      final selected = controller.classBookingDate.value;
      final now = DateTime.now();
      final daysInMonth =
          DateTime(viewMonth.year, viewMonth.month + 1, 0).day;
      final firstWeekday =
          DateTime(viewMonth.year, viewMonth.month, 1).weekday % 7;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: AppColors.textSecondary),
                  onPressed: controller.prevClassCalendarMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: Text(
                    _monthLabel(viewMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                  onPressed: controller.nextClassCalendarMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => Expanded(
                        child: Text(d,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (_, i) {
                if (i < firstWeekday) return const SizedBox();
                final day = i - firstWeekday + 1;
                final date =
                    DateTime(viewMonth.year, viewMonth.month, day);
                final isSelected = selected != null &&
                    selected.year == date.year &&
                    selected.month == date.month &&
                    selected.day == date.day;
                final isToday = date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;
                final isPast = date.isBefore(
                    DateTime(now.year, now.month, now.day));
                return GestureDetector(
                  onTap: isPast
                      ? null
                      : () =>
                          controller.classBookingDate.value = date,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary
                                  .withValues(alpha: 0.15)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('$day',
                          style: TextStyle(
                            fontSize: 13,
                            color: isPast
                                ? AppColors.textMuted
                                : isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                          )),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// Each time slot cell — own Obx scope
class _ClassTimeSlot extends GetView<ScheduleController> {
  const _ClassTimeSlot({required this.slot});
  final String slot;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.classBookingTime.value == slot;
      return GestureDetector(
        onTap: () => controller.classBookingTime.value = slot,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color:
                    selected ? AppColors.primary : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(slot,
              style: TextStyle(
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 12)),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 3 — Confirm
// ═══════════════════════════════════════════════════════════════════════════════
class _StepConfirm extends GetView<ScheduleController> {
  const _StepConfirm({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        final dancer = controller.classBookingDancer.value;
        final date = controller.classBookingDate.value;
        final time = controller.classBookingTime.value;
        final dateStr = date != null ? _formatDate(date) : '—';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review Your Booking',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // ── Class summary ────────────────────────────────────
            _ClassSummaryCard(cls: cls),
            const SizedBox(height: 12),

            // ── Booking details ──────────────────────────────────
            _ConfirmCard(
              child: Column(
                children: [
                  _ConfirmRow(
                      icon: Icons.person_outline,
                      label: 'Student',
                      value: dancer),
                  _ConfirmRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: dateStr),
                  _ConfirmRow(
                      icon: Icons.access_time_outlined,
                      label: 'Time',
                      value: time.isEmpty ? '—' : time),
                  _ConfirmRow(
                      icon: Icons.location_on_outlined,
                      label: 'Studio',
                      value: cls.room),
                  _ConfirmRow(
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      value: '${cls.durationMinutes} minutes'),
                  _ConfirmRow(
                      icon: Icons.bar_chart_outlined,
                      label: 'Level',
                      value: cls.level),
                  _ConfirmRow(
                      icon: Icons.person_outline,
                      label: 'Instructor',
                      value: cls.instructor),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Add-ons ──────────────────────────────────────────
            _ConfirmCard(
              title: 'Optional Add-ons',
              child: Column(
                children: [
                  Text(
                    'Enhance this booking with optional extras.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ...controller.classAddOnOptions.map((addon) {
                    final selected =
                        controller.classBookingAddons.contains(addon);
                    return GestureDetector(
                      onTap: () =>
                          controller.toggleClassAddon(addon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                                  .withValues(alpha: 0.08)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                            width: selected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 18,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(addon,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: selected
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                      )),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Pricing ──────────────────────────────────────────
            _ConfirmCard(
              title: 'Pricing',
              child: Column(
                children: [
                  _PriceRow(
                      label: 'Class enrollment',
                      value: '\$${cls.durationMinutes == 60 ? '45.00' : '35.00'}'),
                  const SizedBox(height: 8),
                  _PriceRow(label: 'Service fee', value: '\$2.50'),
                  if (controller.classBookingAddons.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _PriceRow(
                        label:
                            'Add-ons (${controller.classBookingAddons.length})',
                        value: '\$${controller.classBookingAddons.length * 5}.00'),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _PriceRow(
                    label: 'Total',
                    value: _totalPrice(),
                    isTotal: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Payment is secure and encrypted.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Payment method ────────────────────────────────────
            _ConfirmCard(
              title: 'Payment Method',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F6E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('VISA',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Visa ending in 2412',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: AppColors.textPrimary)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Change',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Cancellation policy ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cancellation Policy',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          'Free cancellation up to 24 hours before the class. Late cancellations may incur a fee.',
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'By confirming, you agree to our Terms of Service.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _totalPrice() {
    final base = cls.durationMinutes == 60 ? 45.0 : 35.0;
    final addons =
        controller.classBookingAddons.length * 5.0;
    final total = base + 2.5 + addons;
    return '\$${total.toStringAsFixed(2)}';
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _ClassSummaryCard extends StatelessWidget {
  const _ClassSummaryCard({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(Icons.sports_gymnastics,
                  size: 26,
                  color: AppColors.primary.withValues(alpha: 0.5)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cls.title,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${cls.startTime} – ${cls.endTime}  •  ${cls.room}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text('Instructor: ${cls.instructor}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          _LevelBadge(level: cls.level),
        ],
      ),
    );
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({required this.child, this.title});
  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(
      {required this.label, required this.value, this.isTotal = false});
  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: isTotal
                  ? Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.textPrimary)
                  : Theme.of(context).textTheme.bodyMedium),
        ),
        Text(value,
            style: isTotal
                ? Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: AppColors.primary)
                : Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final String level;

  Color get _color {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFF9C27B0);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(level,
          style: TextStyle(color: _color, fontSize: 11)),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 10)),
    );
  }
}
