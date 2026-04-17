import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OtpService {
  String get _baseUrl {
    const envBase = String.fromEnvironment('OTP_API_BASE_URL');
    if (envBase.isNotEmpty) {
      return envBase;
    }

    if (kIsWeb) {
      return 'http://localhost:8787';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8787';
      default:
        return 'http://localhost:8787';
    }
  }

  Future<void> sendOtp({required String email, String purpose = 'reset'}) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/auth/otp/send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'purpose': purpose}),
        )
        .timeout(const Duration(seconds: 15));

    final body = _tryDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String code,
    String purpose = 'reset',
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/auth/otp/verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'code': code, 'purpose': purpose}),
        )
        .timeout(const Duration(seconds: 15));

    final body = _tryDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Failed to verify OTP');
    }
  }

  Future<String> verifyResetOtp({
    required String email,
    required String code,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/auth/otp/verify-reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otp': code}),
        )
        .timeout(const Duration(seconds: 15));

    final body = _tryDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Failed to verify reset OTP');
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final token = data['resetToken'] as String?;
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }

    throw Exception('Reset token missing from server response');
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/auth/password/reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'resetToken': resetToken, 'newPassword': newPassword}),
        )
        .timeout(const Duration(seconds: 15));

    final body = _tryDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Failed to reset password');
    }
  }

  Map<String, dynamic> _tryDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
