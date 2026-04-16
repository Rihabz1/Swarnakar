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
  
  AuthState({this.user, this.isLoading = false, this.error});
  
  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
  
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _firebaseService.signOut();
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

  Future<void> sendSignupOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _otpService.sendOtp(email: email, purpose: 'signup');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }

  Future<void> verifySignupOtp({required String email, required String code}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _otpService.verifyOtp(email: email, code: code, purpose: 'signup');
      await _firebaseService.markCurrentUserEmailVerifiedInDb();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }
}
