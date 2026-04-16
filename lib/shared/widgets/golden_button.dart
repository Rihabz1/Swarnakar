import 'package:flutter/material.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';

class GoldenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final bool isFullWidth;

  const GoldenButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidget = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        disabledBackgroundColor: AppColors.goldDark,
        padding: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: Size(
          width ?? (isFullWidth ? double.infinity : 120),
          height,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : Text(
              text,
              style: AppTextStyles.buttonText,
            ),
    );

    if (isFullWidth) {
      return buttonWidget;
    }

    return SizedBox(
      width: width ?? 120,
      height: height,
      child: buttonWidget,
    );
  }
}
