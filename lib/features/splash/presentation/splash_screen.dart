import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _loaderController;

  @override
  void initState() {
    super.initState();
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _navigateToLogin();
  }

  @override
  void dispose() {
    _loaderController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
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

  Widget _buildLogo() {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.9),
          width: 2,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.surfaceRaised,
            AppColors.surface,
          ],
        ),
      ),
      child: const Icon(
        Icons.workspace_premium_outlined,
        size: 52,
        color: AppColors.gold,
      ),
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
