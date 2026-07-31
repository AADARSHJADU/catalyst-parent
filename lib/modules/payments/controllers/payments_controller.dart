import 'dart:async';

import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/billing_model.dart';
import 'package:catalyst/data/services/billing_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentsController extends GetxController {
  final BillingService _service = Get.find<BillingService>();

  // ── State ──────────────────────────────────────────────────────────────
  final isInitialLoading = true.obs;
  final isFetching = false.obs;
  final errorMessage = ''.obs;

  // ── Data ───────────────────────────────────────────────────────────────
  final summary = Rx<BillingSummary>(const BillingSummary());
  final transactions = <BillingTransaction>[].obs;

  // ── Filters ────────────────────────────────────────────────────────────
  final selectedCategory = ''.obs; // empty = All
  final searchQuery = ''.obs;
  final categories = const [
    '',
    'Regular Class',
    'Choreography Fee',
    'Private Lesson',
    'Wellness Pass',
    'Routine Class',
  ];
  final categoryLabels = const [
    'All',
    'Regular Class',
    'Choreography',
    'Private Lesson',
    'Wellness Pass',
    'Routine',
  ];

  // ── Receipt view ───────────────────────────────────────────────────────
  final selectedTransaction = Rxn<BillingTransaction>();

  // ── Debounce ───────────────────────────────────────────────────────────
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchBilling(initial: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> fetchBilling({bool initial = false}) async {
    if (initial) isInitialLoading.value = true;
    isFetching.value = true;
    errorMessage.value = '';
    try {
      final response = await _service.getBilling(
        category: selectedCategory.value.isNotEmpty
            ? selectedCategory.value
            : null,
        search:
            searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );
      summary.value = response.summary;
      transactions.value = response.transactions;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isInitialLoading.value = false;
      isFetching.value = false;
    }
  }

  void setCategory(String cat) {
    selectedCategory.value = cat;
    fetchBilling();
  }

  void setSearch(String query) {
    searchQuery.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchBilling();
    });
  }

  void viewReceipt(BillingTransaction txn) {
    selectedTransaction.value = txn;
  }

  void closeReceipt() {
    selectedTransaction.value = null;
  }
}
