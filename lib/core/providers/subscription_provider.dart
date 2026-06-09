import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/providers/connectivity_provider.dart';

/// Provides the current Firebase Auth user state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// A global provider to track if the user is subscribed based on their Firestore document.
final isSubscribedProvider = StreamProvider<bool>((ref) async* {
  await requireInternet(ref);
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    yield false;
    return;
  }

  yield* FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    return snapshot.data()?['isSubscribed'] == true;
  });
});
