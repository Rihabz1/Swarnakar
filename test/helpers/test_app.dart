import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:swarnakar/core/theme/app_theme.dart';

Future<void> pumpTestRoute(
  WidgetTester tester, {
  required String path,
  required Widget child,
  List<Override> overrides = const [],
  ProviderContainer? container,
}) async {
  await initializeDateFormatting('bn_BD');
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(800, 1000);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final routes = <RouteBase>[
    GoRoute(path: path, builder: (_, __) => child),
    GoRoute(
        path: '/dashboard',
        builder: (_, __) => const Scaffold(body: Text('TEST_DASHBOARD'))),
    GoRoute(
        path: '/signup',
        builder: (_, __) => const Scaffold(body: Text('TEST_SIGNUP'))),
    GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const Scaffold(body: Text('TEST_FORGOT'))),
  ];
  if (path != '/reset-password') {
    routes.add(GoRoute(
      path: '/reset-password',
      builder: (_, __) => const Scaffold(body: Text('TEST_RESET_PASSWORD')),
    ));
  }
  final router = GoRouter(initialLocation: path, routes: routes);
  addTearDown(router.dispose);
  final app =
      MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router);
  await tester.pumpWidget(container == null
      ? ProviderScope(overrides: overrides, child: app)
      : UncontrolledProviderScope(container: container, child: app));
  await tester.pump();
  // Complete delayed entrance animations so tests finish without timers.
  await tester.pump(const Duration(seconds: 2));
}
