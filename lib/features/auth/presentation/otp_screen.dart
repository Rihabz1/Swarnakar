import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'dart:async';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;
  late Timer _timer;
  int _secondsRemaining = 42;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String _maskEmail(String email) {
    if (email.length < 3) return email;
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    final masked = username[0] + '*' * (username.length - 2) + username[username.length - 1];
    return '$masked@${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundSecondary,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
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
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.24)),
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
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.36),
                                  width: 1.5,
                                ),
                                color: AppColors.background.withValues(alpha: 0.35),
                              ),
                              child: const Icon(
                                Icons.badge_outlined,
                                color: AppColors.gold,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            delay: const Duration(milliseconds: 180),
                            child: Text(
                              AppStrings.verifyOtpTitle,
                              style: AppTextStyles.hindSiliguri(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeInUp(
                            delay: const Duration(milliseconds: 260),
                            child: Text(
                              _maskEmail(widget.email),
                              style: AppTextStyles.hindSiliguri(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildOtpBoxes(),
                          const SizedBox(height: 20),
                          FadeInUp(
                            delay: const Duration(milliseconds: 520),
                            child: GoldenButton(
                              text: AppStrings.verify,
                              onPressed: () {
                                context.go('/login');
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            delay: const Duration(milliseconds: 620),
                            child: _buildResendRow(),
                          ),
                          const SizedBox(height: 14),
                          FadeInUp(
                            delay: const Duration(milliseconds: 700),
                            child: Text(
                              AppStrings.termsAccept,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.hindSiliguri(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
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

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 44,
            height: 54,
            child: FadeInUp(
              delay: Duration(milliseconds: 500 + (index * 100)),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.26),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: AppTextStyles.hindSiliguri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _otpFocusNodes[index + 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.didntReceiveCode,
          style: AppTextStyles.hindSiliguri(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        _secondsRemaining > 0
            ? Text(
                '${AppStrings.resendCode} ($_secondsRemaining:${(_secondsRemaining % 60).toString().padLeft(2, '0')})',
                style: AppTextStyles.hindSiliguri(
                  fontSize: 11,
                  color: AppColors.gold,
                ),
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _secondsRemaining = 42;
                  });
                  _startTimer();
                },
                child: Text(
                  AppStrings.resendCode,
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
