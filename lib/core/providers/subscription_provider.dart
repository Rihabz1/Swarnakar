import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the current Firebase Auth user state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// A global provider to track if the user is subscribed based on their Firestore document.
final isSubscribedProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value(false);
  }

  return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().map((snapshot) {
    return snapshot.data()?['isSubscribed'] == true;
  });
});