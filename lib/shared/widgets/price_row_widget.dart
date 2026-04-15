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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.04),
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
              fontSize: 12,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          Text(
            CurrencyFormatter.formatBDT(price),
            style: AppTextStyles.hindSiliguri(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isBlurred ? AppColors.textMuted : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
