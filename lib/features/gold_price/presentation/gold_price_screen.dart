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
import 'package:swarnakar/features/gold_price/providers/gold_price_provider.dart';
import 'package:swarnakar/core/utils/date_formatter.dart';
import 'package:swarnakar/shared/models/price_model.dart';

class GoldPriceScreen extends ConsumerWidget {
  const GoldPriceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(activeSubscriptionProvider);
    final pricesBySectionAsync = ref.watch(goldPricesBySection);

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
          AppStrings.goldMarket,
          style: AppTextStyles.hindSiliguri(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                _buildTabChip(AppStrings.gold, true, context),
                const SizedBox(width: 6),
                _buildTabChip(AppStrings.silver, false, context),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          child: pricesBySectionAsync.when(
            data: (pricesBySection) {
              final subtitleText = _buildUpdatedAtText(pricesBySection);
              return Column(
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
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Text(
                    AppStrings.errorOccurred,
                    style: AppTextStyles.hindSiliguri(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.tryAgain,
                    style: AppTextStyles.hindSiliguri(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  String _buildUpdatedAtText(Map<String, List<PriceModel>> pricesBySection) {
    final price = _pickFirstPrice(pricesBySection.values);
    final formatted = DateFormatter.formatUpdatedAt(price?.updatedAt);
    if (formatted.isEmpty) {
      return 'সর্বশেষ আপডেট: --';
    }
    return 'সর্বশেষ আপডেট: $formatted';
  }

  PriceModel? _pickFirstPrice(Iterable<List<PriceModel>> sections) {
    for (final prices in sections) {
      if (prices.isNotEmpty) {
        return prices.first;
      }
    }
    return null;
  }
}
