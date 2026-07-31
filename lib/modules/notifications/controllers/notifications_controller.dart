import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/api_notification_model.dart';
import 'package:catalyst/data/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final NotificationApiService _service = Get.find<NotificationApiService>();

  // ── State ──────────────────────────────────────────────────────────────
  final notifications = <ApiNotificationModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // ── Filters ────────────────────────────────────────────────────────────
  final selectedTab = 'All'.obs;
  final searchQuery = ''.obs;
  final tabs = const ['All', 'Unread', 'Bookings', 'Billing', 'Announcements'];

  // ── Selection (for bulk actions) ───────────────────────────────────────
  final selectedIds = <int>{}.obs;
  final isSelectionMode = false.obs;

  // ── Computed ───────────────────────────────────────────────────────────
  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  List<ApiNotificationModel> get filteredNotifications {
    List<ApiNotificationModel> result = notifications.toList();

    // Tab filter
    switch (selectedTab.value) {
      case 'Unread':
        result = result.where((n) => !n.isRead).toList();
        break;
      case 'Bookings':
        result = result.where((n) => n.category == 'Bookings').toList();
        break;
      case 'Billing':
        result = result.where((n) => n.category == 'Billing').toList();
        break;
      case 'Announcements':
        result = result.where((n) => n.category == 'Announcements').toList();
        break;
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.message.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // ── Fetch notifications ────────────────────────────────────────────────
  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _service.getNotifications();
      notifications.value = list;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Mark single as read ────────────────────────────────────────────────
  Future<void> markRead(int id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !notifications[idx].isRead) {
      notifications[idx] = notifications[idx].copyWith(isRead: true);
      try {
        await _service.markAsRead(id);
      } on ApiException catch (e) {
        notifications[idx] = notifications[idx].copyWith(isRead: false);
        Get.snackbar('Error', e.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white);
      }
    }
  }

  // ── Mark all as read ───────────────────────────────────────────────────
  Future<void> markAllRead() async {
    final oldList = notifications.toList();
    notifications.value =
        notifications.map((n) => n.copyWith(isRead: true)).toList();
    try {
      await _service.markAllAsRead();
      Get.snackbar('Done', 'All notifications marked as read',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white);
    } on ApiException catch (e) {
      notifications.value = oldList;
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  // ── Delete single ──────────────────────────────────────────────────────
  Future<void> deleteNotification(int id) async {
    final oldList = notifications.toList();
    notifications.removeWhere((n) => n.id == id);
    selectedIds.remove(id);
    try {
      await _service.deleteNotification(id);
    } on ApiException catch (e) {
      notifications.value = oldList;
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  // ── Bulk delete ────────────────────────────────────────────────────────
  Future<void> bulkDelete() async {
    if (selectedIds.isEmpty) return;
    final ids = selectedIds.toList();
    final oldList = notifications.toList();
    notifications.removeWhere((n) => ids.contains(n.id));
    selectedIds.clear();
    isSelectionMode.value = false;
    try {
      await _service.bulkDelete(ids);
      Get.snackbar('Done', '${ids.length} notifications deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white);
    } on ApiException catch (e) {
      notifications.value = oldList;
      Get.snackbar('Error', e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  // ── Selection helpers ──────────────────────────────────────────────────
  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    if (selectedIds.isEmpty) isSelectionMode.value = false;
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) selectedIds.clear();
  }

  void selectTab(String tab) => selectedTab.value = tab;

  void updateSearch(String query) => searchQuery.value = query;
}
