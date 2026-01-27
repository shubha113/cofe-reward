import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

class ClaimService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> claimDevice({
    required String serialNumber,
    required File billPhoto,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/device/claim'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add serial number field
      request.fields['serial_number'] = serialNumber;

      // Add bill photo file
      request.files.add(
        await http.MultipartFile.fromPath(
          'bill_photo',
          billPhoto.path,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Success
        return {
          'success': true,
          'message': responseData['message'] ?? 'Device claimed successfully',
        };
      } else if (response.statusCode == 404) {
        // Invalid serial number
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid serial number',
        };
      } else if (response.statusCode == 409) {
        // Already claimed
        return {
          'success': false,
          'message': responseData['message'] ?? 'This device is already claimed',
        };
      } else if (response.statusCode == 422) {
        // Validation errors
        final errors = responseData['errors'];
        String errorMessage = 'Validation failed';

        if (errors != null) {
          if (errors['serial_number'] != null) {
            errorMessage = errors['serial_number'][0];
          } else if (errors['bill_photo'] != null) {
            errorMessage = errors['bill_photo'][0];
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        // Other errors
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to claim device',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}