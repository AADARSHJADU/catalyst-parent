import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookLessonView extends GetView<PrivateLessonsController> {
  const BookLessonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.bookingStep.value;
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
                controller.bookingStep.value = step - 1;
              }
            },
          ),
          title: Text(_stepTitle(step)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: _StepProgressBar(
                currentStep: step, totalSteps: 4),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(
            key: ValueKey(step),
            child: _stepBody(step),
          ),
        ),
        bottomNavigationBar: _StepBottomBar(step: step),
      );
    });
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Select Instructor';
      case 1:
        return 'Date & Time';
      case 2:
        return 'Lesson Details';
      case 3:
        return 'Confirm Booking';
      default:
        return '';
    }
  }

  Widget _stepBody(int step) {
    switch (step) {
      case 0:
        return const _Step1SelectInstructor();
      case 1:
        return const _Step2DateTime();
      case 2:
        return const _Step3Details();
      case 3:
        return const _Step4Confirm();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Progress bar ───────────────────────────────────────────────────────────────
class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar(
      {required this.currentStep, required this.totalSteps});
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final done = i <= currentStep;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 2 : 0),
            color: done
                ? AppColors.primary
                : AppColors.border,
          ),
        );
      }),
    );
  }
}

// ── Bottom nav bar with back/next ──────────────────────────────────────────────
class _StepBottomBar extends GetView<PrivateLessonsController> {
  const _StepBottomBar({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border:
            Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Obx(() {
        final canNext = _canProceed();
        final isLast = step == 3;
        return Row(
          children: [
            if (step > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      controller.bookingStep.value = step - 1,
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
                        ? () => controller.confirmBooking()
                        : () => controller.bookingStep.value = step + 1)
                    : null,
                icon: isLast
                    ? Obx(() => controller.isBooking.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ))
                        : const Icon(Icons.lock_outline, size: 16))
                    : const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  isLast ? 'Confirm Booking' : _nextLabel(),
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
        return controller.selectedInstructor.value != null;
      case 1:
        return controller.selectedDate.value != null &&
            controller.selectedTime.value.isNotEmpty;
      case 2:
        return controller.selectedFocusAreas.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  String _backLabel() {
    switch (step) {
      case 1:
        return 'Instructor';
      case 2:
        return 'Date & Time';
      case 3:
        return 'Details';
      default:
        return 'Back';
    }
  }

  String _nextLabel() {
    switch (step) {
      case 0:
        return 'Next: Date & Time';
      case 1:
        return 'Next: Details';
      case 2:
        return 'Next: Confirm';
      default:
        return 'Next';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 1 — Select Instructor
// ═══════════════════════════════════════════════════════════════════════════════
class _Step1SelectInstructor
    extends GetView<PrivateLessonsController> {
  const _Step1SelectInstructor();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Find the perfect instructor',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              // Search box
              TextField(
                onChanged: (v) => controller.searchQuery.value = v,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by name or style...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textSecondary, size: 20),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final instructors = controller.filteredInstructors;
            if (instructors.isEmpty) {
              return const Center(
                  child: Text('No instructors found',
                      style: TextStyle(
                          color: AppColors.textSecondary)));
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: instructors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  _InstructorCard(instructor: instructors[i]),
            );
          }),
        ),
      ],
    );
  }
}

class _InstructorCard extends GetView<PrivateLessonsController> {
  const _InstructorCard({required this.instructor});
  final InstructorModel instructor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected =
          controller.selectedInstructor.value?.id == instructor.id;
      return GestureDetector(
        onTap: () => controller.selectedInstructor.value = instructor,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
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
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      _initials(instructor.name),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 11, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(instructor.name,
                        style:
                            Theme.of(context).textTheme.titleMedium),
                    Text(instructor.specialty,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 12, color: AppColors.warning),
                        const SizedBox(width: 3),
                        Text(
                          '${instructor.rating} (${instructor.reviewCount} reviews)',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${instructor.hourlyRate.toInt()}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.primary),
                  ),
                  Text('/hr',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}';
    }
    return name.substring(0, 2);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 2 — Date & Time
// ═══════════════════════════════════════════════════════════════════════════════
class _Step2DateTime extends GetView<PrivateLessonsController> {
  const _Step2DateTime();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected instructor mini-card
          Obx(() {
            final ins = controller.selectedInstructor.value;
            if (ins == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      '${ins.name.split(' ').first[0]}${ins.name.split(' ').last[0]}',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ins.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium),
                        Text(ins.specialty,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        controller.bookingStep.value = 0,
                    child: const Text('Change',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12)),
                  ),
                ],
              ),
            );
          }),

          // Calendar
          Text('Select a Date',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const _InlineCalendar(),
          const SizedBox(height: 24),

          // Time slots
          Row(
            children: [
              Text('Select a Time',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              const Icon(Icons.info_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('All times CDT',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          // Build the grid outside Obx; each cell observes selectedTime individually
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
            itemCount: controller.timeSlots.length,
            itemBuilder: (_, i) {
              final slot = controller.timeSlots[i];
              return _TimeSlotCell(slot: slot);
            },
          ),
        ],
      ),
    );
  }
}

class _InlineCalendar extends GetView<PrivateLessonsController> {
  const _InlineCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final viewMonth = controller.calendarMonth.value;
      final selected = controller.selectedDate.value;
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
            // Month navigation
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: AppColors.textSecondary),
                  onPressed: controller.prevCalendarMonth,
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
                  onPressed: controller.nextCalendarMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Day headers
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => Expanded(
                        child: Text(d,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Days grid
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
                final isPast = date
                    .isBefore(DateTime(now.year, now.month, now.day));

                return GestureDetector(
                  onTap: isPast
                      ? null
                      : () => controller.selectedDate.value = date,
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
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          color: isPast
                              ? AppColors.textMuted
                              : isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                        ),
                      ),
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

// ── Time slot cell — each observes selectedTime independently ──────────────────
class _TimeSlotCell extends GetView<PrivateLessonsController> {
  const _TimeSlotCell({required this.slot});
  final String slot;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedTime.value == slot;
      return GestureDetector(
        onTap: () => controller.selectedTime.value = slot,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            slot,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 3 — Lesson Details
// ═══════════════════════════════════════════════════════════════════════════════
class _Step3Details extends GetView<PrivateLessonsController> {
  const _Step3Details();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Lesson Details ─────────────────────────────────────────
          _SectionTitle(title: 'Lesson Details'),
          const SizedBox(height: 12),
          // Dance style dropdown
          Obx(() => _DropdownTile(
                icon: Icons.sports_gymnastics_outlined,
                label: 'Dance Style (Primary)',
                value: controller.selectedDanceStyle.value,
                options: controller.danceStyles,
                onChanged: (v) =>
                    controller.selectedDanceStyle.value = v,
              )),
          const SizedBox(height: 24),

          // ── Focus areas ────────────────────────────────────────────
          _SectionTitle(title: 'What would you like to focus on?'),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.focusOptions.map((area) {
                  final selected =
                      controller.selectedFocusAreas.contains(area);
                  return GestureDetector(
                    onTap: () => controller.toggleFocusArea(area),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.1)
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            area,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: selected
                                ? const Icon(Icons.check_circle,
                                    size: 16,
                                    color: AppColors.primary,
                                    key: ValueKey('on'))
                                : Icon(Icons.circle_outlined,
                                    size: 16,
                                    color: AppColors.textMuted,
                                    key: const ValueKey('off')),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 24),

          // ── Additional info ────────────────────────────────────────
          _SectionTitle(title: 'Additional Information'),
          const SizedBox(height: 12),
          _NotesField(),
          const SizedBox(height: 24),

          // ── Lesson preferences ─────────────────────────────────────
          _SectionTitle(title: 'Lesson Preferences'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() => _DropdownTile(
                      icon: Icons.location_on_outlined,
                      label: 'Lesson Location',
                      value: controller.selectedStudio.value,
                      options: controller.studioOptions,
                      onChanged: (v) => controller.selectedStudio.value = v,
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _DropdownTile(
                      icon: Icons.videocam_outlined,
                      label: 'Mirrors / Recording',
                      value: controller.selectedRecording.value,
                      options: controller.recordingOptions,
                      onChanged: (v) =>
                          controller.selectedRecording.value = v,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NotesField extends GetView<PrivateLessonsController> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: 300,
      maxLines: 4,
      onChanged: (v) => controller.additionalNotes.value = v,
      style: const TextStyle(
          color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText:
            'Add any specific goals or notes for your instructor (optional)',
        hintStyle: const TextStyle(
            color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(14),
        counterStyle: const TextStyle(color: AppColors.textMuted),
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
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10)),
                  Text(value,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final opt = options[index];

                    return ListTile(
                      title: Text(
                        opt,
                        style: TextStyle(
                          color: opt == value
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      trailing: opt == value
                          ? const Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 16,
                      )
                          : null,
                      onTap: () {
                        onChanged(opt);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 4 — Confirm Booking
// ═══════════════════════════════════════════════════════════════════════════════
class _Step4Confirm extends GetView<PrivateLessonsController> {
  const _Step4Confirm();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        final ins = controller.selectedInstructor.value;
        final date = controller.selectedDate.value;
        final time = controller.selectedTime.value;
        if (ins == null) return const SizedBox.shrink();

        final dateStr = date != null ? _formatDate(date) : '—';
        final endTime = _addHour(time);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review Your Booking',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // ── Instructor summary ───────────────────────────────
            _ConfirmSection(
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          '${ins.name.split(' ').first[0]}${ins.name.split(' ').last[0]}',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Instructor',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: AppColors.textMuted)),
                            Text(ins.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium),
                            Text(
                                '${ins.specialty} · ${controller.selectedStudio.value}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 12,
                                    color: AppColors.warning),
                                const SizedBox(width: 3),
                                Text(
                                    '${ins.rating} (${ins.reviewCount} reviews)',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Booking details ──────────────────────────────────
            _ConfirmSection(
              child: Column(
                children: [
                  _ConfirmRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: dateStr,
                  ),
                  _ConfirmRow(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value:
                        '$time – $endTime (60 mins)',
                  ),
                  _ConfirmRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: controller.selectedStudio.value,
                  ),
                  _ConfirmRow(
                    icon: Icons.sports_gymnastics_outlined,
                    label: 'Dance Style',
                    value: controller.selectedDanceStyle.value,
                  ),
                  _ConfirmRow(
                    icon: Icons.track_changes_outlined,
                    label: 'Focus',
                    value: controller.selectedFocusAreas.isEmpty
                        ? '—'
                        : controller.selectedFocusAreas.join(', '),
                  ),
                  if (controller.additionalNotes.value.isNotEmpty)
                    _ConfirmRow(
                      icon: Icons.notes_outlined,
                      label: 'Notes',
                      value: controller.additionalNotes.value,
                    ),
                  _ConfirmRow(
                    icon: Icons.videocam_outlined,
                    label: 'Recording',
                    value: controller.selectedRecording.value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Pricing ──────────────────────────────────────────
            _ConfirmSection(
              title: 'Booking Summary',
              child: Column(
                children: [
                  _PriceRow(
                      label: 'Lesson (60 mins)',
                      value:
                          '\$${controller.lessonPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _PriceRow(
                      label: 'Service Fee',
                      value:
                          '\$${controller.serviceFee.toStringAsFixed(2)}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child:
                        Divider(height: 1, color: AppColors.border),
                  ),
                  _PriceRow(
                    label: 'Total',
                    value:
                        '\$${controller.total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Your payment information is secure and encrypted.',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Payment method ────────────────────────────────────
            _ConfirmSection(
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
                            ?.copyWith(color: AppColors.textPrimary)),
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

            // ── Promo code ─────────────────────────────────────────
            _ConfirmSection(
              child: Row(
                children: [
                  const Icon(Icons.local_offer_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text('Have a promo code?',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Add Code',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Need to make changes ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Need to make changes?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColors.textPrimary)),
                        Text(
                            'You can go back to any step to update your booking details.',
                            style:
                                Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'By confirming, you agree to our Terms of Service and Cancellation Policy.',
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
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _addHour(String time) {
    if (time.isEmpty) return '';
    try {
      final parts = time.split(' ');
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      final min = hm[1];
      final period = parts[1];
      int h = hour;
      String p = period;
      if (period == 'PM' && hour != 12) h = hour + 12;
      if (period == 'AM' && hour == 12) h = 0;
      h = (h + 1) % 24;
      p = h >= 12 ? 'PM' : 'AM';
      final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$displayH:$min $p';
    } catch (_) {
      return '';
    }
  }
}

// ── Confirm section wrapper ────────────────────────────────────────────────────
class _ConfirmSection extends StatelessWidget {
  const _ConfirmSection({required this.child, this.title});
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
            width: 90,
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
      {required this.label,
      required this.value,
      this.isTotal = false});
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
        Text(
          value,
          style: isTotal
              ? Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.primary)
              : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
        ),
      ],
    );
  }
}

// ── Section title ──────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}
