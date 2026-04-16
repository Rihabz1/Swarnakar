import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swarnakar/core/theme/app_colors.dart';

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
      ('হোম', Icons.home_outlined, '/dashboard'),
      ('স্বর্ণ', Icons.diamond_outlined, '/gold-price'),
      ('রৌপ্য', Icons.circle_outlined, '/silver-price'),
      ('ক্যালকুলেটর', Icons.calculate_outlined, '/calculator'),
      ('প্রোফাইল', Icons.person_outlined, '/settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.16),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          final route = items[index].$3;
          context.go(route);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconSize: 22,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'SutonnyMJ',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'SutonnyMJ',
          fontSize: 11,
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
