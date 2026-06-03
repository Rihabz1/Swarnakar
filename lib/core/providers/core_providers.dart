import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/shared/models/user_model.dart';
import 'package:swarnakar/features/auth/data/firebase_auth_service.dart';

// Global state providers
final isSubscribedProvider = StateProvider<bool>((ref) => false);

final currentUserProvider = StateProvider<UserModel?>((ref) => UserModel(
  uid: '',
  name: '',
  email: '',
  phone: '',
  shopName: '',
  address: '',
  isSubscribed: false,
  plan: '',
  subExpires: null,
));

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  return FirebaseAuthService.instance.getCurrentUserProfile();
});

final activeSubscriptionProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final fallbackSubscribed = ref.watch(isSubscribedProvider);
  final profile = profileAsync.asData?.value;
  
  if (fallbackSubscribed) return true;
  if (profile == null || !profile.isSubscribed) return false;
  
  final expiresAt = profile.subExpires;
  if (expiresAt == null) return true;
  return expiresAt.isAfter(DateTime.now());
});

// Auth state
final isLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);
