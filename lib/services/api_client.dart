import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final StorageService _storage = StorageService();

  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
      )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
      )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        message: data['message'] ?? 'Something went wrong',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle errors
  String _handleError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}

// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => message;
}