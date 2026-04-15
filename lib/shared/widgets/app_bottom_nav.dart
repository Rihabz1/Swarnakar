import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (AppStrings.home, Icons.home_outlined, '/dashboard'),
      (AppStrings.goldMarket, Icons.diamond_outlined, '/gold-price'),
      (AppStrings.silverMarket, Icons.circle_outlined, '/silver-price'),
      (AppStrings.calculator, Icons.calculate_outlined, '/calculator'),
      (AppStrings.profile, Icons.person_outlined, '/settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.gold.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          final route = items[index].$3;
          context.go(route);
        },
        backgroundColor: const Color(0xFF0D0D18),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: AppTextStyles.hindSiliguri(
          fontSize: 8.5,
          color: AppColors.gold,
        ),
        unselectedLabelStyle: AppTextStyles.hindSiliguri(
          fontSize: 8.5,
          color: AppColors.textMuted,
        ),
        items: items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.$2),
                  label: item.$1,
                ))
            .toList(),
      ),
    );
  }

  static int getIndexFromRoute(String route) {
    const routes = ['/dashboard', '/gold-price', '/silver-price', '/calculator', '/settings'];
    return routes.indexOf(route);
  }
}
