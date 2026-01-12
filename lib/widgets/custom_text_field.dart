import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isRequired;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? errorText;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.controller,
    this.isRequired = false,
    this.readOnly = false,
    this.onTap,
    this.errorText,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isRequired)
              const Text(
                '*',
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Text(
              label,
              style: AppTextStyles.inputLabel,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: readOnly ? onTap : null,
          child: AbsorbPointer(
            absorbing: readOnly,
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.inputHint,
                filled: true,
                fillColor: AppColors.white,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: errorText != null ? AppColors.errorRed : AppColors.borderGrey,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: errorText != null ? AppColors.errorRed : AppColors.borderGrey,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryRed,
                    width: 2,
                  ),
                ),
                suffixIcon: readOnly
                    ? const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.greyText,
                )
                    : null,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}