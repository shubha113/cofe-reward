import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

class ClaimService {
  final AuthService _authService = AuthService();

  // ─────────────────────────────────────────────
  // STEP 1: Validate serial numbers → creates batch + pending claims
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>> validateSerials({
    required int productId, // ✅ ADD THIS
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
          'product_id': productId, // ✅ ADD THIS
          'serial_numbers': serialNumbers,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'batch_id': data['batch_id'],
          'results': data['results'], // [{serial_number, status, message}]
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

  // ─────────────────────────────────────────────
  // STEP 2: Upload bill photos for a batch
  // ─────────────────────────────────────────────
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

      // Add all photos as documents[]
      for (int i = 0; i < photos.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'documents[]', // ✅ FIXED - Laravel expects array notation
            photos[i].path,
          ),
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

  // ─────────────────────────────────────────────
  // STEP 3: Submit a batch for review
  // ─────────────────────────────────────────────
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
          'message': data['message'] ?? 'Claim submitted for review',
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

  // ─────────────────────────────────────────────
  // FETCH: Get all user's claimed devices with status
  // ─────────────────────────────────────────────
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
