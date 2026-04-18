import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ProfileService {
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8787';
    }
    // For Android emulator
    return 'http://10.0.2.2:8787';
  }

  Future<Map<String, String>> _getHeaders(String? token) async {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final headers = await _getHeaders(token);
    final response = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    final headers = await _getHeaders(token);
    final response = await http.put(
      Uri.parse('$baseUrl/api/profile/update'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['data'] ?? {};
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final headers = await _getHeaders(token);
    final response = await http.post(
      Uri.parse('$baseUrl/api/profile/change-password'),
      headers: headers,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to change password: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String token) async {
    final headers = await _getHeaders(token);
    final response = await http.delete(
      Uri.parse('$baseUrl/api/profile/delete-account'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to delete account: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getUserStats(String token) async {
    final headers = await _getHeaders(token);
    final response = await http.get(
      Uri.parse('$baseUrl/api/profile/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }
}
