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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: _isFocused
              ? AppColors.gold.withValues(alpha: 0.65)
              : AppColors.gold.withValues(alpha: 0.2),
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          if (widget.icon != null)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                widget.icon,
                color: AppColors.gold,
                size: 20,
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
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.icon == null ? 16 : 0,
                  vertical: 16,
                ),
                hintText: widget.hint,
                hintStyle: AppTextStyles.hindSiliguri(
                  fontSize: 14,
                  color: AppColors.textSecondary,
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
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
