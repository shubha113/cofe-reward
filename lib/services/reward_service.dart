import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/redeemable.dart';
import '../models/rewards_history.dart';
import 'auth_service.dart';

class RewardService {
  final AuthService _authService = AuthService();

  // Get available rewards (now returns all items with can_redeem flag)
  Future<Map<String, dynamic>> getAvailableRewards() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.Client().get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.rewardsAvailable}'),
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
        List<Redeemable> items = [];
        int userPoints = 0;

        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          items = (data['data'] as List)
              .map((item) => Redeemable.fromJson(item))
              .toList();

          // Get user points from first item (all items have same user_points)
          userPoints = items.isNotEmpty ? items.first.userPoints : 0;
        }

        return {
          'success': true,
          'data': items,
          'user_points': userPoints,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch rewards',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Redeem a reward item
  Future<Map<String, dynamic>> redeemItem({
    required int redeemableId,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.Client().post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.rewardsRedeem}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'redeemable_id': redeemableId,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Redeemed successfully',
          'remaining_points': data['remaining_points'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Redemption failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get redemption history
  Future<Map<String, dynamic>> getRedemptionHistory() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.Client().get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.rewardsHistory}'),
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
        List<RedemptionHistory> history = [];
        if (data['data'] != null) {
          history = (data['data'] as List)
              .map((item) => RedemptionHistory.fromJson(item))
              .toList();
        }
        return {
          'success': true,
          'data': history,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch history',
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