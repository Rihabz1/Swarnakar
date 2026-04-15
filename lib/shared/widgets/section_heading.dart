import 'package:flutter/material.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle = AppStrings.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.hindSiliguri(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle!,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
