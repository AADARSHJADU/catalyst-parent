import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/api_notification_model.dart';
import 'package:catalyst/modules/notifications/controllers/notifications_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState();
        }
        return Column(
          children: [
            _SearchBar(),
            _TabBar(),
            _BulkActionBar(),
            Expanded(child: _NotificationList()),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: Get.back,
      ),
      title: const Text('Notifications'),
      actions: [
        Obx(() {
          if (controller.isSelectionMode.value) {
            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: controller.toggleSelectionMode,
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.unreadCount > 0)
                TextButton(
                  onPressed: controller.markAllRead,
                  child: Text(
                    'Mark Read (${controller.unreadCount})',
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 12),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.checklist_outlined, size: 20),
                tooltip: 'Select',
                onPressed: controller.toggleSelectionMode,
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────
class _ErrorState extends GetView<NotificationsController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.fetchNotifications,
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

// ── Search Bar ────────────────────────────────────────────────────────────────
class _SearchBar extends GetView<NotificationsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: controller.updateSearch,
        style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          hintStyle: const TextStyle(
              color: AppColors.textMuted, fontSize: 14),
          prefixIcon: const Icon(Icons.search,
              color: AppColors.textMuted, size: 20),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ),
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────
// ── Tab Bar ───────────────────────────────────────────────────────────────────
class _TabBar extends GetView<NotificationsController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final tab = controller.tabs[index];
          // Obx lives inside the lazily-built item, so the observable
          // read happens synchronously within *this* builder call.
          return Obx(() {
            final isActive = controller.selectedTab.value == tab;
            return GestureDetector(
              onTap: () => controller.selectTab(tab),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

// ── Bulk Action Bar ───────────────────────────────────────────────────────────
class _BulkActionBar extends GetView<NotificationsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isSelectionMode.value) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(
              '${controller.selectedIds.length} selected',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const Spacer(),
            if (controller.selectedIds.isNotEmpty)
              TextButton.icon(
                onPressed: controller.bulkDelete,
                icon: const Icon(Icons.delete_outline,
                    size: 16, color: AppColors.error),
                label: Text(
                  'Delete (${controller.selectedIds.length})',
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ── Notification List ─────────────────────────────────────────────────────────
class _NotificationList extends GetView<NotificationsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredNotifications;

      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_off_outlined,
                  size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                'No notifications found',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchNotifications,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _NotificationTile(notification: items[index]);
          },
        ),
      );
    });
  }
}

// ── Single Notification Tile ──────────────────────────────────────────────────
class _NotificationTile extends GetView<NotificationsController> {
  const _NotificationTile({required this.notification});
  final ApiNotificationModel notification;

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Billing':
        return Icons.payment;
      case 'Bookings':
        return Icons.calendar_today;
      case 'Announcements':
        return Icons.campaign;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'Billing':
        return AppColors.success;
      case 'Bookings':
        return AppColors.primary;
      case 'Announcements':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = notification.category;
    final color = _colorForCategory(category);

    return Obx(() {
      final isSelected =
          controller.selectedIds.contains(notification.id);
      final inSelectionMode = controller.isSelectionMode.value;

      return AppCard(
        onTap: () {
          if (inSelectionMode) {
            controller.toggleSelection(notification.id);
          } else if (!notification.isRead) {
            controller.markRead(notification.id);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection checkbox or icon
            if (inSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 4),
                child: GestureDetector(
                  onTap: () =>
                      controller.toggleSelection(notification.id),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 22,
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForCategory(category),
                  color: color,
                  size: 20,
                ),
              ),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: notification.isRead
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                        ),
                      ),
                      if (!notification.isRead && !inSelectionMode)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions menu
            if (!inSelectionMode)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.textMuted),
                color: AppColors.card,
                onSelected: (val) {
                  switch (val) {
                    case 'read':
                      controller.markRead(notification.id);
                      break;
                    case 'delete':
                      controller.deleteNotification(notification.id);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'read',
                      child: Row(
                        children: [
                          Icon(Icons.done, size: 16,
                              color: AppColors.textPrimary),
                          SizedBox(width: 8),
                          Text('Mark as Read',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16,
                            color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(
                                color: AppColors.error, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}
