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
    final items = [
      _NavItem(
        'হোম',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_filled,
        route: '/dashboard',
        selectedColor: AppColors.gold,
      ),
      _NavItem(
        'স্বর্ণ',
        icon: Icons.diamond_outlined,
        activeIcon: Icons.diamond,
        route: '/gold-price',
        selectedColor: AppColors.gold,
      ),
      _NavItem(
        'রৌপ্য',
        icon: Icons.diamond_outlined,
        activeIcon: Icons.diamond_outlined,
        route: '/silver-price',
        selectedColor: AppColors.silver,
        activeSize: 24,
      ),
      _NavItem(
        'ক্যালকুলেটর',
        icon: Icons.calculate_outlined,
        activeIcon: Icons.calculate,
        route: '/calculator',
        selectedColor: AppColors.gold,
      ),
      _NavItem(
        'প্রোফাইল',
        icon: Icons.person_outlined,
        activeIcon: Icons.person,
        route: '/settings',
        selectedColor: AppColors.gold,
      ),
    ];
    final safeIndex = currentIndex >= 0 && currentIndex < items.length ? currentIndex : 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
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
        currentIndex: safeIndex,
        onTap: (index) {
          final route = items[index].route;
          context.go(route);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconSize: 22,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: items
            .map((item) => BottomNavigationBarItem(
                  icon: _buildNavItem(item, isSelected: false),
                  activeIcon: _buildNavItem(item, isSelected: true),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, {required bool isSelected}) {
    final color = isSelected ? item.selectedColor : AppColors.textMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSelected ? item.activeIcon : item.icon,
          color: color,
          size: isSelected ? item.activeSize ?? 22 : 22,
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: TextStyle(
            fontFamily: 'SutonnyMJ',
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  static int getIndexFromRoute(String route) {
    switch (route) {
      case '/dashboard':
        return 0;
      case '/gold-price':
        return 1;
      case '/silver-price':
        return 2;
      case '/calculator':
      case '/zakat':
      case '/converter':
        return 3;
      case '/settings':
      case '/price-history':
        return 4;
      default:
        return 0;
    }
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final Color selectedColor;
  final double? activeSize;

  const _NavItem(
    this.label, {
    required this.icon,
    required this.activeIcon,
    required this.route,
    required this.selectedColor,
    this.activeSize,
  });
}
