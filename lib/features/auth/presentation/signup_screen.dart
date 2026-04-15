import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.gold,
            size: 18,
          ),
        ),
        title: Text(
          AppStrings.signUp,
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: GoldenInputField(
                  hint: AppStrings.fullName,
                  icon: Icons.person_outline,
                  controller: _nameController,
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: GoldenInputField(
                  hint: AppStrings.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: GoldenInputField(
                  hint: AppStrings.password,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  controller: _passwordController,
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: GoldenInputField(
                  hint: AppStrings.confirmPassword,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  controller: _confirmPasswordController,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: GoldenButton(
                  text: AppStrings.createAccount,
                  onPressed: () {
                    final email = _emailController.text;
                    context.go('/otp?email=$email');
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 1200),
                child: _buildGoogleSignUp(),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 1400),
                child: _buildLoginLink(),
              ),
            ],
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
            color: AppColors.textMuted.withOpacity(0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppStrings.or,
            style: AppTextStyles.hindSiliguri(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textMuted.withOpacity(0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignUp() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.g_mobiledata,
            color: Color(0xFF4285F4),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.signUpWithGoogle,
            style: AppTextStyles.hindSiliguri(
              fontSize: 11,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
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
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text(
            AppStrings.signInHere,
            style: AppTextStyles.hindSiliguri(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}
