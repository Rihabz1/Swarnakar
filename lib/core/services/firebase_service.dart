import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'isSubscribed': false,
        'subscriptionExpiry': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isEmailVerified': false,
      });

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

      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      final isEmailVerified = userDoc.data()?['isEmailVerified'] == true;

      if (!isEmailVerified) {
        await _auth.signOut();
        throw Exception('Please verify your email with OTP before signing in');
      }

      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

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

  // Sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb && _isGoogleSignInPlatformSupported) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
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
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      if (_isFirestoreUnavailable(e)) {
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
        'isSubscribed': false,
        'subscriptionExpiry': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isEmailVerified': true,
      });
    }
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
