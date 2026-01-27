class ApiConfig {
  /// BASE URL
  // The base domain
  static const String domain = 'http://192.168.0.102:8000';

  // API path
  static const String baseUrl = '$domain/api/v1';

  // Image/Storage path
  static const String storageUrl = '$domain/storage/';

  /// AUTH ENDPOINTS
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-phone';
  static const String resendOtp = '/auth/resend-otp';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/profile';

  /// DEVICE CLAIM ENDPOINT
  static const String claimDevice = '/device/claim';

  /// CATEGORY ENDPOINTS (NEW - ID based)
  static const String categories = '/categories';
  static String categorySubcategories(int mainCategoryId) =>
      '/categories/$mainCategoryId/subcategories';

  /// PRODUCT ENDPOINTS
  static const String products = '/products';
  static const String productSearch = '/products/search';
  static String productById(int id) => '/products/$id';
  static String productsByMainCategoryId(int mainCategoryId) =>
      '/products/main-category/$mainCategoryId';
  static String productsByCategoryId(int categoryId) =>
      '/products/category/$categoryId';
  static String productsBySubcategoryId(int subcategoryId) =>
      '/products/subcategory/$subcategoryId';

  /// TIMEOUTS
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// DEV HELPERS
  static const String staticOTP = '123456';
}