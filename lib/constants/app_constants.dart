import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryRed = Color(0xFFE01C08);
  static const Color lightRed= Color(0xFFF36A5C);

  // Background Colors
  static const Color lightBlue = Color(0xFFE8F4F8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyBackground = Color(0xFFF5F5F5);

  // Text Colors
  static const Color darkText = Color(0xFF2D3436);
  static const Color greyText = Color(0xFF636E72);
  static const Color lightGreyText = Color(0xFFB2BEC3);

  // Illustration Colors (tuned to match primary red tone)
  static const Color illustrationBlue = Color(0xFF6B8FD6);
  static const Color illustrationDarkBlue = Color(0xFF4A6FC8);
  static const Color workerBlue = Color(0xFF2D4F8D);

  // Selection Colors
  static const Color selectedBackground = Color(0xFFFFECE9);
  static const Color selectedBorder = primaryRed;

  // Error Colors
  static const Color errorRed = primaryRed;

  // Border Colors
  static const Color borderGrey = Color(0xFFE0E0E0);
}

class AppTextStyles {
  // Headers
  static const TextStyle header1 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
    fontFamily: 'Roboto',
  );

  static const TextStyle header2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
    fontFamily: 'Roboto',
  );

  static const TextStyle header3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
    fontFamily: 'Roboto',
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkText,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.greyText,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.lightGreyText,
    fontFamily: 'Roboto',
  );

  // Button Text
  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    fontFamily: 'Roboto',
  );

  // Input Text
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.darkText,
    fontFamily: 'Roboto',
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkText,
    fontFamily: 'Roboto',
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.lightGreyText,
    fontFamily: 'Roboto',
  );

  // Link Text
  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF2196F3),
    fontFamily: 'Roboto',
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 24.0;
  static const double button = 30.0;
}