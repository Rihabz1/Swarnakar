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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: GoldenInputField(
                  hint: AppStrings.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: GoldenInputField(
                  hint: AppStrings.passwordHint,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  controller: _passwordController,
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppStrings.forgotPassword,
                    style: AppTextStyles.hindSiliguri(
                      fontSize: 11,
                      color: AppColors.gold.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: GoldenButton(
                  text: AppStrings.signIn,
                  isLoading: isLoading,
                  onPressed: () {
                    // Mock login - just navigate to dashboard
                    context.go('/dashboard');
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: _buildGoogleSignIn(),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 1200),
                child: _buildSignupLink(),
              ),
            ],
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.appName,
            style: AppTextStyles.hindSiliguri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.appTagline,
            style: AppTextStyles.hindSiliguri(
              fontSize: 10,
              color: AppColors.textMuted,
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

  Widget _buildGoogleSignIn() {
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

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: AppTextStyles.hindSiliguri(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/signup'),
          child: Text(
            AppStrings.register,
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
