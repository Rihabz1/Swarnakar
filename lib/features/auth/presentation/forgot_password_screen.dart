import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sanitizePhoneInput(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final cleaned = digits.length > 13 ? digits.substring(0, 13) : digits;
    if (_phoneController.text == cleaned) return;
    final currentSelection = _phoneController.selection.baseOffset;
    final nextOffset = currentSelection < 0
        ? cleaned.length
        : currentSelection.clamp(0, cleaned.length);
    _phoneController.value = _phoneController.value.copyWith(
      text: cleaned,
      selection: TextSelection.collapsed(offset: nextOffset),
      composing: TextRange.empty,
    );
  }

  String _normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('880') && digits.length == 13) {
      return digits.substring(2);
    }
    if (digits.startsWith('88') && digits.length == 13) {
      return digits.substring(2);
    }
    return digits;
  }

  bool _isValidBdMobile(String phone) {
    return RegExp(r'^01[3-9]\d{8}$').hasMatch(phone);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _sendOtp() {
    final phone = _normalizePhone(_phoneController.text.trim());

    if (phone.isEmpty || !_isValidBdMobile(phone)) {
      _showMessage('সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন (01XXXXXXXXX)।');
      return;
    }

    context.go('/otp?phone=$phone&flow=reset');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.34),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    FadeInDown(
                      child: Text(
                        'পাসওয়ার্ড রিসেট',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInUp(
                      delay: const Duration(milliseconds: 120),
                      child: Text(
                        'মোবাইল নম্বর দিন, আমরা OTP পাঠাবো',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 12,
                          color: AppColors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 220),
                      child: GoldenInputField(
                        hint: 'মোবাইল নম্বর',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 13,
                        controller: _phoneController,
                        onChanged: _sanitizePhoneInput,
                        isGlassmorphic: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeInUp(
                      delay: const Duration(milliseconds: 320),
                      child: GoldenButton(
                        text: 'OTP পাঠান',
                        onPressed: _sendOtp,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'লগইন এ ফিরে যান',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 12,
                          color: AppColors.gold.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
