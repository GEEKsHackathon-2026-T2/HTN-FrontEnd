import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3D7BFA);
  static const Color primaryDark = Color(0xFF2E5FE0);
  static const Color primaryLight = Color(0xFFEAF1FE);

  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF8B93A7);
  static const Color divider = Color(0xFFEEF1F6);

  static const LinearGradient bannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4C8CFB), Color(0xFF7B6BF5)],
  );
}
