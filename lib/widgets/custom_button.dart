import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final double? width;
  final double? height;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.width,
    this.height,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 56,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
          colors: [AppColors.lightRed, AppColors.primaryRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isEnabled ? null : AppColors.lightGreyText,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: AppTextStyles.buttonText,
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    icon,
                    color: AppColors.white,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}