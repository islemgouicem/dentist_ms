import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle sidebarItem = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static final TextTheme textTheme = TextTheme(
    bodyMedium: const TextStyle(fontSize: 14),
    titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  );
  
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyWhite = TextStyle(
    fontSize: 14,
    color: AppColors.white,
  );

  static const TextStyle numberHighlight = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle smallLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
