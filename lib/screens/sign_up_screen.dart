import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/service_provider.dart';
import '../widgets/custom_button.dart';
import 'job_title_selection_screen.dart';
import 'location_selection_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String providerType;

  const SignUpScreen({
    Key? key,
    required this.providerType,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? selectedState;
  String? selectedCity;
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _navigateToJobTitleSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JobTitleSelectionScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _jobTitleController.text = result;
      });
    }
  }

  void _navigateToLocationSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationSelectionScreen(),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        selectedState = result['state'];
        selectedCity = result['city'];
        _locationController.text = '${result['state']}, ${result['city']}';
      });
    }
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isRequired)
              const Text(
                '* ',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              label,
              style: AppTextStyles.inputLabel.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: readOnly ? onTap : null,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IgnorePointer(
              ignoring: readOnly,
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                keyboardType: keyboardType,
                obscureText: obscureText,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.inputHint,
                  prefixIcon: prefixIcon != null
                      ? Icon(prefixIcon, color: AppColors.primaryRed)
                      : null,
                  suffixIcon: suffixIcon ??
                      (readOnly
                          ? const Icon(Icons.arrow_forward_ios,
                          size: 16, color: AppColors.greyText)
                          : null),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerTypeName = ServiceProviderType.getTypes()
        .firstWhere((type) => type.id == widget.providerType)
        .title;

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
              // Enhanced Header with Progress
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Navigation Bar
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              print('STATE: $selectedState');
                              print('CITY: $selectedCity');

                              if (selectedState != null && selectedCity != null) {
                                Navigator.pop(context, {
                                  'state': selectedState!,
                                  'city': selectedCity!,
                                });
                              }
                            },


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
                        ],
                      ),
                    ),

                    // Animated Progress Indicator Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step indicator with animation
                              Row(
                                children: [
                                  // Step 1 Circle
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppColors.lightRed,
                                                AppColors.primaryRed,
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryRed.withOpacity(0.4),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text(
                                              '1',
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Animated connecting line
                                  Expanded(
                                    child: Container(
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.greyBackground,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _progressAnimation.value * 2,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppColors.lightRed,
                                                AppColors.primaryRed,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryRed.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Step 2 Circle
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.greyBackground,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.borderGrey,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '2',
                                        style: TextStyle(
                                          color: AppColors.greyText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Step Labels
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Basic Info',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.primaryRed,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Step 1 of 2',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.greyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Verification',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.greyText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Coming next',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.lightGreyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Title and Subtitle
                              Text(
                                'Create Account',
                                style: AppTextStyles.header1.copyWith(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryRed.withOpacity(0.1),
                                          AppColors.lightRed.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.primaryRed.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified_user,
                                          size: 14,
                                          color: AppColors.primaryRed,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Join as $providerTypeName',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primaryRed,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildInputField(
                          label: 'Company Name',
                          hint: 'Enter your company name',
                          controller: _companyController,
                          isRequired: true,
                          prefixIcon: Icons.business,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildInputField(
                          label: 'Job Title',
                          hint: 'Select your job title',
                          controller: _jobTitleController,
                          isRequired: true,
                          readOnly: true,
                          onTap: _navigateToJobTitleSelection,
                          prefixIcon: Icons.work_outline,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildInputField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          isRequired: true,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildInputField(
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          controller: _phoneController,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildInputField(
                          label: 'Location',
                          hint: 'Select your location',
                          controller: _locationController,
                          isRequired: true,
                          readOnly: true,
                          onTap: _navigateToLocationSelection,
                          prefixIcon: Icons.location_on_outlined,
                        ),

                        if (selectedState != null && selectedCity != null)
                          Container(
                            margin: const EdgeInsets.only(top: AppSpacing.sm),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.selectedBackground,
                              borderRadius: BorderRadius.circular(AppBorderRadius.small),
                              border: Border.all(
                                color: AppColors.primaryRed.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryRed,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Selected: $selectedState, $selectedCity',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primaryRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Terms and Conditions
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                            border: Border.all(
                              color: AppColors.illustrationBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppColors.illustrationDarkBlue,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'By signing up, you agree to our Terms & Conditions',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Continue Button
                        CustomButton(
                          text: 'Next',
                          icon: Icons.arrow_forward,
                          onPressed: () {
                            // Validate
                            if (_companyController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter company name'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (_jobTitleController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select job title'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (_emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter email'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (selectedState == null || selectedCity == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select location'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }

                            // Success - Would navigate to Step 2
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Step 1 completed! Ready for verification...'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}