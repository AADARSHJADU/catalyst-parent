import 'package:catalyst/data/mock/wellness_mock_data.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:get/get.dart';

enum WellnessPaymentMethod { card, upi, wallets, netBanking }

class WellnessController extends GetxController {
  final currentTabIndex = 0.obs;
  final classesSubTab = 0.obs;
  final membershipsSubTab = 0.obs;
  final bookingsSubTab = 0.obs;
  final selectedPassId = 'pass10'.obs;
  final selectedPaymentMethod = WellnessPaymentMethod.card.obs;
  final selectedCategory = 'All Classes'.obs;
  final searchQuery = ''.obs;
  final favoriteClassIds = <String>{}.obs;
  final isProcessingPayment = false.obs;

  final promoCodeController = ''.obs;

  final user = WellnessMockData.wellnessUser;
  final activeMembership = WellnessMockData.activeMembership;
  final accountOverview = WellnessMockData.accountOverview;
  final passes = WellnessMockData.passes;
  final membershipFeatures = WellnessMockData.membershipFeatures;
  final purchaseHistory = WellnessMockData.purchaseHistory;
  final classes = WellnessMockData.classes;
  final upcomingBookings = WellnessMockData.upcomingBookings;
  final pastBookings = WellnessMockData.pastBookings;
  final browseCategories = WellnessMockData.browseCategories;
  final classFilterCategories = WellnessMockData.classFilterCategories;

  void changeTab(int index) => currentTabIndex.value = index;

  void changeClassesSubTab(int index) => classesSubTab.value = index;

  void changeMembershipsSubTab(int index) => membershipsSubTab.value = index;

  void changeBookingsSubTab(int index) => bookingsSubTab.value = index;

  void selectPass(String id) => selectedPassId.value = id;

  void selectPaymentMethod(WellnessPaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  void selectCategory(String category) => selectedCategory.value = category;

  void toggleFavorite(String classId) {
    if (favoriteClassIds.contains(classId)) {
      favoriteClassIds.remove(classId);
    } else {
      favoriteClassIds.add(classId);
    }
  }

  WellnessPassModel get selectedPass =>
      passes.firstWhere((p) => p.id == selectedPassId.value);

  double get subtotal => selectedPass.price;

  double get tax => subtotal * WellnessMockData.taxRate;

  double get total => subtotal + tax;

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  String get formattedTax => '\$${tax.toStringAsFixed(2)}';

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  List<WellnessClassModel> get filteredClasses {
    var result = classes.toList();
    if (selectedCategory.value != 'All Classes') {
      result = result
          .where((c) => c.category == selectedCategory.value)
          .toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result
          .where(
            (c) =>
                c.title.toLowerCase().contains(q) ||
                c.category.toLowerCase().contains(q) ||
                c.instructor.toLowerCase().contains(q),
          )
          .toList();
    }
    return result;
  }

  List<WellnessClassModel> get favoriteClasses =>
      classes.where((c) => favoriteClassIds.contains(c.id)).toList();

  List<WellnessBookingModel> get currentBookings =>
      bookingsSubTab.value == 0 ? upcomingBookings : pastBookings;

  Future<void> processPayment() async {
    isProcessingPayment.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isProcessingPayment.value = false;
  }

  void goToMemberships() {
    currentTabIndex.value = 1;
  }

  void goToClasses({int subTab = 0}) {
    currentTabIndex.value = 2;
    classesSubTab.value = subTab;
  }

  void goToMyBookings() {
    currentTabIndex.value = 2;
    classesSubTab.value = 1;
  }
}
