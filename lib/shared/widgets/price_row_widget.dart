import 'package:flutter/material.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/utils/currency_formatter.dart';

class PriceRowWidget extends StatelessWidget {
  final String label;
  final double price;
  final bool isBlurred;

  const PriceRowWidget({
    super.key,
    required this.label,
    required this.price,
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.hindSiliguri(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              if (isBlurred)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.vividGold.withValues(alpha: 0.82),
                  ),
                ),
              Text(
                isBlurred ? '••••••' : CurrencyFormatter.formatBDT(price),
                style: AppTextStyles.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isBlurred ? AppColors.mutedChampagne : AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
