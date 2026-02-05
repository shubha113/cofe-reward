class ApiConfig {
  /// BASE URL
  // The base domain
  static const String domain = 'https://cofesolutions.cofesolutions.com';
  //http://192.168.0.102:8000
  //https://cofesolutions.cofesolutions.com

  // API path
  static const String baseUrl = '$domain/api/v1';

  // Image/Storage path
  static const String storageUrl = '$domain/storage/';

  /// AUTH ENDPOINTS
  static const String sendOtp = '/auth/send-otp';
  static const String loginSendOtp = '/auth/login/send-otp';
  static const String verifyOtp = '/auth/verify-phone';
  static const String resendOtp = '/auth/resend-otp';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String loginOtp = '/auth/login-otp';
  static const String logout = '/auth/logout';
  static const String profile = '/profile';

  /// DEVICE CLAIM ENDPOINTS
  static const String claimValidate = '/device/claim/validate';
  static const String claimMyClaims = '/device/claim/my-claims';
  static String claimDocuments(int batchId) => '/device/claim/$batchId/documents';
  static String claimSubmit(int batchId) => '/device/claim/$batchId/submit';
  static const String claimInstallationPhotos = '/device/claim/installation-photos';

  /// CATEGORY ENDPOINTS
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