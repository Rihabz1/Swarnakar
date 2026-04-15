import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'package:swarnakar/core/providers/core_providers.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.gold,
            size: 18,
          ),
        ),
        title: Text(
          AppStrings.premium,
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Column(
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
                textAlign: TextAlign.center,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 9.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              _buildPlanCards(),
              const SizedBox(height: 16),
              Text(
                AppStrings.whatYouGet.toUpperCase(),
                style: AppTextStyles.hindSiliguri(
                  fontSize: 9,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildBenefitsList(),
              const SizedBox(height: 16),
              GoldenButton(
                text: AppStrings.subscribeNow,
                onPressed: () {
                  ref.read(isSubscribedProvider.notifier).state = true;
                  context.go('/dashboard');
                },
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.gold,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.go('/dashboard'),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          AppStrings.continueAsGuest,
                          style: AppTextStyles.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.cancellableAnytime,
                textAlign: TextAlign.center,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 8.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCards() {
    return Row(
      children: [
        Expanded(
          child: _buildPlanCard(
            AppStrings.monthly,
            AppStrings.monthlyPrice,
            AppStrings.perMonth,
            false,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              _buildPlanCard(
                AppStrings.yearly,
                AppStrings.yearlyPrice,
                AppStrings.perYear,
                true,
              ),
              Positioned(
                top: -8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppStrings.best,
                      style: AppTextStyles.hindSiliguri(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    String title,
    String price,
    String period,
    bool isFeatured,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isFeatured ? AppColors.gold.withOpacity(0.06) : AppColors.surface,
        border: Border.all(
          color: isFeatured ? AppColors.gold : AppColors.gold.withOpacity(0.15),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Column(
        children: [
          Text(
            title,
            style: AppTextStyles.hindSiliguri(
              fontSize: 9,
              color: isFeatured ? AppColors.gold.withOpacity(0.7) : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: AppTextStyles.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          Text(
            period,
            style: AppTextStyles.hindSiliguri(
              fontSize: 8,
              color: isFeatured ? AppColors.gold.withOpacity(0.4) : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      AppStrings.livePrices,
      AppStrings.priceNotif,
      AppStrings.adFree,
      AppStrings.fullFeatures,
    ];

    return Column(
      children: benefits.map((benefit) => _buildBenefitRow(benefit)).toList(),
    );
  }

  Widget _buildBenefitRow(String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.12),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              benefit,
              style: AppTextStyles.hindSiliguri(
                fontSize: 9.5,
                color: AppColors.gold.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
