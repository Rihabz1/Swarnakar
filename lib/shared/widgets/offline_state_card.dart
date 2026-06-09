import 'package:flutter/material.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';

class OfflineStateCard extends StatelessWidget {
  const OfflineStateCard({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 390),
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.24),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.11),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.32),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.wifi_off_outlined,
                  color: AppColors.gold,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'ইন্টারনেট সংযোগ নেই',
                textAlign: TextAlign.center,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  height: 1.22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'সর্বশেষ বাজার দর দেখতে ইন্টারনেট সংযোগ চালু করুন।',
                textAlign: TextAlign.center,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    'আবার চেষ্টা করুন',
                    style: AppTextStyles.hindSiliguri(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
