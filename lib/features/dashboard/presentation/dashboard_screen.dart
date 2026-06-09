import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/providers/connectivity_provider.dart';
import 'package:swarnakar/core/utils/connectivity_helper.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/features/dashboard/providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastUpdatedAsync = ref.watch(dashboardLastUpdatedProvider);
    final internetAsync = ref.watch(internetConnectionProvider);
    final isOffline = internetAsync.value == false;
    final updateText = isOffline
        ? const _UpdateText(
            timeLine: ConnectivityHelper.offlineTitle,
            dateLine: ConnectivityHelper.offlineRequiredMessage,
          )
        : _buildUpdatedAtText(lastUpdatedAsync);
    final noticeAsync = ref.watch(dashboardNoticeProvider);
    final noticeText = isOffline
        ? ConnectivityHelper.offlineShortMessage
        : noticeAsync.value ?? defaultDashboardNotice;

    final dashboardCards = [
      (
        'সোনার বাজার',
        'Gold Market',
        Icons.diamond_outlined,
        '/gold-price',
        AppColors.gold
      ),
      (
        'রৌপ্যের বাজার',
        'Silver Market',
        Icons.diamond_outlined,
        '/silver-price',
        AppColors.silver
      ),
      (
        'ক্যালকুলেটর',
        'Calculator',
        Icons.calculate_outlined,
        '/calculator',
        AppColors.gold
      ),
      ('যাকাত', 'Zakat', Icons.shield_outlined, '/zakat', AppColors.gold),
      (
        AppStrings.converter,
        'Converter',
        Icons.swap_horiz,
        '/converter',
        AppColors.gold
      ),
      (
        AppStrings.priceHistory,
        'History',
        Icons.show_chart_outlined,
        '/price-history',
        AppColors.gold
      ),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
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
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (isOffline) ...[
                        _buildOfflineBanner(),
                        const SizedBox(height: 10),
                      ],
                      FadeInDown(
                        child: _buildUpdateCard(updateText, noticeText),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 16, top: 0, bottom: 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    AppStrings.services,
                    style: AppTextStyles.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.38,
                  ),
                  itemCount: dashboardCards.length,
                  itemBuilder: (context, index) {
                    final (bengaliName, englishName, icon, route, iconColor) =
                        dashboardCards[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 90),
                      child: GestureDetector(
                        onTap: () => context.go(route),
                        child: _buildDashboardCard(
                          bengaliName,
                          englishName,
                          icon,
                          iconColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: AppBottomNav.getIndexFromRoute('/dashboard'),
          onTap: (index) {},
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Text(
        ConnectivityHelper.offlineRetryMessage,
        textAlign: TextAlign.center,
        style: AppTextStyles.hindSiliguri(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildUpdateCard(_UpdateText updateText, String noticeText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
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
      child: Column(
        children: [
          Column(
            children: [
              Text(
                updateText.timeLine,
                textAlign: TextAlign.center,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  height: 1.22,
                ),
              ),
              Text(
                updateText.dateLine,
                textAlign: TextAlign.center,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  height: 1.22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.16),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: const Color(0xFFA14220),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        color: AppColors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'নোটিশ',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    noticeText,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.hindSiliguri(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    String bengaliName,
    String englishName,
    IconData icon,
    Color iconColor,
  ) {
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.1),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
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
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  _UpdateText _buildUpdatedAtText(AsyncValue<DateTime?> lastUpdatedAsync) {
    return lastUpdatedAsync.when(
      data: (updatedAt) => _formatBanglaUpdatedAt(updatedAt),
      loading: () => const _UpdateText(
        timeLine: 'সর্বশেষ আপডেট: --',
        dateLine: '',
      ),
      error: (_, __) => const _UpdateText(
        timeLine: 'সর্বশেষ আপডেট: --',
        dateLine: '',
      ),
    );
  }

  _UpdateText _formatBanglaUpdatedAt(DateTime? updatedAt) {
    if (updatedAt == null) {
      return const _UpdateText(
        timeLine: 'সর্বশেষ আপডেট: --',
        dateLine: '',
      );
    }

    final local = updatedAt.toLocal();
    final period = local.hour < 12 ? 'সকাল' : 'বেলা';
    final hourOfPeriod = local.hour % 12;
    final hour = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    final minute = local.minute.toString().padLeft(2, '0');
    final month = _banglaMonths[local.month - 1];
    final weekday = _banglaWeekdays[local.weekday - 1];

    return _UpdateText(
      timeLine:
          'সর্বশেষ আপডেট: $period ${_toBanglaDigits(hour.toString())}.${_toBanglaDigits(minute)}টা',
      dateLine:
          '${_toBanglaDigits(local.day.toString())}ই $month ${_toBanglaDigits(local.year.toString())} রোজ: $weekday',
    );
  }

  String _toBanglaDigits(String value) {
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return value.replaceAllMapped(
      RegExp(r'\d'),
      (match) => banglaDigits[int.parse(match.group(0)!)],
    );
  }

  static const _banglaMonths = [
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];

  static const _banglaWeekdays = [
    'সোমবার',
    'মঙ্গলবার',
    'বুধবার',
    'বৃহস্পতিবার',
    'শুক্রবার',
    'শনিবার',
    'রবিবার',
  ];
}

class _UpdateText {
  const _UpdateText({
    required this.timeLine,
    required this.dateLine,
  });

  final String timeLine;
  final String dateLine;
}
