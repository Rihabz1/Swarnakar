import 'package:flutter/material.dart';
import 'package:swarnakar/core/theme/app_colors.dart';

class GoldPriceCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;

  const GoldPriceCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(
            color: AppColors.gold,
            width: 3,
          ),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
