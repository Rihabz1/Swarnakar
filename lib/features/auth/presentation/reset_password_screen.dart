import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'package:swarnakar/features/auth/providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({super.key, required this.email, required this.resetToken});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _validateAndSubmit() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final whitespaceRegex = RegExp(r'\s');

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('নতুন পাসওয়ার্ড ও কনফার্ম পাসওয়ার্ড দিন।');
      return;
    }
    if (whitespaceRegex.hasMatch(password) || whitespaceRegex.hasMatch(confirmPassword)) {
      _showMessage('পাসওয়ার্ডে স্পেস ব্যবহার করা যাবে না।');
      return;
    }
    if (password.length < 8) {
      _showMessage('পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('পাসওয়ার্ড মিলছে না।');
      return;
    }

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.resetPassword(
        resetToken: widget.resetToken,
        newPassword: password,
      );
      TextInput.finishAutofillContext(shouldSave: true);
      _showMessage('পাসওয়ার্ড সফলভাবে আপডেট হয়েছে।');
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      _showMessage(e.toString());
    }
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
                child: AutofillGroup(
                  child: Column(
                    children: [
                    FadeInDown(
                      child: Text(
                        'নতুন পাসওয়ার্ড সেট করুন',
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
                        widget.email,
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
                        hint: 'নতুন পাসওয়ার্ড',
                        obscureText: true,
                        icon: Icons.lock_outline,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: _passwordController,
                        isGlassmorphic: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 320),
                      child: GoldenInputField(
                        hint: 'পাসওয়ার্ড নিশ্চিত করুন',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: _confirmPasswordController,
                        isGlassmorphic: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeInUp(
                      delay: const Duration(milliseconds: 420),
                      child: GoldenButton(
                        text: 'পাসওয়ার্ড আপডেট করুন',
                        onPressed: _validateAndSubmit,
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
      ),
    );
  }
}
