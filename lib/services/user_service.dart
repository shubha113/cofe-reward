import '../config/api_config.dart';
import 'api_client.dart';
import 'storage_service.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  // Get profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConfig.profile);

      // Update stored user data
      if (response['user'] != null) {
        await _storage.saveUser(response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? companyName,
    String? jobTitle,
    String? locationState,
    String? locationCity,
    String? purchaseLocation,
    String? referrer,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (companyName != null) body['company_name'] = companyName;
      if (jobTitle != null) body['job_title'] = jobTitle;
      if (locationState != null) body['location_state'] = locationState;
      if (locationCity != null) body['location_city'] = locationCity;
      if (purchaseLocation != null) body['purchase_location'] = purchaseLocation;
      if (referrer != null) body['referrer'] = referrer;

      final response = await _apiClient.put(
        ApiConfig.profile,
        body: body,
      );

      // Update stored user data
      if (response['user'] != null) {
        await _storage.saveUser(response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }
}