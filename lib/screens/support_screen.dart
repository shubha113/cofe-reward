import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.support_agent,
                    color: AppColors.primaryRed,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Support',
                    style: AppTextStyles.header2.copyWith(fontSize: 24),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.lightRed.withValues(alpha: 0.2),
                            AppColors.primaryRed.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.support_agent_outlined,
                        size: 60,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Support Page',
                      style: AppTextStyles.header2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Coming soon...',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}