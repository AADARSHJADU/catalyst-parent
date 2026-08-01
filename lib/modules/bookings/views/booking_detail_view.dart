import 'package:catalyst/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Legacy booking detail — now booking details are shown inline.
class BookingDetailView extends StatelessWidget {
  const BookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Booking Detail'),
      ),
      body: const Center(
        child: Text('Booking details now shown in My Bookings tab.',
            style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
