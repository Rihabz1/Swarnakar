import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swarnakar/app.dart';
import 'package:swarnakar/core/router/app_router.dart';
import 'package:swarnakar/core/services/email_link_auth_service.dart';
import 'package:swarnakar/core/services/firebase_service.dart';
import 'package:swarnakar/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await initializeDateFormatting('bn_BD');

  runApp(
    const ProviderScope(
      child: SwarnakarApp(),
    ),
  );

  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    final emailLinkAuthService = EmailLinkAuthService(
      firebaseService: FirebaseService(),
    );
    unawaited(
      emailLinkAuthService.start(
        onSignedIn: () => appRouter.go('/dashboard'),
        onError: (message) => debugPrint('Email link sign-in error: $message'),
      ),
    );
  }
}