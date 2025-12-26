import 'package:flutter/material.dart';
import 'package:my_app/core/constants/app_colors.dart';

class AppTextStyles {
  static const introMain = TextStyle(
    fontFamily: 'Noto Sans',
    color: AppColors.textcolor02,
    fontSize: 43,
    fontWeight: FontWeight.w100,
    height: 1.02,
    letterSpacing: -0.2,
  );

  static const introSub = TextStyle(
    fontFamily: 'Noto Sans',
    color: AppColors.textcolor03,
    fontSize: 45,
    fontWeight: FontWeight.w600,
    height: 1.02,
  );

  static const title = TextStyle(
    fontFamily: 'Noto Sans',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.textcolor02,
    height: 1.3,
  );

  static const body = TextStyle(
    fontFamily: 'Noto Sans',
    fontSize: 17,
    color: AppColors.textcolor01,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const bodyMuted = TextStyle(
    fontFamily: 'Noto Sans',
    fontSize: 14,
    color: AppColors.textcolor03,
  );
}
