import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/constants/app_assets.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  bool _validateSignup() {
    final name = _nameController.text.trim();
    final phone = _normalizePhone(_phoneController.text.trim());
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final whitespaceRegex = RegExp(r'\s');

    if (name.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('সবগুলো তথ্য দিন।');
      return false;
    }
    if (!_isValidBdMobile(phone)) {
      _showError('সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন (01XXXXXXXXX)।');
      return false;
    }
    if (whitespaceRegex.hasMatch(password) || whitespaceRegex.hasMatch(confirmPassword)) {
      _showError('পাসওয়ার্ডে স্পেস ব্যবহার করা যাবে না।');
      return false;
    }
    if (password.length < 8) {
      _showError('পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।');
      return false;
    }
    if (password != confirmPassword) {
      _showError('পাসওয়ার্ড মিলছে না।');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/login');
                        }
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.gold,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Sign Up',
                      style: AppTextStyles.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
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
                          FadeInUp(
                            delay: const Duration(milliseconds: 180),
                            child: GoldenInputField(
                              hint: AppStrings.fullName,
                              icon: Icons.person_outline,
                              controller: _nameController,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeInUp(
                            delay: const Duration(milliseconds: 280),
                            child: GoldenInputField(
                              hint: AppStrings.mobileNumber,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              maxLength: 13,
                              controller: _phoneController,
                              onChanged: _sanitizePhoneInput,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeInUp(
                            delay: const Duration(milliseconds: 380),
                            child: GoldenInputField(
                              hint: AppStrings.password,
                              icon: Icons.lock_outline,
                              obscureText: true,
                              controller: _passwordController,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeInUp(
                            delay: const Duration(milliseconds: 470),
                            child: GoldenInputField(
                              hint: AppStrings.confirmPassword,
                              icon: Icons.lock_outline,
                              obscureText: true,
                              controller: _confirmPasswordController,
                            ),
                          ),
                          const SizedBox(height: 18),
                          FadeInUp(
                            delay: const Duration(milliseconds: 560),
                            child: GoldenButton(
                              text: AppStrings.createAccount,
                              onPressed: () {
                                if (!_validateSignup()) return;
                                final phone = _normalizePhone(_phoneController.text.trim());
                                context.go('/otp?phone=$phone');
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDivider(),
                          const SizedBox(height: 12),
                          FadeInUp(
                            delay: const Duration(milliseconds: 660),
                            child: _buildGoogleSignUp(),
                          ),
                          const SizedBox(height: 20),
                          FadeInUp(
                            delay: const Duration(milliseconds: 760),
                            child: _buildLoginLink(),
                          ),
                        ],
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

  Widget _buildGoogleSignUp() {
    return OutlinedButton.icon(
      onPressed: () {},
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.haveAccount,
          style: AppTextStyles.hindSiliguri(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text(
            AppStrings.signInHere,
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
