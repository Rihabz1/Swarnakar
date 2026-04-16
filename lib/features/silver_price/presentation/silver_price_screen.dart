import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/shared/widgets/section_heading.dart';
import 'package:swarnakar/shared/widgets/gold_price_card.dart';
import 'package:swarnakar/shared/widgets/price_row_widget.dart';
import 'package:swarnakar/shared/widgets/subscribe_banner.dart';
import 'package:swarnakar/core/providers/core_providers.dart';
import 'package:swarnakar/features/silver_price/providers/silver_price_provider.dart';
import 'package:intl/intl.dart';

class SilverPriceScreen extends ConsumerWidget {
  const SilverPriceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(isSubscribedProvider);
    final pricesBySection = ref.watch(silverPricesBySection);
    final exactUpdateTime = DateFormat('dd MMMM yyyy, hh:mm a', 'bn_BD').format(DateTime.now());
    final subtitleText = 'সর্বশেষ আপডেট: $exactUpdateTime';

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
          AppStrings.silverMarket,
          style: AppTextStyles.hindSiliguri(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              children: [
                _buildTabChip(AppStrings.gold, false, context),
                const SizedBox(width: 8),
                _buildTabChip(AppStrings.silver, true, context),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundSecondary,
              AppColors.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...pricesBySection.entries.map((entry) {
                return Column(
                  children: [
                    SectionHeading(
                      title: entry.key,
                      subtitle: subtitleText,
                      isCentered: true,
                    ),
                    GoldPriceCard(
                      isLocked: !isSubscribed,
                      onLockedTap: () => context.go('/paywall'),
                      children: entry.value.map((price) {
                        return PriceRowWidget(
                          label: price.label,
                          price: price.price,
                          isBlurred: !isSubscribed,
                        );
                      }).toList(),
                    ),
                  ],
                );
              }),
              if (!isSubscribed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: SubscribeBanner(
                    onSubscribe: () => context.go('/paywall'),
                  ),
                ),
              if (isSubscribed)
                const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/silver-price'),
        onTap: (index) {},
      ),
    );
  }

  Widget _buildTabChip(String label, bool isActive, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          context.go('/gold-price');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold.withValues(alpha: 0.14) : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.textMuted.withValues(alpha: 0.45),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: AppTextStyles.hindSiliguri(
            fontSize: 12,
            color: isActive ? AppColors.gold : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
