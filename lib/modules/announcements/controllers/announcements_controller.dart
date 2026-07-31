import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/announcement_model.dart';
import 'package:catalyst/data/services/announcement_service.dart';
import 'package:get/get.dart';

class AnnouncementsController extends GetxController {
  final AnnouncementService _service = Get.find<AnnouncementService>();

  // ── State ──────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final announcements = <AnnouncementModel>[].obs;

  // ── Filters (client-side) ──────────────────────────────────────────────
  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;
  final filters = const ['All', 'Urgent', 'Normal'];

  // ── Detail view ────────────────────────────────────────────────────────
  final selectedAnnouncement = Rxn<AnnouncementModel>();

  // ── Computed ───────────────────────────────────────────────────────────
  List<AnnouncementModel> get filteredAnnouncements {
    // Access .length to ensure GetX registers this as observable read
    final _ = announcements.length;
    List<AnnouncementModel> result = List<AnnouncementModel>.from(announcements);

    // Priority filter
    final filter = selectedFilter.value;
    switch (filter) {
      case 'Urgent':
        result = result.where((a) => a.isUrgent).toList();
        break;
      case 'Normal':
        result = result.where((a) => !a.isUrgent).toList();
        break;
    }

    // Search
    final query = searchQuery.value;
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.body.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  int get urgentCount {
    final _ = announcements.length;
    return announcements.where((a) => a.isUrgent).length;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _service.getAnnouncements();
      announcements.assignAll(result);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) => selectedFilter.value = filter;
  void setSearch(String query) => searchQuery.value = query;

  void viewDetail(AnnouncementModel announcement) {
    selectedAnnouncement.value = announcement;
  }

  void closeDetail() {
    selectedAnnouncement.value = null;
  }
}
