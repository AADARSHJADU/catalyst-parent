import 'package:cached_network_image/cached_network_image.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/data/mock/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FlowAppBar({
    super.key,
    required this.title,
    this.showNotification = true,
    this.notificationCount = 3,
    this.onBack,
  });

  final String title;
  final bool showNotification;
  final int notificationCount;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        onPressed: onBack ?? Get.back,
        icon: Container(
          padding: const EdgeInsets.all(6),
          /*decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),*/
          child: const Icon(Icons.arrow_back_ios, size: 18),
        ),
      ),
      title: Text(title),
      /*actions: [
        if (showNotification)
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.card,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: MockData.profileImageUrl,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Icon(Icons.person, size: 16),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.person, size: 16),
              ),
            ),
          ),
        ),
      ],*/
    );
  }
}
