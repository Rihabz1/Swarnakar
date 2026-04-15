import 'package:flutter/material.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';

class GoldenInputField extends StatefulWidget {
  final String hint;
  final IconData? icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final VoidCallback? onIconTap;

  const GoldenInputField({
    super.key,
    required this.hint,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.onIconTap,
  });

  @override
  State<GoldenInputField> createState() => _GoldenInputFieldState();
}

class _GoldenInputFieldState extends State<GoldenInputField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: _isFocused
              ? AppColors.gold.withOpacity(0.5)
              : AppColors.gold.withOpacity(0.18),
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          if (widget.icon != null)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(
                widget.icon,
                color: AppColors.gold,
                size: 16,
              ),
            ),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              obscureText: _obscureText && widget.obscureText,
              validator: widget.validator,
              maxLines: _obscureText && widget.obscureText ? 1 : widget.maxLines,
              maxLength: widget.maxLength,
              style: AppTextStyles.hindSiliguri(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.icon == null ? 14 : 0,
                  vertical: 12,
                ),
                hintText: widget.hint,
                hintStyle: AppTextStyles.hindSiliguri(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
                counterText: '',
              ),
            ),
          ),
          if (widget.obscureText)
            GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.gold,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
