import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

class BlurPriceOverlay extends StatelessWidget {
  final Widget child;
  final bool isSubscribed;

  const BlurPriceOverlay({
    super.key,
    required this.child,
    required this.isSubscribed,
  });

  @override
  Widget build(BuildContext context) {
    if (isSubscribed) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.42,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          color: AppColors.background.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            color: AppColors.gold,
                            size: 13,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.subscribeToView,
                            style: AppTextStyles.hindSiliguri(
                              fontSize: 8,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
