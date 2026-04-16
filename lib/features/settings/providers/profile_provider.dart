import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swarnakar/core/services/profile_service.dart';
import 'package:swarnakar/features/auth/providers/auth_provider.dart';

final profileServiceProvider = Provider((ref) => ProfileService());

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.read(profileServiceProvider),
    ref,
  );
});

class ProfileState {
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final String? error;
  final bool isEditing;

  ProfileState({
    this.profile,
    this.stats,
    this.isLoading = false,
    this.error,
    this.isEditing = false,
  });

  ProfileState copyWith({
    Map<String, dynamic>? profile,
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
    bool? isEditing,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  final Ref _ref;

  ProfileNotifier(this._profileService, this._ref) : super(ProfileState());

  Future<String?> _getToken() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    return await currentUser.getIdToken();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authState = _ref.read(authProvider);
      if (authState.user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }

      final token = await _getToken();
      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get authentication token',
        );
        return;
      }

      final profile = await _profileService.getProfile(token);
      final stats = await _profileService.getUserStats(token);

      state = state.copyWith(
        profile: profile,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _getToken();
      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get authentication token',
        );
        return;
      }

      final updatedProfile = await _profileService.updateProfile(token, data);

      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        isEditing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _getToken();
      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get authentication token',
        );
        return;
      }

      await _profileService.changePassword(
        token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _getToken();
      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get authentication token',
        );
        return;
      }

      await _profileService.deleteAccount(token);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void toggleEdit() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
