import '../config/api_config.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  // Register user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String companyName,
    required String jobTitle,
    required String locationState,
    required String locationCity,
    required String providerType,
    required String salesRepresentative,
    String? purchaseLocation,
    String? referrer,
    bool hasPurchased = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.register,
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'company_name': companyName,
          'job_title': jobTitle,
          'location_state': locationState,
          'location_city': locationCity,
          'provider_type': providerType,
          'sales_representative': salesRepresentative,
          if (purchaseLocation != null) 'purchase_location': purchaseLocation,
          if (referrer != null) 'referrer': referrer,
          'has_purchased': hasPurchased,
        },
      );

      // Save user data temporarily (before verification)
      if (response['user'] != null) {
        await _storage.saveUser(response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.verifyOtp,
        body: {
          'phone': phone,
          'otp': otp,
        },
      );

      // Save token and user data
      if (response['token'] != null) {
        await _storage.saveToken(response['token']);
      }
      if (response['user'] != null) {
        await _storage.saveUser(response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.resendOtp,
        body: {
          'phone': phone,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      // Save token and user data
      if (response['token'] != null) {
        await _storage.saveToken(response['token']);
      }
      if (response['user'] != null) {
        await _storage.saveUser(response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConfig.me);

      // Update stored user data
      if (response['user'] != null) {
        await _storage.saveUser(response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    // Just clear local storage
    await _storage.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  // Get stored user
  Future<Map<String, dynamic>?> getStoredUser() async {
    return await _storage.getUser();
  }
}