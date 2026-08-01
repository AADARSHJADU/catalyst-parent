import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/private_lessons/controllers/private_lessons_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Fixes image URLs that come from API with localhost references.
String _fixImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  // Replace localhost with actual server domain
  if (url.contains('localhost') || url.contains('127.0.0.1')) {
    return url
        .replaceAll('http://localhost:8080', 'https://darksalmon-dragonfly-928313.hostingersite.com')
        .replaceAll('http://127.0.0.1:8080', 'https://darksalmon-dragonfly-928313.hostingersite.com');
  }
  // If it's a relative path, prepend the base URL
  if (!url.startsWith('http')) {
    return 'https://darksalmon-dragonfly-928313.hostingersite.com$url';
  }
  return url;
}

class PrivateLessonsView extends GetView<PrivateLessonsController> {
  const PrivateLessonsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Private Lessons'),
      ),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.currentTab.value = 0; // Switch to instructors tab
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calendar_month_outlined, size: 18),
        label: const Text('Book a New Private Lesson',
            style: TextStyle(fontSize: 13)),
      ),*/
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.instructors.isEmpty) {
          return _buildError(context);
        }
        return Column(
          children: [
            // Tabs
            _TabBar(),
            Expanded(
              child: Obx(() => controller.currentTab.value == 0
                  ? _InstructorsList()
                  : _MyBookingsList()),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Obx(() => Text(controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary))),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => controller.onInit(),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────
class _TabBar extends GetView<PrivateLessonsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Obx(() {
        final tab = controller.currentTab.value;
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.currentTab.value = 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: tab == 0 ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('Instructors',
                        style: TextStyle(
                            color: tab == 0
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.currentTab.value = 1;
                  controller.refreshBookings();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: tab == 1 ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('My Bookings',
                        style: TextStyle(
                            color: tab == 1
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Instructors List ──────────────────────────────────────────────────────────
class _InstructorsList extends GetView<PrivateLessonsController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) => controller.searchQuery.value = v,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search instructors...',
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
        const SizedBox(height: 10),
        // Instructor cards
        Expanded(
          child: Obx(() {
            final items = controller.filteredInstructors;
            if (items.isEmpty) {
              return const Center(
                child: Text('No instructors found.',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _InstructorCard(instructor: items[i]),
            );
          }),
        ),
      ],
    );
  }
}

// ── Instructor Card ───────────────────────────────────────────────────────────
class _InstructorCard extends GetView<PrivateLessonsController> {
  const _InstructorCard({required this.instructor});
  final Map<String, dynamic> instructor;

  @override
  Widget build(BuildContext context) {
    final name = instructor['name']?.toString() ?? '';
    final styles = instructor['styles']?.toString() ?? '';
    final rating = instructor['rating']?.toString() ?? '';
    final reviews = instructor['reviews']?.toString() ?? '';
    final cost = instructor['cost'];
    final experience = instructor['experienceYears']?.toString() ?? '';
    final image = _fixImageUrl(instructor['image']?.toString());

    return AppCard(
      onTap: () => Get.to(() => _InstructorDetailPage(instructor: instructor)),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage:
                image.isNotEmpty
                    ? NetworkImage(image)
                    : null,
            child: image.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(styles,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (rating.isNotEmpty) ...[
                      const Icon(Icons.star,
                          size: 13, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text('$rating ($reviews)',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11)),
                      const SizedBox(width: 10),
                    ],
                    if (experience.isNotEmpty)
                      Text(experience,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (cost != null)
                Text('\$${(cost as num).toStringAsFixed(0)}/hr',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

// ── My Bookings List ──────────────────────────────────────────────────────────
class _MyBookingsList extends GetView<PrivateLessonsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingBookings.value) {
        return const Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2));
      }
      final bookings = controller.myBookings.toList();
      if (bookings.isEmpty) {
        return const Center(
          child: Text('No bookings yet.',
              style: TextStyle(color: AppColors.textSecondary)),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshBookings,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
        ),
      );
    });
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final Map<String, dynamic> booking;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'approved':
      case 'accepted':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = booking['name']?.toString() ??
        booking['focusArea']?.toString() ??
        'Private Lesson';
    final instructor = booking['instructor']?.toString() ??
        booking['instructorName']?.toString() ??
        '';
    final studentName = booking['studentName']?.toString() ?? '';
    final dateString = booking['dateString']?.toString() ?? '';
    final duration = booking['duration']?.toString() ?? '';
    final status = (booking['status'] ??
            booking['lessonStatus'] ??
            booking['bookingStatus'])
        ?.toString()
        .toLowerCase() ??
        'pending';
    final paymentStatus =
        (booking['paymentStatus'] ?? booking['payment_status'])
            ?.toString()
            .toLowerCase() ??
        '';
    // Show Pay Now if explicitly flagged OR if lesson is approved/scheduled but unpaid
    final canPayNow = booking['canPayNow'] == true ||
        booking['can_pay_now'] == true ||
        ((status == 'scheduled' || status == 'approved' || status == 'accepted') &&
            (paymentStatus == 'unpaid' || paymentStatus == 'pending' || paymentStatus.isEmpty));
    final cost = booking['cost'] ?? booking['price'];
    final color = _statusColor(status);

    // Debug
    print('🎫 [BOOKING CARD] name=$name status=$status paymentStatus=$paymentStatus canPayNow=$canPayNow');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name,
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status.capitalize!,
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (instructor.isNotEmpty)
            _infoRow(Icons.person_outline, 'Instructor: $instructor'),
          if (studentName.isNotEmpty)
            _infoRow(Icons.child_care, 'Student: $studentName'),
          if (dateString.isNotEmpty)
            _infoRow(Icons.calendar_today_outlined, dateString),
          if (duration.isNotEmpty)
            _infoRow(Icons.timer_outlined, 'Duration: $duration'),
          if (cost != null)
            _infoRow(Icons.attach_money,
                'Cost: \$${(cost as num).toStringAsFixed(2)}'),
          if (paymentStatus.isNotEmpty)
            _infoRow(
                Icons.payment_outlined, 'Payment: ${paymentStatus.capitalize}'),
          if (canPayNow) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final lessonId = booking['id'] as int?;
                  if (lessonId != null) {
                    Get.find<PrivateLessonsController>().payForLesson(lessonId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Pay Now', style: TextStyle(fontSize: 13)),
              ),
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
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Instructor Detail Page
// ══════════════════════════════════════════════════════════════════════════════
class _InstructorDetailPage extends GetView<PrivateLessonsController> {
  const _InstructorDetailPage({required this.instructor});
  final Map<String, dynamic> instructor;

  @override
  Widget build(BuildContext context) {
    final name = instructor['name']?.toString() ?? '';
    final bio = instructor['bio']?.toString() ?? '';
    final styles = instructor['styles']?.toString() ?? '';
    final rating = instructor['rating']?.toString() ?? '';
    final reviews = instructor['reviews']?.toString() ?? '';
    final experience = instructor['experienceYears']?.toString() ?? '';
    final location = instructor['location']?.toString() ?? '';
    final image = _fixImageUrl(instructor['image']?.toString());
    final specializations = instructor['specializations'] as List? ?? [];
    final durationOptions = instructor['durationOptions'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: Text(name),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            controller.selectInstructorForBooking(instructor);
            Get.to(() => const _BookingFormPage());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Book Private Lesson',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + basic info
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage:
                  image.isNotEmpty
                      ? NetworkImage(image)
                      : null,
              child: image.isEmpty
                  ? Text(name.isNotEmpty ? name[0] : '?',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(name,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          Center(
            child: Text(styles,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(height: 8),
          // Rating + experience
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rating.isNotEmpty) ...[
                const Icon(Icons.star, size: 16, color: AppColors.warning),
                const SizedBox(width: 3),
                Text('$rating ($reviews reviews)',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 14),
              ],
              if (experience.isNotEmpty)
                Text(experience,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              if (location.isNotEmpty) ...[
                const SizedBox(width: 14),
                const Icon(Icons.location_on_outlined,
                    size: 13, color: AppColors.textMuted),
                Text(location,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ],
          ),
          const SizedBox(height: 20),
          // Bio
          if (bio.isNotEmpty) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(bio,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Specializations
          if (specializations.isNotEmpty) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Specializations',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: specializations
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(s.toString(),
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Duration options / Rates
          if (durationOptions.isNotEmpty)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lesson Rates',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...durationOptions.map((opt) {
                    final label = opt['label']?.toString() ?? '';
                    final rate = opt['rate'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(label,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13)),
                          Text(
                              rate != null
                                  ? '\$${(rate as num).toStringAsFixed(0)}'
                                  : '',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Booking Form Page
// ══════════════════════════════════════════════════════════════════════════════
class _BookingFormPage extends GetView<PrivateLessonsController> {
  const _BookingFormPage();

  @override
  Widget build(BuildContext context) {
    final instructor = controller.selectedInstructor.value!;
    final name = instructor['name']?.toString() ?? '';
    final durationOptions = instructor['durationOptions'] as List? ?? [];
    final focusCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: Text('Book with $name'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Student Selection ─────────────────────────────────
          Text('Select Student',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Obx(() {
            final students = controller.students;
            final selectedId = controller.selectedStudentId.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedId != null &&
                          students.any((s) => s['id'] == selectedId)
                      ? selectedId
                      : null,
                  isExpanded: true,
                  dropdownColor: AppColors.card,
                  hint: const Text('Select student',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 14)),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  items: students
                      .map((s) => DropdownMenuItem<int>(
                            value: s['id'] as int,
                            child: Text(
                                '${s['firstName']} ${s['lastName']}'),
                          ))
                      .toList(),
                  onChanged: (v) => controller.selectedStudentId.value = v,
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // ── Date Selection ────────────────────────────────────
          Text('Select Date',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Obx(() => GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        controller.selectedDate.value ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    controller.selectedDate.value = picked;
                    controller.fetchAvailability();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        controller.selectedDate.value != null
                            ? '${controller.selectedDate.value!.year}-${controller.selectedDate.value!.month.toString().padLeft(2, '0')}-${controller.selectedDate.value!.day.toString().padLeft(2, '0')}'
                            : 'Tap to select date',
                        style: TextStyle(
                            color: controller.selectedDate.value != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),

          // ── Available Time Slots ──────────────────────────────
          Obx(() {
            if (controller.isLoadingSlots.value) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2)),
              );
            }
            if (controller.availableSlots.isEmpty &&
                controller.selectedDate.value != null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No available slots for this date.',
                    style: TextStyle(color: AppColors.textMuted)),
              );
            }
            if (controller.availableSlots.isEmpty) {
              return const SizedBox.shrink();
            }
            final activeTime = controller.selectedTime.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Time Slots',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.availableSlots.map((slot) {
                    final isActive = activeTime == slot;
                    return GestureDetector(
                      onTap: () => controller.selectedTime.value = slot,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(slot,
                            style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 12)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),

          // ── Duration ──────────────────────────────────────────
          if (durationOptions.isNotEmpty) ...[
            Text('Duration',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Obx(() {
              final selected = controller.selectedDuration.value;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: durationOptions.map((opt) {
                  final mins = opt['mins'] as int? ?? 60;
                  final label = opt['label']?.toString() ?? '$mins min';
                  final rate = opt['rate'];
                  final isActive = selected == mins;
                  return GestureDetector(
                    onTap: () {
                      controller.selectedDuration.value = mins;
                      controller.calculatePrice();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(label,
                              style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          if (rate != null)
                            Text('\$${(rate as num).toStringAsFixed(0)}',
                                style: TextStyle(
                                    color: isActive
                                        ? Colors.white70
                                        : AppColors.textMuted,
                                    fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 16),
          ],

          // ── Focus Area ────────────────────────────────────────
          _buildTextField('Focus Area (e.g. Turns & Leaps)', focusCtrl,
              (v) => controller.focusArea.value = v),
          const SizedBox(height: 12),
          _buildTextField('Student Goal', goalCtrl,
              (v) => controller.studentGoal.value = v),
          const SizedBox(height: 12),
          _buildTextField('Additional Notes (optional)', notesCtrl,
              (v) => controller.notes.value = v,
              maxLines: 3),
          const SizedBox(height: 20),

          // ── Price ─────────────────────────────────────────────
          Obx(() {
            final price = controller.calculatedPrice.value;
            if (price == null) return const SizedBox.shrink();
            final total = price['totalCost'] ?? price['baseRate'] ?? 0;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Cost',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 14)),
                  Text('\$${(total as num).toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          // ── Submit Button ─────────────────────────────────────
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                          controller.focusArea.value = focusCtrl.text.trim();
                          controller.studentGoal.value = goalCtrl.text.trim();
                          controller.notes.value = notesCtrl.text.trim();
                          final success = await controller.submitRequest();
                          if (success) {
                            Get.back(); // Close form
                            Get.back(); // Close detail
                            controller.currentTab.value = 1; // Show bookings
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Request',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              )),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController ctrl, void Function(String) onChanged,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
