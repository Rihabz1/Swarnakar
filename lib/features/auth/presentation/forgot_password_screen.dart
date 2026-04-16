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
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _forceEmailLowercase(String value) {
    final lowered = value.toLowerCase();
    if (_emailController.text == lowered) return;
    final currentSelection = _emailController.selection.baseOffset;
    final nextOffset = currentSelection < 0
        ? lowered.length
        : currentSelection.clamp(0, lowered.length);
    _emailController.value = _emailController.value.copyWith(
      text: lowered,
      selection: TextSelection.collapsed(offset: nextOffset),
      composing: TextRange.empty,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _sendOtp() {
    final email = _emailController.text.trim().toLowerCase();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showMessage('সঠিক ইমেইল দিন।');
      return;
    }

    context.go('/otp?email=$email&flow=reset');
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
                        'ইমেইল দিন, আমরা OTP পাঠাবো',
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
                        hint: 'ইমেইল ঠিকানা',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        onChanged: _forceEmailLowercase,
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
