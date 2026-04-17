import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'firebase_service.dart';

class EmailLinkAuthService {
  EmailLinkAuthService({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  final FirebaseService _firebaseService;
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;
  bool _isHandling = false;

  Future<void> start({
    VoidCallback? onSignedIn,
    void Function(String message)? onError,
  }) async {
    if (kIsWeb) {
      await _handleLink(
        Uri.base,
        onSignedIn: onSignedIn,
        onError: onError,
      );
      return;
    }

    if (_subscription != null) {
      return;
    }

    final initialLink = await _appLinks.getInitialLink();
    await _handleLink(
      initialLink,
      onSignedIn: onSignedIn,
      onError: onError,
    );

    _subscription = _appLinks.uriLinkStream.listen((uri) async {
      await _handleLink(
        uri,
        onSignedIn: onSignedIn,
        onError: onError,
      );
    }, onError: (error) {
      onError?.call(error.toString());
    });
  }

  Future<void> _handleLink(
    Uri? uri, {
    VoidCallback? onSignedIn,
    void Function(String message)? onError,
  }) async {
    if (uri == null || _isHandling) {
      return;
    }

    final link = uri.toString();
    _isHandling = true;
    try {
      final result = await _firebaseService.completeSignInWithEmailLink(link);
      if (result != null) {
        onSignedIn?.call();
      }
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      _isHandling = false;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
