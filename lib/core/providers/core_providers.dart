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

// Auth state
final isLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);
