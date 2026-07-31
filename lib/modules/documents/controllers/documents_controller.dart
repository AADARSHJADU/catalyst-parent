import 'dart:async';

import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/document_model.dart';
import 'package:catalyst/data/services/document_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentsController extends GetxController {
  final DocumentService _service = Get.find<DocumentService>();

  // ── State ──────────────────────────────────────────────────────────────
  final isInitialLoading = true.obs;  // Only true on first load
  final isFetching = false.obs;       // True during any fetch (no full screen block)
  final errorMessage = ''.obs;
  final documents = <ApiDocumentModel>[].obs;
  final stats = Rx<DocumentStats>(const DocumentStats());

  // ── Pagination ─────────────────────────────────────────────────────────
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  static const int _limit = 10;

  // ── Filters ────────────────────────────────────────────────────────────
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;
  final categories = const [
    'All',
    'Waivers',
    'Policies',
    'Medical Forms',
    'Downloads',
  ];

  // ── Debounce timer ─────────────────────────────────────────────────────
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchDocuments(initial: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> fetchDocuments({bool initial = false}) async {
    if (initial) isInitialLoading.value = true;
    isFetching.value = true;
    errorMessage.value = '';
    try {
      final response = await _service.getDocuments(
        page: currentPage.value,
        limit: _limit,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        category: selectedCategory.value != 'All'
            ? selectedCategory.value
            : null,
      );
      documents.value = response.documents;
      stats.value = response.stats;
      totalPages.value = response.totalPages;
      totalItems.value = response.totalItems;
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
    currentPage.value = 1;
    fetchDocuments();
  }

  /// Debounced search — waits 500ms after last keystroke before calling API
  void setSearch(String query) {
    searchQuery.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentPage.value = 1;
      fetchDocuments();
    });
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;
    currentPage.value = page;
    fetchDocuments();
  }

  void nextPage() => goToPage(currentPage.value + 1);
  void prevPage() => goToPage(currentPage.value - 1);
}
