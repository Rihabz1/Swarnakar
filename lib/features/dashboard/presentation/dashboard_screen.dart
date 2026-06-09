import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/features/dashboard/providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastUpdatedAsync = ref.watch(dashboardLastUpdatedProvider);
    final updateText = _buildUpdatedAtText(lastUpdatedAsync);

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
                  child: _buildUpdateCard(updateText),
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

  Widget _buildUpdateCard(_UpdateText updateText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  height: 1.22,
                ),
              ),
              Text(
                updateText.dateLine,
                textAlign: TextAlign.center,
                style: AppTextStyles.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  height: 1.22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'কেউ মাল কিনছে না। আরও ১ঘন্টা সময় লাগতে পারে।',
              textAlign: TextAlign.center,
              style: AppTextStyles.hindSiliguri(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.red,
                height: 1.25,
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
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
