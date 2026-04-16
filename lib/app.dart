import 'package:flutter/material.dart';
import 'package:swarnakar/core/router/app_router.dart';
import 'package:swarnakar/core/theme/app_theme.dart';

class SwarnakarApp extends StatelessWidget {
  const SwarnakarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'স্বর্ণকার',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      localizationsDelegates: const [
        // Add localization delegates if needed in future
      ],
      supportedLocales: const [
        Locale('bn', 'BD'),
        Locale('en', 'US'),
      ],
    );
  }
}
