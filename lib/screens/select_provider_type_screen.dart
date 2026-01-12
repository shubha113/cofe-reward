import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/service_provider.dart';
import '../widgets/custom_button.dart';
import 'sign_up_screen.dart';

class SelectProviderTypeScreen extends StatefulWidget {
  const SelectProviderTypeScreen({Key? key}) : super(key: key);

  @override
  State<SelectProviderTypeScreen> createState() => _SelectProviderTypeScreenState();
}

class _SelectProviderTypeScreenState extends State<SelectProviderTypeScreen>
    with SingleTickerProviderStateMixin {
  String? selectedType;
  final List<ServiceProviderType> providerTypes = ServiceProviderType.getTypes();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
              AppColors.lightBlue.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Choose Your Role',
                      style: AppTextStyles.header1.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Select the option that best describes you',
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Provider Type Cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: providerTypes.length,
                  itemBuilder: (context, index) {
                    final provider = providerTypes[index];
                    final isSelected = selectedType == provider.id;
                    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          index * 0.1,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ),
                    );

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - animation.value)),
                          child: Opacity(
                            opacity: animation.value,
                            child: child,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = provider.id;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                              colors: [
                                AppColors.lightRed.withOpacity(0.1),
                                AppColors.selectedBackground,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : null,
                            color: isSelected ? null : AppColors.white,
                            borderRadius: BorderRadius.circular(AppBorderRadius.large),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : AppColors.borderGrey,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.primaryRed.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: isSelected ? 15 : 10,
                                offset: Offset(0, isSelected ? 6 : 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon Container
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                    colors: [
                                      AppColors.lightRed,
                                      AppColors.primaryRed
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                      : LinearGradient(
                                    colors: [
                                      AppColors.lightBlue,
                                      AppColors.lightBlue.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(AppBorderRadius.medium),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? AppColors.primaryRed.withOpacity(0.3)
                                          : Colors.transparent,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    provider.icon,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),

                              // Text Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.title,
                                      style: AppTextStyles.header3.copyWith(
                                        color: isSelected
                                            ? AppColors.primaryRed
                                            : AppColors.darkText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.description,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),

                              // Selection Indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                    colors: [
                                      AppColors.lightRed,
                                      AppColors.primaryRed
                                    ],
                                  )
                                      : null,
                                  color: isSelected ? null : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                    color: AppColors.borderGrey,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 18,
                                )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Next Button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: CustomButton(
                  text: 'Continue',
                  isEnabled: selectedType != null,
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    if (selectedType != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(
                            providerType: selectedType!,
                          ),
                        ),
                      );
                    }
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