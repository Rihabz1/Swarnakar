import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/shared/models/user_model.dart';

// Global state providers
final isSubscribedProvider = StateProvider<bool>((ref) => false);

final currentUserProvider = StateProvider<UserModel?>((ref) => UserModel(
  uid: '',
  name: '',
  email: '',
  isSubscribed: false,
));

// Auth state
final isLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);
