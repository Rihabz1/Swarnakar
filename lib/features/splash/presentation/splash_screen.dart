import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/utils/connectivity_helper.dart';
import 'package:swarnakar/features/auth/data/firebase_auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loaderController;
  StreamSubscription<List<dynamic>>? _connectivitySubscription;
  bool _isOffline = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _connectivitySubscription =
        ConnectivityHelper.connectivityStream.listen((_) async {
      if (_isOffline && await ConnectivityHelper.isConnected()) {
        _navigateNext(skipDelay: true);
      }
    });
    _navigateNext();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _loaderController.dispose();
    super.dispose();
  }

  Future<void> _navigateNext({bool skipDelay = false}) async {
    if (_isChecking) return;
    _isChecking = true;
    if (!skipDelay) {
      await Future.delayed(const Duration(seconds: 3));
    }
    if (!mounted) return;
    final hasInternet = await ConnectivityHelper.isConnected();
    if (!mounted) return;
    if (!hasInternet) {
      setState(() {
        _isOffline = true;
        _isChecking = false;
      });
      return;
    }
    setState(() {
      _isOffline = false;
    });
    try {
      final restored = await FirebaseAuthService.instance.restoreSession();
      if (!mounted) return;
      if (!restored) {
        context.go('/login');
        return;
      }
      final profile =
          await FirebaseAuthService.instance.getCurrentUserProfile();
      if (!mounted) return;
      if (profile == null) {
        await FirebaseAuthService.instance.clearSession();
        if (!mounted) return;
        context.go('/login');
        return;
      }
      context.go('/dashboard');
    } on NetworkException {
      if (!mounted) return;
      setState(() {
        _isOffline = true;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: AppColors.background,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                if (_isOffline)
                  _buildOfflineContent()
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 650),
                          child: _buildLogo(),
                        ),
                        const SizedBox(height: 28),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 180),
                          child: Text(
                            AppStrings.appName,
                            style: AppTextStyles.hindSiliguri(
                              fontSize: 46,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 280),
                          child: Text(
                            'স্বর্ণের বাজারের নির্ভরযোগ্য সঙ্গী',
                            style: AppTextStyles.hindSiliguri(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 54),
                        _buildPremiumLoader(),
                      ],
                    ),
                  ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      AppStrings.appVersion,
                      style: AppTextStyles.hindSiliguri(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              color: AppColors.gold,
              size: 58,
            ),
            const SizedBox(height: 22),
            Text(
              ConnectivityHelper.offlineTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.hindSiliguri(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ConnectivityHelper.offlineRequiredMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.hindSiliguri(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed:
                  _isChecking ? null : () => _navigateNext(skipDelay: true),
              child: Text(
                'আবার চেষ্টা করুন',
                style: AppTextStyles.hindSiliguri(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/swarnakar-nobg.png',
      width: 132,
      height: 132,
      fit: BoxFit.contain,
    );
  }

  Widget _buildPremiumLoader() {
    return SizedBox(
      width: 42,
      height: 42,
      child: AnimatedBuilder(
        animation: _loaderController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _loaderController.value * 2 * math.pi,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const SweepGradient(
                  colors: [
                    AppColors.goldDark,
                    AppColors.vividGold,
                    AppColors.goldLight,
                    AppColors.goldDark,
                  ],
                  stops: [0.0, 0.42, 0.78, 1.0],
                ).createShader(rect);
              },
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
