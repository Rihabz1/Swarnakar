import 'package:flutter/foundation.dart';

class RecaptchaService {
  RecaptchaService._();

  static final RecaptchaService instance = RecaptchaService._();

  Future<String?> getToken({String action = 'phone_auth'}) async {
    if (!kIsWeb) {
      return null;
    }

    return null;
  }
}