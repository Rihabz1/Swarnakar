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
import 'package:swarnakar/shared/widgets/blur_price_overlay.dart';
import 'package:swarnakar/shared/widgets/subscribe_banner.dart';
import 'package:swarnakar/core/providers/core_providers.dart';
import 'package:swarnakar/features/gold_price/providers/gold_price_provider.dart';

class GoldPriceScreen extends ConsumerWidget {
  const GoldPriceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(isSubscribedProvider);
    final pricesBySection = ref.watch(goldPricesBySection);

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
          AppStrings.goldMarket,
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              children: [
                _buildTabChip(AppStrings.gold, true, context),
                const SizedBox(width: 8),
                _buildTabChip(AppStrings.silver, false, context),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...pricesBySection.entries.map((entry) {
              return Column(
                children: [
                  SectionHeading(title: entry.key),
                  GoldPriceCard(
                    children: entry.value.map((price) {
                      return BlurPriceOverlay(
                        isSubscribed: isSubscribed,
                        child: PriceRowWidget(
                          label: price.label,
                          price: price.price,
                        ),
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/gold-price'),
        onTap: (index) {},
      ),
    );
  }

  Widget _buildTabChip(String label, bool isActive, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          context.go('/silver-price');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.textMuted,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.hindSiliguri(
            fontSize: 11,
            color: isActive ? AppColors.gold : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
