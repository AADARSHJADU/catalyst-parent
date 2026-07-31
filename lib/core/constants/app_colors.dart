import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFF26A21);
  static const Color secondary = Color(0xFFD33721);
  static const Color card = Color(0xFF141416);
  static const Color background = Color(0xFF120D0C);
  static const Color surface = Color(0xFF1A1A1A);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color border = Color(0xFF2A2A2A);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);

  static const Color wellness = Color(0xFF9C27B0);
  static const Color wellnessLight = Color(0xFFBA68C8);
  static const Color info = Color(0xFF42A5F5);

  static const LinearGradient wellnessGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [secondary, primary],
  );
}
