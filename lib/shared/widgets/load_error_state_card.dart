import 'package:flutter/material.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';

class LoadErrorStateCard extends StatelessWidget {
  const LoadErrorStateCard({
    super.key,
    required this.onRetry,
    this.title = 'তথ্য লোড করা যায়নি',
    this.message = 'কিছুক্ষণ পর আবার চেষ্টা করুন।',
  });

  final VoidCallback onRetry;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 42),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
