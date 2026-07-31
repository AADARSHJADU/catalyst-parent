import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/announcement_model.dart';
import 'package:catalyst/modules/announcements/controllers/announcements_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AnnouncementsView extends GetView<AnnouncementsController> {
  const AnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () {
          if (controller.selectedAnnouncement.value != null) {
            controller.closeDetail();
          } else {
            Get.back();
          }
        }),
        title: Obx(() => Text(
              controller.selectedAnnouncement.value != null
                  ? 'Announcement'
                  : 'Announcements',
            )),
      ),
      body: Obx(() {
        // Detail view
        if (controller.selectedAnnouncement.value != null) {
          return _DetailView(
              announcement: controller.selectedAnnouncement.value!);
        }
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.announcements.length == 0) {
          return _ErrorView();
        }
        return _ContentView();
      }),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────
class _ErrorView extends GetView<AnnouncementsController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              onPressed: controller.fetchAnnouncements,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Content View ──────────────────────────────────────────────────────────────
class _ContentView extends GetView<AnnouncementsController> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchAnnouncements,
      color: AppColors.primary,
      child: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: controller.setSearch,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search announcements...',
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
          // Filter tabs
          SizedBox(
            height: 38,
            child: Obx(() {
              final activeFilter = controller.selectedFilter.value;
              final urgent = controller.urgentCount;
              return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final filter = controller.filters[i];
                    final isActive = activeFilter == filter;
                    return GestureDetector(
                      onTap: () => controller.setFilter(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filter,
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (filter == 'Urgent' && urgent > 0) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$urgent',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.error,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
            }),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: Obx(() {
              final items = controller.filteredAnnouncements;
              if (items.isEmpty) {
                return const Center(
                  child: Text('No announcements found.',
                      style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    _AnnouncementCard(announcement: items[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Announcement Card ─────────────────────────────────────────────────────────
class _AnnouncementCard extends GetView<AnnouncementsController> {
  const _AnnouncementCard({required this.announcement});
  final AnnouncementModel announcement;

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      return DateFormat('MMM d, yyyy • h:mm a')
          .format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (announcement.isUrgent
                          ? AppColors.error
                          : AppColors.info)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  announcement.isUrgent
                      ? Icons.warning_amber_outlined
                      : Icons.campaign_outlined,
                  size: 18,
                  color: announcement.isUrgent
                      ? AppColors.error
                      : AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(announcement.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      'By ${announcement.creatorName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (announcement.isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Urgent',
                      style: TextStyle(
                          color: AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            announcement.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                _formatDate(announcement.publishAt ?? announcement.createdAt),
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.viewDetail(announcement),
                child: const Text('Read Full →',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Detail View ───────────────────────────────────────────────────────────────
class _DetailView extends GetView<AnnouncementsController> {
  const _DetailView({required this.announcement});
  final AnnouncementModel announcement;

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      return DateFormat('MMMM d, yyyy • h:mm a')
          .format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority badge + title
              if (announcement.isUrgent)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.warning_amber, size: 14,
                          color: AppColors.error),
                      SizedBox(width: 4),
                      Text('Urgent / High Priority',
                          style: TextStyle(
                              color: AppColors.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              Text(announcement.title,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              // Meta row
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(announcement.creatorName,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(
                        announcement.publishAt ?? announcement.createdAt),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              // Body
              Text(
                announcement.body,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.7),
              ),
              if (announcement.expiresAt != null) ...[
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Expires: ${_formatDate(announcement.expiresAt)}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
