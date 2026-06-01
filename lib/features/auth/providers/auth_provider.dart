import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/otp_service.dart';
import '../../../shared/models/user_model.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());
final otpServiceProvider = Provider((ref) => OtpService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseServiceProvider).userStream;
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(firebaseServiceProvider),
    ref.watch(otpServiceProvider),
  );
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final String? phoneVerificationId;
  final String? verifyingPhoneNumber;
  
  AuthState({
    this.user, 
    this.isLoading = false, 
    this.error,
    this.phoneVerificationId,
    this.verifyingPhoneNumber,
  });
  
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    String? phoneVerificationId,
    String? verifyingPhoneNumber,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      phoneVerificationId: phoneVerificationId ?? this.phoneVerificationId,
      verifyingPhoneNumber: verifyingPhoneNumber ?? this.verifyingPhoneNumber,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseService _firebaseService;
  final OtpService _otpService;
  
  AuthNotifier(this._firebaseService, this._otpService) : super(AuthState());

  String _formatError(Object error) {
    final text = error.toString();
    const prefix = 'Exception: ';
    if (text.startsWith(prefix)) {
      return text.substring(prefix.length);
    }
    return text;
  }
  
  // ==================== EMAIL AUTH METHODS ====================
  
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userCredential = await _firebaseService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: null,
        isSubscribed: false,
        subscriptionExpiry: null,
      );
      
      state = state.copyWith(user: userModel, isLoading: false);
      return userModel;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return null;
    }
  }
  
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userCredential = await _firebaseService.signInWithEmail(
        email: email,
        password: password,
      );
      
      final userData = await _firebaseService.getUserData(userCredential.user!.uid);
      
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        name: userData?['name'] ?? '',
        email: userCredential.user!.email!,
        phoneNumber: userData?['phoneNumber'],
        isSubscribed: userData?['isSubscribed'] ?? false,
        subscriptionExpiry: userData?['subscriptionExpiry']?.toDate(),
      );
      
      state = state.copyWith(user: userModel, isLoading: false);
      return userModel;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return null;
    }
  }
  
  Future<UserModel?> signInWithGoogle({
    bool allowNewUser = true,
    bool allowExistingUser = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userCredential = await _firebaseService.signInWithGoogle(
        allowNewUser: allowNewUser,
        allowExistingUser: allowExistingUser,
      );
      final userData = await _firebaseService.getUserData(userCredential.user!.uid);
      
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? '',
        email: userCredential.user!.email!,
        phoneNumber: userData?['phoneNumber'],
        isSubscribed: userData?['isSubscribed'] ?? false,
        subscriptionExpiry: userData?['subscriptionExpiry']?.toDate(),
      );
      
      state = state.copyWith(user: userModel, isLoading: false);
      return userModel;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return null;
    }
  }

  Future<void> sendPhoneOtp(
    String phoneNumber,
    String recaptchaToken, {
    required bool isSignup,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final existingUser = await _firebaseService.getUserDataByPhoneNumber(phoneNumber);

    if (isSignup && existingUser != null) {
      state = state.copyWith(
        isLoading: false,
        error: 'এই ফোন নম্বরটি ইতিমধ্যেই ব্যবহার করা হয়েছে। অনুগ্রহ করে লগইন করুন।',
      );
      return;
    }

    if (!isSignup && existingUser == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'এই নম্বরের জন্য কোনো অ্যাকাউন্ট পাওয়া যায়নি। অনুগ্রহ করে সাইন আপ করুন।',
      );
      return;
    }

    await sendPhoneVerificationCode(phoneNumber);
  }

  Future<void> signInWithPhone(String phoneNumber, String otpCode) async {
    await verifyPhoneOtp(otpCode);
  }

  Future<void> signUpWithPhone(
    String phoneNumber,
    String otpCode,
    String? name,
  ) async {
    await verifyPhoneOtp(otpCode);

    if (name != null && name.trim().isNotEmpty && state.user != null) {
      await _firebaseService.updateUserData({
        'name': name.trim(),
        'updatedAt': DateTime.now(),
      });

      state = state.copyWith(
        user: state.user!.copyWith(name: name.trim()),
      );
    }
  }
  
  // ==================== PHONE AUTH METHODS ====================
  
  Future<void> sendPhoneVerificationCode(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    String? failureMessage;

    await _firebaseService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onVerificationCompleted: (credential) async {
        try {
          final userCredential = await _firebaseService.signInWithPhoneOtp(
            credential.smsCode ?? ''
          );
          await _handlePhoneSignIn(userCredential);
        } catch (e) {
          state = state.copyWith(isLoading: false, error: _formatError(e));
        }
      },
      onVerificationFailed: (e) {
        failureMessage = _firebaseService.getPhoneAuthErrorMessage(e);
        state = state.copyWith(
          isLoading: false,
          error: failureMessage,
        );
      },
      onCodeSent: (verificationId, resendToken) {
        state = state.copyWith(
          isLoading: false,
          phoneVerificationId: verificationId,
          verifyingPhoneNumber: phoneNumber,
        );
      },
      onCodeAutoRetrievalTimeout: (verificationId) {
        state = state.copyWith(phoneVerificationId: verificationId);
      },
    );

    // After verifyPhoneNumber returns, one of the callbacks should have fired.
    // If we don't have a verification id, consider it a failure and throw so
    // callers (UI) can react via try/catch.
    if (state.phoneVerificationId == null) {
      state = state.copyWith(isLoading: false);
      throw Exception(failureMessage ?? 'Failed to send verification code.');
    }
  }
  
  Future<void> verifyPhoneOtp(String smsCode) async {
    if (state.phoneVerificationId == null) {
      state = state.copyWith(error: 'Session expired. Request a new code.');
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userCredential = await _firebaseService.signInWithPhoneOtp(smsCode);
      await _handlePhoneSignIn(userCredential);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }
  
  Future<void> _handlePhoneSignIn(UserCredential userCredential) async {
    final user = userCredential.user!;
    
    final userData = await _firebaseService.getUserData(user.uid);
    
    UserModel userModel;
    if (userData == null) {
      // New user - create profile
      userModel = UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber,
        isSubscribed: false,
        subscriptionExpiry: null,
      );
      await _firebaseService.updateUserData({
        'uid': user.uid,
        'name': userModel.name,
        'email': userModel.email,
        'phoneNumber': userModel.phoneNumber,
        'isSubscribed': false,
        'createdAt': DateTime.now(),
      });
    } else {
      // Existing user
      userModel = UserModel(
        uid: user.uid,
        name: userData['name'] ?? '',
        email: user.email ?? userData['email'] ?? '',
        phoneNumber: user.phoneNumber ?? userData['phoneNumber'],
        isSubscribed: userData['isSubscribed'] ?? false,
        subscriptionExpiry: userData['subscriptionExpiry']?.toDate(),
      );
    }
    
    _firebaseService.clearPhoneVerification();
    
    state = state.copyWith(
      user: userModel,
      isLoading: false,
      phoneVerificationId: null,
      verifyingPhoneNumber: null,
    );
  }
  
  void clearPhoneVerification() {
    _firebaseService.clearPhoneVerification();
    state = state.copyWith(
      phoneVerificationId: null,
      verifyingPhoneNumber: null,
      error: null,
    );
  }
  
  // ==================== COMMON METHODS ====================
  
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _firebaseService.signOut();
    _firebaseService.clearPhoneVerification();
    state = AuthState();
  }
  
  Future<void> updateSubscriptionStatus(bool isSubscribed) async {
    await _firebaseService.updateUserData({
      'isSubscribed': isSubscribed,
      'subscriptionExpiry': isSubscribed 
          ? DateTime.now().add(const Duration(days: 30))
          : null,
    });
    
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(
          isSubscribed: isSubscribed,
          subscriptionExpiry: isSubscribed 
              ? DateTime.now().add(const Duration(days: 30))
              : null,
        ),
      );
    }
  }

  // ==================== PASSWORD RESET METHODS ====================
  
  Future<void> sendResetOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _otpService.sendOtp(email: email, purpose: 'reset');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }

  Future<String> verifyResetOtp({required String email, required String code}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resetToken = await _otpService.verifyResetOtp(email: email, code: code);
      state = state.copyWith(isLoading: false);
      return resetToken;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }

  Future<void> resetPassword({required String resetToken, required String newPassword}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _otpService.resetPassword(resetToken: resetToken, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }
}