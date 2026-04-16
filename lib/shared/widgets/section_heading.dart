import 'package:flutter/material.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isCentered;

  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle = AppStrings.lastUpdate,
    this.isCentered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: AppTextStyles.hindSiliguri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle!,
                textAlign: isCentered ? TextAlign.center : TextAlign.start,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
