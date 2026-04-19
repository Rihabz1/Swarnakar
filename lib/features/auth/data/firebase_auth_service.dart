import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String toBdE164(String localPhone) {
    final digits = localPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('01') && digits.length == 11) {
      return '+880${digits.substring(1)}';
    }
    if (digits.startsWith('8801') && digits.length == 13) {
      return '+$digits';
    }
    if (digits.startsWith('880') && digits.length == 13) {
      return '+$digits';
    }
    throw FirebaseAuthException(
      code: 'invalid-phone-number',
      message: 'সঠিক মোবাইল নম্বর দিন।',
    );
  }

  Future<void> sendOtp({
    required String phoneE164,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onFailed,
    int? forceResendingToken,
    void Function()? onAutoVerified,
  }) async {
    final completer = Completer<void>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final credentialResult = await _auth.signInWithCredential(credential);
          await _saveUserProfileSafely(
            credentialResult.user,
            phone: credentialResult.user?.phoneNumber,
          );
          onAutoVerified?.call();
        } catch (_) {
          // Ignore auto-verification errors and allow manual OTP fallback.
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onFailed(_friendlyMessage(e));
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeAutoRetrievalTimeout: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    await completer.future;
  }

  Future<User?> verifyOtp({
    required String verificationId,
    required String otp,
    String? name,
    String? phone,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final result = await _auth.signInWithCredential(credential);
    await _saveUserProfileSafely(result.user, name: name, phone: phone);
    return result.user;
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    await _saveUserProfileSafely(result.user);
    return result.user;
  }

  Future<void> _saveUserProfileSafely(User? user, {String? name, String? phone}) async {
    try {
      await _saveUserProfile(user, name: name, phone: phone)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Best-effort profile sync; auth should not fail if Firestore is unavailable.
    }
  }

  Future<void> _saveUserProfile(User? user, {String? name, String? phone}) async {
    if (user == null) return;

    final now = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(user.uid).set(
      {
        'uid': user.uid,
        'name': name ?? user.displayName ?? '',
        'email': user.email ?? '',
        'phone': phone ?? user.phoneNumber ?? '',
        'provider': user.providerData.isNotEmpty ? user.providerData.first.providerId : 'unknown',
        'isSubscribed': false,
        'lastLoginAt': now,
        'updatedAt': now,
        'createdAt': now,
      },
      SetOptions(merge: true),
    );
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'মোবাইল নম্বর সঠিক নয়।';
      case 'too-many-requests':
        return 'অনেকবার চেষ্টা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।';
      case 'session-expired':
        return 'OTP এর সময়সীমা শেষ। নতুন OTP নিন।';
      case 'invalid-verification-code':
        return 'OTP সঠিক নয়। আবার দিন।';
      default:
        return e.message ?? 'অথেনটিকেশন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';
    }
  }
}
