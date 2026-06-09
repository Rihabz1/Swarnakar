import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:swarnakar/features/splash/presentation/splash_screen.dart';
import 'package:swarnakar/features/auth/presentation/login_screen.dart';
import 'package:swarnakar/features/auth/presentation/signup_screen.dart';
import 'package:swarnakar/features/auth/presentation/otp_screen.dart';
import 'package:swarnakar/features/auth/presentation/forgot_password_screen.dart';
import 'package:swarnakar/features/auth/presentation/reset_password_screen.dart';
import 'package:swarnakar/features/dashboard/presentation/dashboard_screen.dart';
import 'package:swarnakar/features/gold_price/presentation/gold_price_screen.dart';
import 'package:swarnakar/features/silver_price/presentation/silver_price_screen.dart';
import 'package:swarnakar/features/calculator/presentation/calculator_screen.dart';
import 'package:swarnakar/features/zakat/presentation/zakat_screen.dart';
import 'package:swarnakar/features/subscription/presentation/paywall_screen.dart';
import 'package:swarnakar/features/converter/presentation/converter_screen.dart';
import 'package:swarnakar/features/price_history/presentation/price_history_screen.dart';
import 'package:swarnakar/features/settings/presentation/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      pageBuilder: (context, state) => _swipePage(
        state,
        const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _swipePage(
        state,
        const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      pageBuilder: (context, state) => _swipePage(
        state,
        const SignupScreen(),
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      pageBuilder: (context, state) => _swipePage(
        state,
        const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      pageBuilder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ??
            state.uri.queryParameters['email'] ??
            '';
        final flow = state.uri.queryParameters['flow'] ?? 'signup';
        return _swipePage(
          state,
          OtpScreen(phone: phone, flow: flow),
        );
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      pageBuilder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ??
            state.uri.queryParameters['email'] ??
            '';
        final otp = state.uri.queryParameters['otp'] ?? '';
        return _swipePage(
          state,
          ResetPasswordScreen(phone: phone, otp: otp),
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      pageBuilder: (context, state) => _swipePage(
        state,
        const DashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/gold-price',
      name: 'gold-price',
      pageBuilder: (context, state) => _mainPage(
        state,
        const GoldPriceScreen(),
      ),
    ),
    GoRoute(
      path: '/silver-price',
      name: 'silver-price',
      pageBuilder: (context, state) => _mainPage(
        state,
        const SilverPriceScreen(),
      ),
    ),
    GoRoute(
      path: '/calculator',
      name: 'calculator',
      pageBuilder: (context, state) => _mainPage(
        state,
        const CalculatorScreen(),
      ),
    ),
    GoRoute(
      path: '/zakat',
      name: 'zakat',
      pageBuilder: (context, state) => _mainPage(
        state,
        const ZakatScreen(),
      ),
    ),
    GoRoute(
      path: '/paywall',
      name: 'paywall',
      pageBuilder: (context, state) => _swipePage(
        state,
        const PaywallScreen(),
      ),
    ),
    GoRoute(
      path: '/converter',
      name: 'converter',
      pageBuilder: (context, state) => _mainPage(
        state,
        const ConverterScreen(),
      ),
    ),
    GoRoute(
      path: '/price-history',
      name: 'price-history',
      pageBuilder: (context, state) => _mainPage(
        state,
        const PriceHistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => _mainPage(
        state,
        const SettingsScreen(),
      ),
    ),
  ],
);

CupertinoPage<void> _swipePage(GoRouterState state, Widget child) {
  return CupertinoPage<void>(
    key: state.pageKey,
    child: child,
  );
}

CupertinoPage<void> _mainPage(GoRouterState state, Widget child) {
  return _swipePage(
    state,
    _MainBackToDashboardScope(child: child),
  );
}

class _MainBackToDashboardScope extends StatefulWidget {
  const _MainBackToDashboardScope({required this.child});

  final Widget child;

  @override
  State<_MainBackToDashboardScope> createState() =>
      _MainBackToDashboardScopeState();
}

class _MainBackToDashboardScopeState extends State<_MainBackToDashboardScope> {
  static const double _edgeWidth = 18;
  static const double _swipeThreshold = 56;

  double _dragDistance = 0;
  bool _didNavigate = false;

  void _goDashboard() {
    if (_didNavigate) {
      return;
    }
    _didNavigate = true;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final enableAndroidEdgeSwipe =
        defaultTargetPlatform == TargetPlatform.android;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goDashboard();
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (enableAndroidEdgeSwipe) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _edgeWidth,
              child: _buildEdgeSwipeDetector(swipeFromLeft: true),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: _edgeWidth,
              child: _buildEdgeSwipeDetector(swipeFromLeft: false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEdgeSwipeDetector({required bool swipeFromLeft}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) {
        _dragDistance = 0;
        _didNavigate = false;
      },
      onHorizontalDragUpdate: (details) {
        _dragDistance += details.primaryDelta ?? 0;
        final passedThreshold = swipeFromLeft
            ? _dragDistance > _swipeThreshold
            : _dragDistance < -_swipeThreshold;

        if (passedThreshold) {
          _goDashboard();
        }
      },
    );
  }
}
