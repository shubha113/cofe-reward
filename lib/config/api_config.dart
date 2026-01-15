class ApiConfig {
  //Base URL
  static const String baseUrl = 'http://192.168.0.113:5000/api';

  //Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String me = '/auth/me';

  //Profile endpoints
  static const String profile = '/user';
  static const String favorites = '/user/favorites';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Static OTP for development
  static const String staticOTP = '123456';
}
