import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';
import 'select_provider_type_screen.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isSendingOtp = false;

  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.primaryRed),
    );
  }

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.length != 10) {
      _showError('Enter valid 10-digit phone number');
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      await _authService.sendLoginOtp(phone: _phoneController.text.trim());

      setState(() => _otpSent = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.length != 10) {
      _showError('Enter valid phone number');
      return;
    }

    if (_otpController.text.length != 6) {
      _showError('Enter valid OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.loginWithOtp(
        phone: _phoneController.text.trim(),
        otp: _otpController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Login successful'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.white, AppColors.lightBlue.withValues(alpha: 0.3)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // Welcome Header
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.header1.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sign in to continue your journey',
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Illustration Card
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFE01C08)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.xlarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -20,
                            bottom: -20,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          // Icon
                          // Image Logo replacement
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Image.asset(
                                        'assets/images/cofee.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Text(
                                  'COFE REWARD',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Phone field
                    Text(
                      'Phone Number',
                      style: AppTextStyles.inputLabel.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
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
                        style: AppTextStyles.inputText,
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: AppColors.primaryRed,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.medium,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          counterText: '',
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Send OTP button
                    CustomButton(
                      text: _isSendingOtp
                          ? 'Sending OTP...'
                          : (_otpSent ? 'OTP Sent' : 'Send OTP'),
                      onPressed: () {
                        if (!_otpSent && !_isSendingOtp) {
                          _handleSendOtp();
                        }
                      },
                      isEnabled: !_otpSent && !_isSendingOtp,
                      icon: Icons.sms,
                    ),

                    if (_otpSent) ...[
                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'OTP',
                        style: AppTextStyles.inputLabel.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.medium,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: AppTextStyles.inputText,
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: AppColors.primaryRed,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.medium,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      CustomButton(
                        text: _isLoading ? 'Verifying...' : 'Login',
                        onPressed: () => _handleLogin(),
                        isEnabled: !_isLoading,
                        icon: Icons.login,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
