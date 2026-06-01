import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class FirebaseService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleSignInInitialization;
  static const Duration _firestoreOpTimeout = Duration(seconds: 8);
  
  // Phone Authentication State
  String? _phoneVerificationId;

  bool get _isFirebaseAuthPlatformSupported {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  bool get _isGoogleSignInPlatformSupported {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  FirebaseAuth get _auth {
    _ensureFirebaseInitialized();
    return FirebaseAuth.instance;
  }

  FirebaseFirestore get _firestore {
    _ensureFirebaseInitialized();
    return FirebaseFirestore.instance;
  }

  // User stream
  Stream<User?> get userStream {
    if (Firebase.apps.isEmpty) {
      return const Stream<User?>.empty();
    }
    return _auth.authStateChanges();
  }

  // Current user
  User? get currentUser => Firebase.apps.isEmpty ? null : _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'isSubscribed': false,
          'subscriptionExpiry': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isEmailVerified': false,
        }).timeout(_firestoreOpTimeout);
      } catch (e) {
        if (!_isFirestoreUnavailable(e) && e is! TimeoutException) {
          throw _handleFirebaseError(e);
        }
      }

      return userCredential;
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.reload();
      final refreshedUser = _auth.currentUser;
      final isEmailVerified = refreshedUser?.emailVerified ?? false;

      if (!isEmailVerified) {
        await _auth.signOut();
        throw Exception('Please verify your email from the verification link before signing in');
      }

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .timeout(_firestoreOpTimeout);

        if (userDoc.exists && userDoc.data()?['isEmailVerified'] != true) {
          await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'isEmailVerified': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }).timeout(_firestoreOpTimeout);
        }

        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        }).timeout(_firestoreOpTimeout);
      } catch (e) {
        if (!_isFirestoreUnavailable(e) && e is! TimeoutException) {
          throw _handleFirebaseError(e);
        }
      }

      return userCredential;
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle({
    bool allowNewUser = true,
    bool allowExistingUser = true,
  }) async {
    try {
      if (kIsWeb) {
        final credential = await _auth.signInWithPopup(GoogleAuthProvider());
        await _enforceGoogleAccountPolicy(
          credential,
          allowNewUser: allowNewUser,
          allowExistingUser: allowExistingUser,
        );
        await _syncUserDocumentBestEffort(credential);
        return credential;
      }

      if (!_isGoogleSignInPlatformSupported) {
        throw Exception(
          'Google sign-in is not supported on this platform. '
          'Use Android, iOS, macOS, or Web.',
        );
      }

      await _ensureGoogleSignInInitialized();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      await _enforceGoogleAccountPolicy(
        userCredential,
        allowNewUser: allowNewUser,
        allowExistingUser: allowExistingUser,
      );

      await _syncUserDocumentBestEffort(userCredential);

      return userCredential;
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // ==================== PHONE AUTHENTICATION METHODS ====================

  // Verify phone number and send SMS code
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _phoneVerificationId = verificationId;
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: timeout,
    );
  }

  // Sign in with phone number and SMS code
  Future<UserCredential> signInWithPhoneOtp(String smsCode) async {
    if (_phoneVerificationId == null) {
      throw FirebaseAuthException(
        code: 'session-expired',
        message: 'Verification session expired. Please request a new code.',
      );
    }
    
    final credential = PhoneAuthProvider.credential(
      verificationId: _phoneVerificationId!,
      smsCode: smsCode,
    );
    
    final userCredential = await _auth.signInWithCredential(credential);
    _clearPhoneVerificationState();
    return userCredential;
  }

  // Link phone number to existing user account
  Future<UserCredential> linkPhoneNumber(String smsCode) async {
    if (_phoneVerificationId == null) {
      throw FirebaseAuthException(
        code: 'session-expired',
        message: 'Verification session expired. Please request a new code.',
      );
    }
    
    final credential = PhoneAuthProvider.credential(
      verificationId: _phoneVerificationId!,
      smsCode: smsCode,
    );
    
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found to link phone number');
    }
    
    final userCredential = await user.linkWithCredential(credential);
    _clearPhoneVerificationState();
    return userCredential;
  }

  // Update phone number for existing user (requires re-authentication)
  Future<void> updatePhoneNumber(String smsCode) async {
    if (_phoneVerificationId == null) {
      throw FirebaseAuthException(
        code: 'session-expired',
        message: 'Verification session expired. Please request a new code.',
      );
    }
    
    final credential = PhoneAuthProvider.credential(
      verificationId: _phoneVerificationId!,
      smsCode: smsCode,
    );
    
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    
    await user.updatePhoneNumber(credential);
    _clearPhoneVerificationState();
  }

  // Get current phone number (if any)
  String? getCurrentPhoneNumber() {
    return _auth.currentUser?.phoneNumber;
  }

  // Clear phone verification state
  void clearPhoneVerification() {
    _clearPhoneVerificationState();
  }

  void _clearPhoneVerificationState() {
    _phoneVerificationId = null;
  }

  // Get user-friendly error message for phone auth
  String getPhoneAuthErrorMessage(FirebaseAuthException e) {
    final raw = '${e.code} ${e.message ?? ''}'.toLowerCase();

    if (raw.contains('billing_not_enabled') || raw.contains('billing not enabled')) {
      return 'Phone verification is not enabled for this Firebase project yet. Please enable billing/phone auth in Firebase Console.';
    }

    if (raw.contains('recaptcha') || raw.contains('sitekey')) {
      return 'Phone verification is not configured for this project. Please set up Firebase phone auth reCAPTCHA/Play Integrity in the Firebase Console.';
    }

    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format. Please use country code (e.g., +880XXXXXXXXX)';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please use email login or try again tomorrow.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'session-expired':
        return 'Session expired. Please request a new code.';
      case 'provider-already-linked':
        return 'This phone number is already linked to another account.';
      case 'credential-already-in-use':
        return 'This phone number is already associated with an existing account.';
      case 'missing-phone-number':
        return 'Phone number is required.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return e.message ?? 'Phone authentication failed. Please try again.';
    }
  }

  // Send verification code for re-authentication (for sensitive operations)
  Future<void> sendPhoneVerificationForReAuth(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {},
      verificationFailed: (_) {},
      codeSent: (verificationId, resendToken) {
        _phoneVerificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // Re-authenticate with phone before sensitive operations
  Future<UserCredential> reAuthenticateWithPhone(String smsCode) async {
    if (_phoneVerificationId == null) {
      throw FirebaseAuthException(
        code: 'session-expired',
        message: 'Verification session expired. Please request a new code.',
      );
    }
    
    final credential = PhoneAuthProvider.credential(
      verificationId: _phoneVerificationId!,
      smsCode: smsCode,
    );
    
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    
    return await user.reauthenticateWithCredential(credential);
  }

  // ==================== END PHONE AUTHENTICATION METHODS ====================

  // Sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb && _isGoogleSignInPlatformSupported) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      _clearPhoneVerificationState();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<void> markCurrentUserEmailVerifiedInDb() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No active user found');
      }
      await _firestore.collection('users').doc(user.uid).update({
        'isEmailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Resend verification email for current user
  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No active user found. Please sign up again.');
      }
      await user.sendEmailVerification();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Reload user and return latest email verification status
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }
      await user.reload();
      final refreshedUser = _auth.currentUser;
      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_firestoreOpTimeout);
      return doc.data();
    } catch (e) {
      if (_isFirestoreUnavailable(e) || e is TimeoutException) {
        return null;
      }
      throw _handleFirebaseError(e);
    }
  }

  Future<Map<String, dynamic>?> getUserDataByPhoneNumber(String phoneNumber) async {
    try {
      final primaryQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get()
          .timeout(_firestoreOpTimeout);

      if (primaryQuery.docs.isNotEmpty) {
        return primaryQuery.docs.first.data();
      }

      final legacyQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get()
          .timeout(_firestoreOpTimeout);

      if (legacyQuery.docs.isNotEmpty) {
        return legacyQuery.docs.first.data();
      }

      return null;
    } catch (e) {
      if (_isFirestoreUnavailable(e) || e is TimeoutException) {
        return null;
      }
      throw _handleFirebaseError(e);
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  String _handleFirebaseError(dynamic error) {
    if (error is FirebaseException && error.plugin == 'cloud_firestore') {
      switch (error.code) {
        case 'unavailable':
          return 'Firestore server-এ এখন connect করা যাচ্ছে না। একটু পরে আবার চেষ্টা করুন।';
        default:
          return 'ডেটাবেস ত্রুটি (${error.code}): ${error.message ?? 'No details'}';
      }
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'এই ইমেইলটি ইতিমধ্যে ব্যবহার করা হচ্ছে';
        case 'invalid-email':
          return 'ইমেইল ফরম্যাট সঠিক নয়';
        case 'weak-password':
          return 'পাসওয়ার্ড খুব সহজ (কমপক্ষে ৬ অক্ষর)';
        case 'user-not-found':
          return 'ইউজার পাওয়া যায়নি';
        case 'wrong-password':
          return 'পাসওয়ার্ড ভুল';
        case 'user-disabled':
          return 'এই ইউজার ব্লক করা হয়েছে';
        case 'too-many-requests':
          return 'অনেক চেষ্টা করেছেন, কিছুক্ষণ পর চেষ্টা করুন';
        case 'network-request-failed':
          return 'ইন্টারনেট সংযোগ পরীক্ষা করুন';
        case 'popup-blocked':
          return 'Google login popup blocked হয়েছে। Browser popup allow করুন।';
        case 'popup-closed-by-user':
          return 'Google login popup বন্ধ করা হয়েছে';
        case 'unauthorized-domain':
          return 'এই domain Firebase Auth এ authorized নয়';
        case 'operation-not-allowed':
          return 'Firebase Console এ Google sign-in enable করা নেই';
        default:
          return 'একটি ত্রুটি ঘটেছে (${error.code}): ${error.message ?? 'No details'}';
      }
    }
    return 'একটি ত্রুটি ঘটেছে: $error';
  }

  bool _isFirestoreUnavailable(dynamic error) {
    return error is FirebaseException &&
        error.plugin == 'cloud_firestore' &&
        error.code == 'unavailable';
  }

  Future<void> _syncUserDocumentBestEffort(UserCredential userCredential) async {
    try {
      await _ensureUserDocument(userCredential);
    } catch (e) {
      if (!_isFirestoreUnavailable(e)) {
        rethrow;
      }
    }
  }

  Future<void> _enforceGoogleAccountPolicy(
    UserCredential userCredential, {
    required bool allowNewUser,
    required bool allowExistingUser,
  }) async {
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if ((isNewUser && allowNewUser) || (!isNewUser && allowExistingUser)) {
      return;
    }

    final user = userCredential.user;

    if (isNewUser && user != null) {
      await user.delete();
    }

    await _auth.signOut();

    if (isNewUser) {
      throw Exception('No account found with this Google email. Sign up first.');
    }

    throw Exception('An account with this Google email already exists. Please log in.');
  }

  Future<void> _ensureUserDocument(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user == null) {
      return;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email,
        'phoneNumber': user.phoneNumber, // Added phone number support
        'isSubscribed': false,
        'subscriptionExpiry': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isEmailVerified': true,
      });
    }
  }

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??=
        _googleSignIn.initialize().catchError((dynamic error) {
          _googleSignInInitialization = null;
          throw error;
        });
  }

  void _ensureFirebaseInitialized() {
    if (!_isFirebaseAuthPlatformSupported) {
      throw Exception(
        'Firebase Auth is not supported on this platform. '
        'Use Android, iOS, macOS, Windows, or Web.',
      );
    }

    if (Firebase.apps.isEmpty) {
      throw Exception(
        'Firebase is not configured for this platform yet. '
        'Run FlutterFire configure and add platform options.',
      );
    }
  }
}