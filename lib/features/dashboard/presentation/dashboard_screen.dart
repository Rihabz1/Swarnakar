import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/utils/currency_formatter.dart';
import 'package:swarnakar/core/providers/core_providers.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/features/dashboard/providers/dashboard_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goldPrice = ref.watch(dashboardGoldPriceProvider);
    final silverPrice = ref.watch(dashboardSilverPriceProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);
    final exactUpdateTime = DateFormat('dd MMMM yyyy, hh:mm a', 'bn_BD').format(DateTime.now());
    final updateText = 'সর্বশেষ আপডেট: $exactUpdateTime';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        title: Text(
          AppStrings.appName,
          style: AppTextStyles.hindSiliguri(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
            height: 1.2,
          ),
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
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildPriceSection(
                                'সোনার বর্তমান বাজার',
                                CurrencyFormatter.formatBDT(goldPrice),
                                updateText,
                                isLocked: !isSubscribed,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 46,
                              color: AppColors.gold.withValues(alpha: 0.15),
                            ),
                            Expanded(
                              child: _buildPriceSection(
                                'রৌপ্যের বর্তমান বাজার',
                                CurrencyFormatter.formatBDT(silverPrice),
                                updateText,
                                isLocked: !isSubscribed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (!isSubscribed)
                          Align(
                            alignment: Alignment.center,
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/paywall'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 34),
                                visualDensity: const VisualDensity(
                                  horizontal: -2,
                                  vertical: -2,
                                ),
                                side: BorderSide(
                                  color: AppColors.gold.withValues(alpha: 0.55),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              icon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.gold,
                                size: 14,
                              ),
                              label: Text(
                                'প্রিমিয়াম আনলক করুন',
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          )
                        else
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                'প্রিমিয়াম সক্রিয়',
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4, bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.services,
                    style: AppTextStyles.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: dashboardCards.length,
                  itemBuilder: (context, index) {
                    final (bengaliName, englishName, icon, route) = dashboardCards[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 90),
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
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/dashboard'),
        onTap: (index) {},
      ),
    );
  }

  Widget _buildPriceSection(
    String label,
    String value,
    String subtext, {
    bool isLocked = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.hindSiliguri(
            fontSize: 9.5,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (isLocked)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.lock_outline,
                  size: 12,
                  color: AppColors.vividGold.withValues(alpha: 0.82),
                ),
              ),
            Text(
              isLocked ? '••••••' : value,
              style: AppTextStyles.hindSiliguri(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isLocked ? AppColors.mutedChampagne : AppColors.gold,
              ),
            ),
          ],
        ),
        if (subtext.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtext,
              style: AppTextStyles.hindSiliguri(
                fontSize: 9,
                color: AppColors.white,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x33C5A059),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bengaliName,
            textAlign: TextAlign.center,
            style: AppTextStyles.hindSiliguri(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          Text(
            englishName,
            textAlign: TextAlign.center,
            style: AppTextStyles.poppins(
              fontSize: 10,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
