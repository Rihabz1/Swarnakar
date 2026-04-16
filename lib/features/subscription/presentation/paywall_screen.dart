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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.gold,
            size: 18,
          ),
        ),
        title: Text(
          AppStrings.premium,
          style: AppTextStyles.hindSiliguri(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              color: AppColors.gold,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.upgradePremium,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.hindSiliguri(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.unlockFeatures,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.hindSiliguri(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPlanCards(),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.whatYouGet.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.hindSiliguri(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.75),
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
      ),
    );
  }

  Widget _buildPlanCards() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 132,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  top: 16,
                  child: _buildPlanCard(
                    AppStrings.monthly,
                    AppStrings.monthlyPrice,
                    AppStrings.perMonth,
                    false,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 132,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  top: 16,
                  child: _buildPlanCard(
                    AppStrings.yearly,
                    AppStrings.yearlyPrice,
                    AppStrings.perYear,
                    true,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        AppStrings.best,
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
        color: isFeatured ? AppColors.gold.withValues(alpha: 0.06) : AppColors.surface,
        border: Border.all(
          color: isFeatured ? AppColors.gold : AppColors.gold.withValues(alpha: 0.24),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.hindSiliguri(
              fontSize: 10,
              color: isFeatured ? AppColors.gold.withValues(alpha: 0.75) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: AppTextStyles.hindSiliguri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          Text(
            period,
            style: AppTextStyles.hindSiliguri(
              fontSize: 9,
              color: isFeatured ? AppColors.gold.withValues(alpha: 0.5) : AppColors.textMuted,
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
              color: AppColors.gold.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.35),
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
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
