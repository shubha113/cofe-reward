import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';

class SignUp2Screen extends StatefulWidget {
  final String providerType;
  final Map<String, String> step1Data;

  const SignUp2Screen({
    Key? key,
    required this.providerType,
    required this.step1Data,
  }) : super(key: key);

  @override
  State<SignUp2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUp2Screen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _salesRepController = TextEditingController();
  final TextEditingController _purchaseLocationController = TextEditingController();
  final TextEditingController _referrerController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPhoneVerified = false;
  bool _hasPurchased = false;
  bool _agreedToTerms = false;
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

    _progressAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _salesRepController.dispose();
    _purchaseLocationController.dispose();
    _referrerController.dispose();
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
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
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppColors.primaryRed)
                  : null,
              suffixIcon: suffixIcon,
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
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '* ',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Phone Number',
              style: AppTextStyles.inputLabel.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.inputText,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    hintStyle: AppTextStyles.inputHint,
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: AppColors.primaryRed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+91',
                            style: AppTextStyles.inputText.copyWith(
                              color: AppColors.illustrationDarkBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: AppColors.borderGrey,
                            margin: const EdgeInsets.only(left: 8),
                          ),
                        ],
                      ),
                    ),
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
                    counterText: '',
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: _isPhoneVerified
                  ? null
                  : () {
                if (_phoneController.text.length == 10) {
                  setState(() {
                    _isPhoneVerified = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP sent to your phone!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid phone number'),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPhoneVerified
                    ? Colors.green
                    : AppColors.primaryRed,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                elevation: 0,
              ),
              child: Text(
                _isPhoneVerified ? 'Verified' : 'Verify',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
              AppColors.lightBlue.withValues(alpha: 0.2),
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
                      color: Colors.black.withValues(alpha: 0.08),
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
                                  // Step 1 Circle (Completed)
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check,
                                        color: AppColors.white,
                                        size: 20,
                                      ),
                                    ),
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
                                        widthFactor: _progressAnimation.value,
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
                                                color: AppColors.primaryRed.withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Step 2 Circle (Active)
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
                                                color: AppColors.primaryRed.withValues(alpha: 0.4),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text(
                                              '2',
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
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Completed ✓',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: Colors.green,
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
                                            color: AppColors.primaryRed,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Step 2 of 2',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.greyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Title
                              Text(
                                'Complete Your Profile',
                                style: AppTextStyles.header1.copyWith(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Just a few more details to get started',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.greyText,
                                ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _nameController,
                          isRequired: true,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildPhoneField(),
                        const SizedBox(height: AppSpacing.lg),

                        // OTP Field with resend link
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputField(
                              label: 'Verification Code',
                              hint: 'Enter 6-digit OTP',
                              controller: _otpController,
                              isRequired: true,
                              prefixIcon: Icons.security,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('OTP resent successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: Text(
                                  'Didn\'t receive verification code?',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.illustrationDarkBlue,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildInputField(
                          label: 'Password',
                          hint: 'Create a strong password',
                          controller: _passwordController,
                          isRequired: true,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.greyText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildInputField(
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          controller: _confirmPasswordController,
                          isRequired: true,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.greyText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildInputField(
                          label: 'Sales Representative',
                          hint: 'Enter sales representative name',
                          controller: _salesRepController,
                          isRequired: true,
                          prefixIcon: Icons.support_agent,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Optional Fields Section Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppBorderRadius.small),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.illustrationDarkBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Optional Information',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildInputField(
                          label: 'Where do you purchase Cofe products?',
                          hint: 'Enter purchase location',
                          controller: _purchaseLocationController,
                          isRequired: false,
                          prefixIcon: Icons.store_outlined,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _buildInputField(
                          label: 'Referrer',
                          hint: 'Enter referrer name (if any)',
                          controller: _referrerController,
                          isRequired: false,
                          prefixIcon: Icons.person_add_outlined,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Have you purchased Cofe products?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '* ',
                                  style: TextStyle(
                                    color: AppColors.primaryRed,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Have you purchased Cofe products?',
                                  style: AppTextStyles.inputLabel.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _hasPurchased = true;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: _hasPurchased
                                            ? AppColors.selectedBackground
                                            : AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                            AppBorderRadius.medium),
                                        border: Border.all(
                                          color: _hasPurchased
                                              ? AppColors.primaryRed
                                              : AppColors.borderGrey,
                                          width: _hasPurchased ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _hasPurchased
                                                    ? AppColors.primaryRed
                                                    : AppColors.borderGrey,
                                                width: 2,
                                              ),
                                              color: _hasPurchased
                                                  ? AppColors.primaryRed
                                                  : AppColors.white,
                                            ),
                                            child: _hasPurchased
                                                ? const Center(
                                              child: Icon(
                                                Icons.circle,
                                                size: 12,
                                                color: AppColors.white,
                                              ),
                                            )
                                                : null,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            'Yes',
                                            style: AppTextStyles.bodyLarge.copyWith(
                                              fontWeight: _hasPurchased
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: _hasPurchased
                                                  ? AppColors.primaryRed
                                                  : AppColors.darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _hasPurchased = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: !_hasPurchased
                                            ? AppColors.selectedBackground
                                            : AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                            AppBorderRadius.medium),
                                        border: Border.all(
                                          color: !_hasPurchased
                                              ? AppColors.primaryRed
                                              : AppColors.borderGrey,
                                          width: !_hasPurchased ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: !_hasPurchased
                                                    ? AppColors.primaryRed
                                                    : AppColors.borderGrey,
                                                width: 2,
                                              ),
                                              color: !_hasPurchased
                                                  ? AppColors.primaryRed
                                                  : AppColors.white,
                                            ),
                                            child: !_hasPurchased
                                                ? const Center(
                                              child: Icon(
                                                Icons.circle,
                                                size: 12,
                                                color: AppColors.white,
                                              ),
                                            )
                                                : null,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            'No',
                                            style: AppTextStyles.bodyLarge.copyWith(
                                              fontWeight: !_hasPurchased
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: !_hasPurchased
                                                  ? AppColors.primaryRed
                                                  : AppColors.darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Terms and Conditions Checkbox
                        InkWell(
                          onTap: () {
                            setState(() {
                              _agreedToTerms = !_agreedToTerms;
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: _agreedToTerms
                                      ? AppColors.primaryRed
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _agreedToTerms
                                        ? AppColors.primaryRed
                                        : AppColors.borderGrey,
                                    width: 2,
                                  ),
                                ),
                                child: _agreedToTerms
                                    ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.white,
                                )
                                    : null,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.darkText,
                                      height: 1.5,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to follow the '),
                                      TextSpan(
                                        text:
                                        '\'Partner Program Term Policy, Policy Term of Use\'',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.illustrationDarkBlue,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Sign Up Button
                        CustomButton(
                          text: 'Sign Up',
                          icon: Icons.check_circle,
                          onPressed: () {
                            // Validation
                            if (_nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your name'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (_phoneController.text.length != 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter valid phone number'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (!_isPhoneVerified) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please verify your phone number'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (_otpController.text.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter valid OTP'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (_passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter password'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (_salesRepController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text('Please enter sales representative name'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }
                            if (!_agreedToTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please agree to terms and conditions'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              return;
                            }

                            // Success
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account created successfully! 🎉'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Navigate to home screen using named route
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/signin',
                                    (route) => false,
                              );
                            });
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