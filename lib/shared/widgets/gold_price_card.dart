import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

class GoldPriceCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final bool isLocked;
  final VoidCallback? onLockedTap;

  const GoldPriceCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(0),
    this.isLocked = false,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: children,
          ),
          if (isLocked)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onLockedTap,
                  borderRadius: BorderRadius.circular(16),
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
                              child: Text(
                                AppStrings.subscribeToView,
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
