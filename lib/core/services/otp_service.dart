import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/data/firebase_auth_service.dart';

class OtpService {
  final FirebaseAuthService _phoneAuthService = FirebaseAuthService.instance;
  String? _phoneVerificationId;

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

  Future<Map<String, dynamic>> sendPhoneOtp(
    String phoneNumber,
    String recaptchaToken,
  ) async {
    final phoneE164 = _phoneAuthService.toBdE164(phoneNumber);
    String? failureMessage;

    if (kIsWeb && recaptchaToken.isEmpty) {
      throw Exception('reCAPTCHA token is required for web phone authentication');
    }

    await _phoneAuthService.sendOtp(
      phoneE164: phoneE164,
      onCodeSent: (verificationId, resendToken) {
        _phoneVerificationId = verificationId;
      },
      onFailed: (message) {
        failureMessage = message;
      },
      onAutoVerified: () {},
    );

    if (failureMessage != null) {
      throw Exception(failureMessage);
    }

    return <String, dynamic>{
      'verificationId': _phoneVerificationId,
      'phoneNumber': phoneE164,
      'maskedPhoneNumber': _maskPhoneNumber(phoneE164),
    };
  }

  Future<bool> verifyPhoneOtp(String phoneNumber, String code) async {
    final phoneE164 = _phoneAuthService.toBdE164(phoneNumber);

    if (_phoneVerificationId == null) {
      throw Exception('Verification session expired. Request a new code.');
    }

    final user = await _phoneAuthService.verifyOtp(
      verificationId: _phoneVerificationId!,
      otp: code,
      phone: phoneE164,
    );
    return user != null;
  }

  Future<bool> checkPhoneNumber(String phoneNumber) async {
    try {
      _phoneAuthService.toBdE164(phoneNumber);
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearPhoneVerification() {
    _phoneVerificationId = null;
  }

  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 8) {
      return phoneNumber;
    }
    final last4 = phoneNumber.substring(phoneNumber.length - 4);
    return '****$last4';
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
