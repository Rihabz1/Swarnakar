import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:math';
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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String _generateStrongPassword({int length = 16}) {
    const uppercase = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const lowercase = 'abcdefghijkmnopqrstuvwxyz';
    const digits = '23456789';
    const symbols = '@#%+=!?4&*()-_';
    const allChars = '$uppercase$lowercase$digits$symbols';
    final random = Random.secure();

    final chars = <String>[
      uppercase[random.nextInt(uppercase.length)],
      lowercase[random.nextInt(lowercase.length)],
      digits[random.nextInt(digits.length)],
      symbols[random.nextInt(symbols.length)],
    ];

    for (var i = chars.length; i < length; i++) {
      chars.add(allChars[random.nextInt(allChars.length)]);
    }

    chars.shuffle(random);
    return chars.join();
  }

  void _useGeneratedPassword() {
    final generated = _generateStrongPassword();
    _passwordController.text = generated;
    _confirmPasswordController.text = generated;
    _showSuccess('শক্তিশালী পাসওয়ার্ড তৈরি করা হয়েছে।');
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

  bool _validateSignup() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final whitespaceRegex = RegExp(r'\s');

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('সবগুলো তথ্য দিন।');
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
    if (whitespaceRegex.hasMatch(password) || whitespaceRegex.hasMatch(confirmPassword)) {
      _showError('পাসওয়ার্ডে স্পেস ব্যবহার করা যাবে না।');
      return false;
    }
    if (password.length < 6) {
      _showError('পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।');
      return false;
    }
    if (password != confirmPassword) {
      _showError('পাসওয়ার্ড মিলছে না।');
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
    
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        _showError(next.error!);
      }
    });

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
                      child: AutofillGroup(
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
                                hint: AppStrings.email,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                controller: _emailController,
                                onChanged: _forceEmailLowercase,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FadeInUp(
                              delay: const Duration(milliseconds: 380),
                              child: GoldenInputField(
                                hint: AppStrings.password,
                                icon: Icons.lock_outline,
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,
                                autofillHints: const [AutofillHints.newPassword],
                                enableSuggestions: false,
                                autocorrect: false,
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
                                keyboardType: TextInputType.visiblePassword,
                                autofillHints: const [AutofillHints.newPassword],
                                enableSuggestions: false,
                                autocorrect: false,
                                controller: _confirmPasswordController,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _useGeneratedPassword,
                                icon: const Icon(Icons.password_rounded, size: 16),
                                label: const Text('Generate strong password'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.gold.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            FadeInUp(
                              delay: const Duration(milliseconds: 560),
                              child: GoldenButton(
                                text: AppStrings.createAccount,
                                isLoading: authState.isLoading,
                                onPressed: () async {
                                  if (!_validateSignup()) return;
                                  final router = GoRouter.of(context);
                                  final createdUser = await authNotifier.signUp(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );
                                  if (createdUser == null || !mounted) {
                                    return;
                                  }

                                  TextInput.finishAutofillContext(shouldSave: true);

                                  try {
                                    await ref.read(firebaseServiceProvider).resendVerificationEmail();
                                    await authNotifier.signOut();
                                  } catch (_) {
                                    if (!mounted) {
                                      return;
                                    }
                                    _showError('ভেরিফিকেশন ইমেইল পাঠানো যায়নি। আবার চেষ্টা করুন।');
                                    return;
                                  }

                                  _showSuccess(
                                    'অ্যাকাউন্ট তৈরি হয়েছে। ইমেইলে ভেরিফিকেশন লিংক পাঠানো হয়েছে।',
                                  );
                                  router.go('/login');
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDivider(),
                            const SizedBox(height: 12),
                            FadeInUp(
                              delay: const Duration(milliseconds: 660),
                              child: _buildGoogleSignUp(authNotifier, authState.isLoading),
                            ),
                            const SizedBox(height: 20),
                            FadeInUp(
                              delay: const Duration(milliseconds: 760),
                              child: _buildLoginLink(),
                            ),
                          ],
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
            style: AppTextStyles.hindSiliguri(fontSize: 11, color: AppColors.textMuted),
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

  Widget _buildGoogleSignUp(AuthNotifier authNotifier, bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : () async {
        if (!_isGoogleSignInSupported) {
          _showError('Google Sign-In Linux এ সাপোর্ট করে না। Android/iOS/Web ব্যবহার করুন।');
          return;
        }
        final router = GoRouter.of(context);
        final user = await authNotifier.signInWithGoogle(
          allowNewUser: true,
          allowExistingUser: false,
        );
        if (user != null && mounted) {
          _showSuccess('Google account দিয়ে signup সফল হয়েছে!');
          router.go('/dashboard');
        }
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
        'Google দিয়ে সাইন আপ করুন',
        style: AppTextStyles.hindSiliguri(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.haveAccount,
          style: AppTextStyles.hindSiliguri(fontSize: 12, color: AppColors.textMuted),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text(
            AppStrings.signInHere,
            style: AppTextStyles.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gold),
          ),
        ),
      ],
    );
  }
}