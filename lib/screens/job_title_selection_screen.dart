import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/service_provider.dart';

class JobTitleSelectionScreen extends StatefulWidget {
  const JobTitleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<JobTitleSelectionScreen> createState() => _JobTitleSelectionScreenState();
}

class _JobTitleSelectionScreenState extends State<JobTitleSelectionScreen> {
  String? selectedJobTitle;
  final List<JobTitle> jobTitles = JobTitle.getJobTitles();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.white,
              AppColors.lightBlue.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.greyBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Select Job Title',
                          style: AppTextStyles.header3.copyWith(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Job Titles List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: jobTitles.length,
                  itemBuilder: (context, index) {
                    final jobTitle = jobTitles[index];
                    final isSelected = selectedJobTitle == jobTitle.title;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedJobTitle = jobTitle.title;
                        });
                        // Small delay for visual feedback
                        Future.delayed(const Duration(milliseconds: 200), () {
                          Navigator.pop(context, jobTitle.title);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [
                              AppColors.lightRed.withValues(alpha: 0.1),
                              AppColors.selectedBackground,
                            ],
                          )
                              : null,
                          color: isSelected ? null : AppColors.white,
                          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryRed
                                : AppColors.borderGrey,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.primaryRed.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                  colors: [
                                    AppColors.lightRed,
                                    AppColors.primaryRed
                                  ],
                                )
                                    : LinearGradient(
                                  colors: [
                                    AppColors.lightBlue,
                                    AppColors.lightBlue.withValues(alpha: 0.7),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.work_outline,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.primaryRed,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                jobTitle.title,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primaryRed
                                      : AppColors.darkText,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.lightRed,
                                      AppColors.primaryRed
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}