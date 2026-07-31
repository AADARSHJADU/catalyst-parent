import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_assets.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WellnessAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WellnessAppBar({
    super.key,
    this.showBack = false,
    this.showMenu = true,
    this.onBack,
  });

  final bool showBack;
  final bool showMenu;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: showBack
          ? IconButton(
              onPressed: onBack ?? Get.back,
              icon: const Icon(Icons.arrow_back_ios, size: 18),
            )
          : showMenu
              ? IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                )
              : null,
      centerTitle: true,
      title: Image.asset(
          'assets/images/app_logo11.png',
          height: 36
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.notifications),
              icon: const Icon(Icons.notifications_outlined),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
