import '../config/api_config.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  // Send OTP (initial phone verification)
  Future<Map<String, dynamic>> sendOtp({required String phone}) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.sendOtp,
        body: {'phone': phone},
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP - FIXED: Use 'verification_code' instead of 'otp'
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.verifyOtp,
        body: {
          'phone': phone,
          'verification_code': otp,
        },
      );

      // Note: verifyPhone doesn't return token, only success message
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp({required String phone}) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.resendOtp,
        body: {'phone': phone},
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Register user - FIXED: Match backend field names exactly
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
    String? address,
    bool hasPurchased = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.register,
        body: {
          'phone': phone,
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'company_name': companyName,
          'company_type': providerType,
          'job_title': jobTitle,
          'location_state': locationState,
          'location_city': locationCity,
          'sales_representative': salesRepresentative,
          'has_purchased': hasPurchased,
          if (purchaseLocation != null && purchaseLocation.isNotEmpty)
            'purchase_location': purchaseLocation,
          if (referrer != null && referrer.isNotEmpty) 'referrer': referrer,
          if (address != null && address.isNotEmpty) 'address': address,
        },
      );

      // Save token and user data
      if (response['data'] != null) {
        if (response['data']['token'] != null) {
          await _storage.saveToken(response['data']['token']);
        }
        if (response['data']['user'] != null) {
          await _storage.saveUser(response['data']['user']);
        }
      }

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
        body: {'email': email, 'password': password},
      );

      // Save token and user data
      if (response['data'] != null) {
        if (response['data']['token'] != null) {
          await _storage.saveToken(response['data']['token']);
        }
        if (response['data']['user'] != null) {
          await _storage.saveUser(response['data']['user']);
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConfig.profile);

      // Update stored user data
      if (response['data'] != null && response['data']['user'] != null) {
        await _storage.saveUser(response['data']['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call backend logout endpoint
      await _apiClient.post(ApiConfig.logout, body: {});
    } catch (e) {
      // Continue even if backend call fails
    } finally {
      // Always clear local storage
      await _storage.clear();
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  // Get stored user
  Future<Map<String, dynamic>?> getStoredUser() async {
    return await _storage.getUser();
  }
}