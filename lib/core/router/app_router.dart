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
import 'package:swarnakar/features/reports/presentation/reports_screen.dart';
import 'package:swarnakar/features/settings/presentation/settings_screen.dart';
import 'package:swarnakar/features/settings/presentation/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/finishSignIn',
      name: 'finish-signin',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final flow = state.uri.queryParameters['flow'] ?? 'signup';
        return OtpScreen(email: email, flow: flow);
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final token = state.uri.queryParameters['token'] ?? '';
        return ResetPasswordScreen(email: email, resetToken: token);
      },
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/gold-price',
      name: 'gold-price',
      builder: (context, state) => const GoldPriceScreen(),
    ),
    GoRoute(
      path: '/silver-price',
      name: 'silver-price',
      builder: (context, state) => const SilverPriceScreen(),
    ),
    GoRoute(
      path: '/calculator',
      name: 'calculator',
      builder: (context, state) => const CalculatorScreen(),
    ),
    GoRoute(
      path: '/zakat',
      name: 'zakat',
      builder: (context, state) => const ZakatScreen(),
    ),
    GoRoute(
      path: '/paywall',
      name: 'paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
