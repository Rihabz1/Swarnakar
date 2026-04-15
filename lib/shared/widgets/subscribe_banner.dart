import 'package:flutter/material.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';

class SubscribeBanner extends StatelessWidget {
  final VoidCallback onSubscribe;

  const SubscribeBanner({
    super.key,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: AppColors.gold,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.upgradePremium,
            style: AppTextStyles.hindSiliguri(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.unlockFeatures,
            style: AppTextStyles.hindSiliguri(
              fontSize: 9.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          GoldenButton(
            text: AppStrings.subscribeNow,
            onPressed: onSubscribe,
          ),
        ],
      ),
    );
  }
}
