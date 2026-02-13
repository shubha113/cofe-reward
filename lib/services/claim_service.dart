import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

class ClaimService {
  final AuthService _authService = AuthService();

  // Validate serial numbers - NOW CLAIMS IMMEDIATELY
  Future<Map<String, dynamic>> validateSerials({
    required int productId,
    required List<String> serialNumbers,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.Client().post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.claimValidate}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'product_id': productId,
          'serial_numbers': serialNumbers,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'batch_id': data['batch_id'],
          'results': data['results'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Validation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Upload bill photos
  Future<Map<String, dynamic>> uploadDocuments({
    required int batchId,
    required List<File> photos,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.claimDocuments(batchId)}'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      for (int i = 0; i < photos.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('documents[]', photos[i].path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Documents uploaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Upload installation photos with location
  Future<Map<String, dynamic>> uploadInstallationPhotos({
    required List<Map<String, dynamic>> photos,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.claimInstallationPhotos}'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      for (int i = 0; i < photos.length; i++) {
        final photoData = photos[i];

        request.fields['photos[$i][claim_id]'] = photoData['claim_id'].toString();

        if (photoData['latitude'] != null) {
          request.fields['photos[$i][latitude]'] = photoData['latitude'].toString();
        }
        if (photoData['longitude'] != null) {
          request.fields['photos[$i][longitude]'] = photoData['longitude'].toString();
        }
        if (photoData['address'] != null) {
          request.fields['photos[$i][address]'] = photoData['address'].toString();
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'photos[$i][photo]',
            photoData['photo'].path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Installation photos uploaded successfully',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Submit batch (photos uploaded, finalizing)
  Future<Map<String, dynamic>> submitBatch({required int batchId}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.Client().post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.claimSubmit(batchId)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Photos submitted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Submit failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get all user's claims
  Future<Map<String, dynamic>> getMyBatches() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.Client().get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.claimMyClaims}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again.',
        };
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch claims',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}