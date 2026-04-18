import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'package:swarnakar/features/auth/providers/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
  }

  bool _validateLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final whitespaceRegex = RegExp(r'\s');

    if (email.isEmpty || password.isEmpty) {
      _showError('ইমেইল ও পাসওয়ার্ড দিন।');
      return false;
    }
    if (!emailRegex.hasMatch(email)) {
      _showError('সঠিক ইমেইল ফরম্যাট দিন (example@email.com)।');
      return false;
    }
    if (whitespaceRegex.hasMatch(email)) {
      _showError('ইমেইলে স্পেস ব্যবহার করা যাবে না।');
      return false;
    }
    if (whitespaceRegex.hasMatch(password)) {
      _showError('পাসওয়ার্ডে স্পেস ব্যবহার করা যাবে না।');
      return false;
    }
    if (password.length < 6) {
      _showError('পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।');
      return false;
    }
    return true;
  }

  bool get _isGoogleSignInSupported {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    
    // Listen for auth state changes
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        _showError(next.error!);
      }
      if (next.user != null) {
        _showSuccess('সফলভাবে লগইন করেছেন!');
        context.go('/dashboard');
      }
    });

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
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 26),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: GoldenInputField(
                            hint: AppStrings.email,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            controller: _emailController,
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
                            keyboardType: TextInputType.visiblePassword,
                            autofillHints: const [AutofillHints.password],
                            enableSuggestions: false,
                            autocorrect: false,
                            controller: _passwordController,
                            isGlassmorphic: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInUp(
                          delay: const Duration(milliseconds: 430),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => context.go('/forgot-password'),
                              child: Text(
                                AppStrings.forgotPassword,
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 11,
                                  color: AppColors.gold.withValues(alpha: 0.72),
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
                            isLoading: authState.isLoading,
                            onPressed: () async {
                              if (!_validateLogin()) return;
                              final user = await authNotifier.signIn(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                              if (user != null) {
                                TextInput.finishAutofillContext(shouldSave: true);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildDivider(),
                        const SizedBox(height: 14),
                        FadeInUp(
                          delay: const Duration(milliseconds: 650),
                          child: _buildGoogleSignIn(authNotifier, authState.isLoading),
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
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold, width: 1.6),
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
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.gold,
              size: 30,
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

  Widget _buildGoogleSignIn(AuthNotifier authNotifier, bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : () async {
        if (!_isGoogleSignInSupported) {
          _showError('Google Sign-In Linux এ সাপোর্ট করে না। Android/iOS/Web ব্যবহার করুন।');
          return;
        }
        await authNotifier.signInWithGoogle(allowNewUser: false);
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      icon: SvgPicture.network(
        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
        width: 18,
        height: 18,
        placeholderBuilder: (context) => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 1.4),
        ),
      ),
      label: Text(
        'Google দিয়ে সাইন ইন করুন',
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