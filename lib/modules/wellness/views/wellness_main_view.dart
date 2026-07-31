import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/modules/wellness/controllers/wellness_controller.dart';
import 'package:catalyst/modules/wellness/views/wellness_account_tab.dart';
import 'package:catalyst/modules/wellness/views/wellness_classes_tab.dart';
import 'package:catalyst/modules/wellness/views/wellness_home_tab.dart';
import 'package:catalyst/modules/wellness/views/wellness_memberships_tab.dart';
import 'package:catalyst/modules/wellness/widgets/wellness_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WellnessMainView extends GetView<WellnessController> {
  const WellnessMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [
      WellnessHomeTab(),
      WellnessMembershipsTab(),
      WellnessClassesTab(),
      WellnessAccountTab(),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const WellnessAppBar(),
        body: IndexedStack(
          index: controller.currentTabIndex.value,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentTabIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.background,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.credit_card_outlined),
                activeIcon: Icon(Icons.credit_card),
                label: 'Memberships',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_available_outlined),
                activeIcon: Icon(Icons.event_available),
                label: 'Classes',
              ),
              /*BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Account',
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
