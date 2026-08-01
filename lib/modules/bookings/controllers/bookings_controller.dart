import 'dart:async';

import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/services/bookings_history_service.dart';
import 'package:get/get.dart';

class MyBookingsController extends GetxController {
  final BookingsHistoryService _service = Get.find<BookingsHistoryService>();

  // ── State ──────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // ── Tabs ───────────────────────────────────────────────────────────────
  final selectedTab = 0.obs;
  final tabs = const [
    'Classes',
    'Private Lessons',
    'Wellness',
    'Choreography',
    'Routines',
  ];

  // ── Data per tab ───────────────────────────────────────────────────────
  final items = <Map<String, dynamic>>[].obs;
  final totalItems = 0.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;

  // ── Filters ────────────────────────────────────────────────────────────
  final searchQuery = ''.obs;
  final paymentStatusFilter = 'All'.obs;
  final paymentStatuses = const ['All', 'Paid', 'Pending', 'Refunded'];

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void selectTab(int index) {
    selectedTab.value = index;
    currentPage.value = 1;
    fetchData();
  }

  void setSearch(String query) {
    searchQuery.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentPage.value = 1;
      fetchData();
    });
  }

  void setPaymentStatus(String status) {
    paymentStatusFilter.value = status;
    currentPage.value = 1;
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      Map<String, dynamic> response;

      switch (selectedTab.value) {
        case 0: // Classes
          response = await _service.getClassHistory(
            page: currentPage.value,
            search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
            paymentStatus: paymentStatusFilter.value,
            type: 'group',
          );
          break;
        case 1: // Private Lessons
          response = await _service.getPrivateHistory(
            page: currentPage.value,
            search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
            paymentStatus: paymentStatusFilter.value,
          );
          break;
        case 2: // Wellness
          response = await _service.getClassHistory(
            page: currentPage.value,
            search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
            paymentStatus: paymentStatusFilter.value,
            type: 'wellness',
          );
          break;
        case 3: // Choreography
          response = await _service.getChoreographyHistory(
            page: currentPage.value,
            search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
            paymentStatus: paymentStatusFilter.value,
          );
          break;
        case 4: // Routines
          response = await _service.getClassHistory(
            page: currentPage.value,
            search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
            paymentStatus: paymentStatusFilter.value,
            type: 'routine',
          );
          break;
        default:
          response = {};
      }

      // Parse items and pagination
      final rawItems = response['items'] ??
          response['bookings'] ??
          response['data'] ??
          [];
      items.value = List<Map<String, dynamic>>.from(rawItems as List);

      final pagination = response['pagination'] as Map<String, dynamic>?;
      if (pagination != null) {
        totalItems.value = pagination['total'] as int? ??
            pagination['totalItems'] as int? ??
            items.length;
        totalPages.value = pagination['totalPages'] as int? ?? 1;
        currentPage.value = pagination['page'] as int? ??
            pagination['currentPage'] as int? ??
            1;
      } else {
        // Try top-level pagination fields
        totalItems.value = response['total'] as int? ?? items.length;
        totalPages.value = response['totalPages'] as int? ?? 1;
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong.';
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchData();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchData();
    }
  }
}
