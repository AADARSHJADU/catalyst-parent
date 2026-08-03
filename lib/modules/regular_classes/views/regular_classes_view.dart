import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/regular_classes/controllers/regular_classes_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Fixes image URLs from API (localhost → real server, relative → absolute).
String _fixUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.contains('localhost') || url.contains('127.0.0.1')) {
    return url
        .replaceAll('http://localhost:8080', 'https://darksalmon-dragonfly-928313.hostingersite.com')
        .replaceAll('http://127.0.0.1:8080', 'https://darksalmon-dragonfly-928313.hostingersite.com');
  }
  if (!url.startsWith('http')) {
    return 'https://darksalmon-dragonfly-928313.hostingersite.com$url';
  }
  return url;
}

class RegularClassesView extends GetView<RegularClassesController> {
  const RegularClassesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Regular Classes'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.classes.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(controller.errorMessage.value,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => controller.onInit(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            _Tabs(),
            Expanded(
              child: Obx(() => controller.currentTab.value == 0
                  ? _BrowseClasses()
                  : _MyEnrollments()),
            ),
          ],
        );
      }),
    );
  }
}

class _Tabs extends GetView<RegularClassesController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Obx(() {
        final tab = controller.currentTab.value;
        return Row(
          children: [
            _tabBtn('Browse Classes', 0, tab),
            const SizedBox(width: 8),
            _tabBtn('My Enrollments', 1, tab),
          ],
        );
      }),
    );
  }

  Widget _tabBtn(String label, int index, int active) {
    final isActive = index == active;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.currentTab.value = index;
          if (index == 1) controller.refreshBookings();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

// ── Browse Classes ────────────────────────────────────────────────────────────
class _BrowseClasses extends GetView<RegularClassesController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) => controller.searchQuery.value = v,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search classes...',
              hintStyle:
                  const TextStyle(color: AppColors.textMuted, fontSize: 14),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Obx(() {
            final items = controller.filteredClasses;
            if (items.isEmpty) {
              return const Center(
                  child: Text('No classes found.',
                      style: TextStyle(color: AppColors.textSecondary)));
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ClassCard(classData: items[i]),
            );
          }),
        ),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classData});
  final Map<String, dynamic> classData;

  @override
  Widget build(BuildContext context) {
    final name = classData['name']?.toString() ?? '';
    final instructor = classData['instructorName']?.toString() ?? '';
    final schedule = classData['schedule']?.toString() ?? '';
    final level = classData['level']?.toString() ?? '';
    final style = classData['danceStyle']?.toString() ?? '';
    final cost = classData['cost'];
    final capacity = classData['capacity'] as int? ?? 0;
    final enrolled = classData['enrolledCount'] as int? ?? 0;
    final available = classData['availableSeats'] as int? ?? (capacity - enrolled);
    final isFull = classData['isFull'] == true || available <= 0;
    final waitlist = classData['waitlistCount'] as int? ?? 0;
    final rawImage = classData['classImage']?.toString() ?? '';
    final image = _fixUrl(rawImage);

    return AppCard(
      onTap: () => Get.to(() => _ClassDetailPage(classData: classData)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class image
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.music_note_outlined,
                      size: 36, color: AppColors.primary),
                ),
              ),
            )
          else
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.music_note_outlined,
                  size: 36, color: AppColors.primary),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(name, style: Theme.of(context).textTheme.titleSmall),
              ),
              if (cost != null)
                Text('\$${(cost as num).toStringAsFixed(0)}/mo',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          if (instructor.isNotEmpty) _chip(Icons.person_outline, instructor),
          if (schedule.isNotEmpty) _chip(Icons.schedule_outlined, schedule),
          if (level.isNotEmpty || style.isNotEmpty)
            _chip(Icons.bar_chart_outlined, [level, style].where((s) => s.isNotEmpty).join(' • ')),
          const SizedBox(height: 8),
          // Capacity bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: capacity > 0 ? enrolled / capacity : 0,
                    backgroundColor: AppColors.surface,
                    color: isFull ? AppColors.error : AppColors.success,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$enrolled/$capacity',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                isFull ? 'Full' : '$available seats available',
                style: TextStyle(
                    color: isFull ? AppColors.error : AppColors.success,
                    fontSize: 11, fontWeight: FontWeight.w500),
              ),
              if (waitlist > 0) ...[
                const SizedBox(width: 10),
                Text('$waitlist on waitlist',
                    style: const TextStyle(color: AppColors.warning, fontSize: 11)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(child: Text(text,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

// ── My Enrollments ────────────────────────────────────────────────────────────
class _MyEnrollments extends GetView<RegularClassesController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bookings = controller.myBookings.toList();
      if (bookings.isEmpty) {
        return const Center(
            child: Text('No enrollments yet.',
                style: TextStyle(color: AppColors.textSecondary)));
      }
      return RefreshIndicator(
        onRefresh: controller.refreshBookings,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _EnrollmentCard(booking: bookings[i]),
        ),
      );
    });
  }
}

class _EnrollmentCard extends GetView<RegularClassesController> {
  const _EnrollmentCard({required this.booking});
  final Map<String, dynamic> booking;

  @override
  Widget build(BuildContext context) {
    final name = booking['name']?.toString() ?? 'Class';
    final instructor = booking['instructor']?.toString() ?? '';
    final studentName = booking['studentName']?.toString() ?? '';
    final paymentStatus = booking['paymentStatus']?.toString() ?? '';
    final enrollmentStatus = booking['enrollmentStatus']?.toString() ?? '';
    final joiningDate = booking['joiningDate']?.toString() ?? '';
    final cost = booking['cost'] ?? booking['amountPaid'];
    final id = booking['id'] as int?;
    final bookingType = booking['bookingType']?.toString() ?? '';
    final isPaid = paymentStatus.toLowerCase() == 'paid';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPaid ? AppColors.success : AppColors.warning)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(paymentStatus,
                    style: TextStyle(
                        color: isPaid ? AppColors.success : AppColors.warning,
                        fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (instructor.isNotEmpty)
            _row(Icons.person_outline, instructor),
          if (studentName.isNotEmpty)
            _row(Icons.child_care, studentName),
          if (enrollmentStatus.isNotEmpty)
            _row(Icons.check_circle_outline, 'Status: $enrollmentStatus'),
          if (joiningDate.isNotEmpty)
            _row(Icons.calendar_today_outlined, 'Joined: $joiningDate'),
          if (bookingType == 'waitlist')
            _row(Icons.hourglass_empty, 'On Waitlist'),
          if (cost != null)
            _row(Icons.attach_money, '\$${(cost as num).toStringAsFixed(2)}'),
          if (id != null && bookingType != 'waitlist') ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmDrop(context, id),
                icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                label: const Text('Drop Class',
                    style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(child: Text(text,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        ],
      ),
    );
  }

  void _confirmDrop(BuildContext context, int id) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Drop Class'),
      content: const Text('Are you sure you want to drop this enrollment?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.dropEnrollment(id);
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Drop'),
        ),
      ],
    ));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Class Detail + Booking
// ══════════════════════════════════════════════════════════════════════════════
class _ClassDetailPage extends GetView<RegularClassesController> {
  const _ClassDetailPage({required this.classData});
  final Map<String, dynamic> classData;

  @override
  Widget build(BuildContext context) {
    final name = classData['name']?.toString() ?? '';
    final instructor = classData['instructorName']?.toString() ?? '';
    final schedule = classData['schedule']?.toString() ?? '';
    final level = classData['level']?.toString() ?? '';
    final style = classData['danceStyle']?.toString() ?? '';
    final ageGroup = classData['ageGroup']?.toString() ?? '';
    final description = classData['description']?.toString() ?? '';
    final cost = classData['cost'];
    final capacity = classData['capacity'] as int? ?? 0;
    final enrolled = classData['enrolledCount'] as int? ?? 0;
    final available = classData['availableSeats'] as int? ?? (capacity - enrolled);
    final isFull = classData['isFull'] == true || available <= 0;
    final studioName = classData['studioName']?.toString() ?? '';
    final roomName = classData['roomName']?.toString() ?? '';
    final classId = classData['id'] as int;
    final image = _fixUrl(classData['classImage']?.toString() ?? '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _showBookingSheet(context, classId, name),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(isFull ? 'Join Waitlist' : 'Book This Class',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Class image with placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(name),
                  )
                : _imagePlaceholder(name),
          ),
          const SizedBox(height: 14),
          // Price + capacity
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (cost != null)
                      Text('\$${(cost as num).toStringAsFixed(0)}/month',
                          style: const TextStyle(color: AppColors.primary,
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('$available of $capacity seats available',
                        style: TextStyle(
                            color: isFull ? AppColors.error : AppColors.success,
                            fontSize: 12)),
                  ]),
                ),
                CircularProgressIndicator(
                  value: capacity > 0 ? enrolled / capacity : 0,
                  backgroundColor: AppColors.surface,
                  color: isFull ? AppColors.error : AppColors.success,
                  strokeWidth: 6,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Details
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _detail(Icons.person_outline, 'Instructor', instructor),
              _detail(Icons.schedule, 'Schedule', schedule),
              _detail(Icons.bar_chart, 'Level', level),
              _detail(Icons.music_note, 'Style', style),
              _detail(Icons.people_outline, 'Age Group', ageGroup),
              _detail(Icons.location_on_outlined, 'Studio', '$roomName, $studioName'),
              if (description.isNotEmpty) ...[
                const Divider(color: AppColors.border),
                const SizedBox(height: 6),
                Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5)),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(String name) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note_outlined, size: 48,
              color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Text(name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _detail(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        Expanded(child: Text(value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
      ]),
    );
  }

  void _showBookingSheet(BuildContext context, int classId, String className) {
    controller.selectedClassId.value = classId;
    controller.joiningDate.value = null;
    if (controller.students.isNotEmpty) {
      controller.selectedStudentId.value = controller.students.first['id'] as int?;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.8,
          builder: (_, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: Container(width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              Text('Book: $className', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              // Student
              const Text('Student', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.selectedStudentId.value,
                    isExpanded: true, dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    items: controller.students.map((s) => DropdownMenuItem<int>(
                      value: s['id'] as int,
                      child: Text('${s['firstName']} ${s['lastName']}'),
                    )).toList(),
                    onChanged: (v) => controller.selectedStudentId.value = v,
                  ),
                ),
              )),
              const SizedBox(height: 14),
              // Joining date
              const Text('Joining Date', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Obx(() => GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) controller.joiningDate.value = picked;
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border)),
                  child: Text(
                    controller.joiningDate.value != null
                        ? '${controller.joiningDate.value!.year}-${controller.joiningDate.value!.month.toString().padLeft(2, '0')}-${controller.joiningDate.value!.day.toString().padLeft(2, '0')}'
                        : 'Tap to select',
                    style: TextStyle(color: controller.joiningDate.value != null
                        ? AppColors.textPrimary : AppColors.textMuted, fontSize: 14),
                  ),
                ),
              )),
              const SizedBox(height: 20),
              // Buttons
              Obx(() => Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isBooking.value ? null : () async {
                        final success = await controller.bookOnline(classId);
                        if (success) { Get.back(); Get.back(); controller.currentTab.value = 1; }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: controller.isBooking.value
                          ? const SizedBox(height: 18, width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Pay Online (Stripe)'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.isBooking.value ? null : () async {
                        final success = await controller.bookPayLater(classId);
                        if (success) { Get.back(); Get.back(); controller.currentTab.value = 1; }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Pay Later / Cash'),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
