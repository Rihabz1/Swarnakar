import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/utils/currency_formatter.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/features/dashboard/providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goldPrice = ref.watch(dashboardGoldPriceProvider);
    final silverPrice = ref.watch(dashboardSilverPriceProvider);

    final dashboardCards = [
      ('সোনার বাজার', 'Gold Market', Icons.diamond_outlined, '/gold-price'),
      ('রৌপ্যের বাজার', 'Silver Market', Icons.circle_outlined, '/silver-price'),
      ('ক্যালকুলেটর', 'Calculator', Icons.calculate_outlined, '/calculator'),
      ('যাকাত', 'Zakat', Icons.shield_outlined, '/zakat'),
      ('বিবরণী', 'Reports', Icons.receipt_long_outlined, '/reports'),
      ('সেটিংস', 'Settings', Icons.settings_outlined, '/settings'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          AppStrings.appName,
          style: AppTextStyles.heading2,
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.gold,
                size: 14,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Price Ticker Strip
            Padding(
              padding: const EdgeInsets.all(12),
              child: FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPriceSection(
                          'সোনা / ভরি',
                          CurrencyFormatter.formatBDT(goldPrice),
                          'আজ সকাল ৯:৩০',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.gold.withOpacity(0.15),
                      ),
                      Expanded(
                        child: _buildPriceSection(
                          'রূপা / ভরি',
                          CurrencyFormatter.formatBDT(silverPrice),
                          'আজ সকাল ৯:৩০',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.gold.withOpacity(0.15),
                      ),
                      Expanded(
                        child: _buildPriceSection(
                          'আপডেট',
                          'আজ ৯টা',
                          '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Services Section Label
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 12, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.services.toUpperCase(),
                  style: AppTextStyles.poppins(
                    fontSize: 9,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            // Dashboard Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: dashboardCards.length,
                itemBuilder: (context, index) {
                  final (bengaliName, englishName, icon, route) = dashboardCards[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100),
                    child: GestureDetector(
                      onTap: () => context.go(route),
                      child: _buildDashboardCard(
                        bengaliName,
                        englishName,
                        icon,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/dashboard'),
        onTap: (index) {},
      ),
    );
  }

  Widget _buildPriceSection(String label, String value, String subtext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.hindSiliguri(
            fontSize: 8.5,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.hindSiliguri(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        if (subtext.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtext,
              style: AppTextStyles.hindSiliguri(
                fontSize: 8,
                color: AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDashboardCard(String bengaliName, String englishName, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.08),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: 18,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            bengaliName,
            textAlign: TextAlign.center,
            style: AppTextStyles.hindSiliguri(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          Text(
            englishName,
            textAlign: TextAlign.center,
            style: AppTextStyles.poppins(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
