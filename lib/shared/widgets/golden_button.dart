import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';

class GoldenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final bool isFullWidth;

  const GoldenButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidget = SizedBox(
      width: width ?? (isFullWidth ? double.infinity : 120),
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.goldLight,
              AppColors.vividGold,
              AppColors.goldDark,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.vividGold.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: isLoading
                  ? const _MetallicGoldLoader()
                  : Text(
                      text,
                      style: AppTextStyles.buttonText,
                    ),
            ),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return buttonWidget;
    }

    return SizedBox(
      width: width ?? 120,
      height: height,
      child: buttonWidget,
    );
  }
}

class _MetallicGoldLoader extends StatefulWidget {
  const _MetallicGoldLoader();

  @override
  State<_MetallicGoldLoader> createState() => _MetallicGoldLoaderState();
}

class _MetallicGoldLoaderState extends State<_MetallicGoldLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const SweepGradient(
                  colors: [
                    AppColors.goldDark,
                    AppColors.vividGold,
                    AppColors.goldLight,
                    AppColors.goldDark,
                  ],
                  stops: [0.0, 0.45, 0.75, 1.0],
                ).createShader(rect);
              },
              child: const CircularProgressIndicator(
                strokeWidth: 2.3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
