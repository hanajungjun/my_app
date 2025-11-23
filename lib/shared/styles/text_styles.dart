import 'package:flutter/material.dart';
import 'package:my_app/core/constants/app_colors.dart';

class AppTextStyles {
  static const introMain = TextStyle(
    color: AppColors.titleBlue,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const introSub = TextStyle(
    color: AppColors.highlightPink,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const title = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.titleBlue,
    height: 1.3,
  );

  static const body = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textMain,
  );

  static const bodyMuted = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textSub,
  );
}
