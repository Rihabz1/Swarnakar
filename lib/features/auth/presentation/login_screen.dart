import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'package:swarnakar/core/providers/core_providers.dart';
import 'package:swarnakar/core/constants/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swarnakar/features/auth/data/firebase_auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

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

  void _handleForgotPassword() {
    context.go('/forgot-password');
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  bool _validateLogin() {
    final phone = _normalizePhone(_phoneController.text.trim());
    final password = _passwordController.text;
    final whitespaceRegex = RegExp(r'\s');

    if (phone.isEmpty || password.isEmpty) {
      _showError('মোবাইল নম্বর ও পাসওয়ার্ড দিন।');
      return false;
    }
    if (!_isValidBdMobile(phone)) {
      _showError('সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন (01XXXXXXXXX)।');
      return false;
    }
    if (whitespaceRegex.hasMatch(password)) {
      _showError('পাসওয়ার্ডে স্পেস ব্যবহার করা যাবে না।');
      return false;
    }
    if (password.length < 8) {
      _showError('পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।');
      return false;
    }
    return true;
  }

  Future<void> _handleGoogleSignIn() async {
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      final user = await FirebaseAuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (user == null) {
        _showError('Google সাইন-ইন বাতিল হয়েছে।');
        return;
      }
      context.go('/dashboard');
    } catch (_) {
      if (!mounted) return;
      _showError('Google সাইন-ইন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।');
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.24),
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
                      _buildHeader(),
                      const SizedBox(height: 26),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: GoldenInputField(
                          hint: AppStrings.mobileNumber,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          maxLength: 13,
                          controller: _phoneController,
                          onChanged: _sanitizePhoneInput,
                          isGlassmorphic: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        delay: const Duration(milliseconds: 320),
                        child: GoldenInputField(
                          hint: AppStrings.passwordHint,
                          icon: Icons.lock_outline,
                          obscureText: true,
                          controller: _passwordController,
                          isGlassmorphic: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeInUp(
                        delay: const Duration(milliseconds: 430),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _handleForgotPassword,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppStrings.forgotPassword,
                              style: AppTextStyles.hindSiliguri(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        delay: const Duration(milliseconds: 530),
                        child: GoldenButton(
                          text: AppStrings.signIn,
                          isLoading: isLoading,
                          onPressed: () {
                            if (!_validateLogin()) return;
                            context.go('/dashboard');
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildDivider(),
                      const SizedBox(height: 14),
                      FadeInUp(
                        delay: const Duration(milliseconds: 650),
                        child: _buildGoogleSignIn(),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 760),
                        child: _buildSignupLink(),
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

  Widget _buildHeader() {
    return FadeInDown(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold, width: 1.4),
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceRaised,
                  AppColors.surface,
                ],
              ),
            ),
            child: Image.asset(
              'assets/images/swarnakar-nobg.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.appName,
            style: AppTextStyles.hindSiliguri(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'স্বর্ণের বাজারের নির্ভরযোগ্য সহায়ক',
            style: AppTextStyles.hindSiliguri(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textMuted.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppStrings.or,
            style: AppTextStyles.hindSiliguri(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textMuted.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignIn() {
    return OutlinedButton.icon(
      onPressed: _handleGoogleSignIn,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      icon: SvgPicture.asset(
        AppAssets.googleLogo,
        width: 18,
        height: 18,
      ),
      label: Text(
        AppStrings.signUpWithGoogle,
        style: AppTextStyles.hindSiliguri(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: AppTextStyles.hindSiliguri(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/signup'),
          child: Text(
            AppStrings.register,
            style: AppTextStyles.hindSiliguri(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}
