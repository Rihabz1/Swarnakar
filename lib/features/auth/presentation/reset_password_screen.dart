import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'package:swarnakar/core/utils/connectivity_helper.dart';
import 'package:swarnakar/features/auth/data/firebase_auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  final String otp;

  const ResetPasswordScreen(
      {super.key, required this.phone, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _isLoading = false;

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

  bool _validateInputs() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final whitespaceRegex = RegExp(r'\s');
    if (password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('নতুন পাসওয়ার্ড ও কনফার্ম পাসওয়ার্ড দিন।');
      return false;
    }
    if (whitespaceRegex.hasMatch(password) ||
        whitespaceRegex.hasMatch(confirmPassword)) {
      _showMessage('পাসওয়ার্ডে স্পেস ব্যবহার করা যাবে না।');
      return false;
    }
    if (password.length < 8) {
      _showMessage('পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।');
      return false;
    }
    if (password != confirmPassword) {
      _showMessage('পাসওয়ার্ড মিলছে না।');
      return false;
    }
    return true;
  }

  Future<void> _submitReset() async {
    if (!_validateInputs()) return;
    if (widget.otp.trim().isEmpty) {
      _showMessage('OTP পাওয়া যায়নি। আবার OTP যাচাই করুন।');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuthService.instance.resetPasswordWithOtp(
        phone: widget.phone,
        otp: widget.otp,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      _showMessage('পাসওয়ার্ড সফলভাবে আপডেট হয়েছে।');
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      if (e is NetworkException) {
        _showMessage(ConnectivityHelper.offlineRetryMessage);
      } else if (e is AuthException) {
        _showMessage(e.message ?? 'পাসওয়ার্ড রিসেট ব্যর্থ হয়েছে।');
      } else {
        _showMessage('পাসওয়ার্ড রিসেট ব্যর্থ হয়েছে।');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                        'নতুন পাসওয়ার্ড সেট করুন',
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
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: _passwordController,
                        isGlassmorphic: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: GoldenInputField(
                        hint: 'পাসওয়ার্ড নিশ্চিত করুন',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: _confirmPasswordController,
                        isGlassmorphic: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeInUp(
                      delay: const Duration(milliseconds: 380),
                      child: GoldenButton(
                        text: 'পাসওয়ার্ড আপডেট করুন',
                        isLoading: _isLoading,
                        onPressed: _submitReset,
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
