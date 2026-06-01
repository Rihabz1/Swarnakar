import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:country_picker/country_picker.dart';
import 'package:swarnakar/core/services/recaptcha_service.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import '../providers/auth_provider.dart';

enum PhoneAuthMode { signin, signup }

class PhoneAuthScreen extends ConsumerStatefulWidget {
  final PhoneAuthMode mode;

  const PhoneAuthScreen({super.key, this.mode = PhoneAuthMode.signin});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedCountryCode = '+880';
  bool _otpSent = false;
  String? _sentPhoneE164;
  int _resendCooldown = 0;

  bool get _isSignup => widget.mode == PhoneAuthMode.signup;
  String get _emailAuthRoute => _isSignup ? '/signup' : '/login';
  String get _fullPhoneNumber => _normalizePhoneNumber();
  String get _maskedPhone {
    final phone = _sentPhoneE164 ?? _fullPhoneNumber;
    if (phone.length < 8) return phone;
    final last4 = phone.substring(phone.length - 4);
    final firstPart = phone.substring(0, phone.length - 4);
    final masked = firstPart.length > 2
      ? '${firstPart.substring(0, firstPart.length - 2)}**'
      : '***';
    return '$masked$last4';
  }

  @override
  void initState() {
    super.initState();
    _startResendTimerIfNeeded();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _startResendTimerIfNeeded() {
    if (_resendCooldown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _resendCooldown > 0) {
          setState(() => _resendCooldown--);
          _startResendTimerIfNeeded();
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = _fullPhoneNumber;

    setState(() => _otpSent = false);

    final existingUser = await ref
        .read(firebaseServiceProvider)
        .getUserDataByPhoneNumber(phoneNumber);

    if (_isSignup && existingUser != null) {
      _showError('এই ফোন নম্বরটি ইতিমধ্যেই ব্যবহার করা হয়েছে। অনুগ্রহ করে লগইন করুন।');
      return;
    }

    if (!_isSignup && existingUser == null) {
      _showError('এই নম্বরের জন্য কোনো অ্যাকাউন্ট পাওয়া যায়নি। অনুগ্রহ করে সাইন আপ করুন।');
      return;
    }

    final recaptchaToken = await RecaptchaService.instance.getToken();
    if (kIsWeb && recaptchaToken == null) {
      _showError('সুরক্ষা যাচাই ব্যর্থ হয়েছে। আবার চেষ্টা করুন।');
      return;
    }

    try {
      await ref.read(authProvider.notifier).sendPhoneOtp(
        phoneNumber,
        recaptchaToken ?? '',
        isSignup: _isSignup,
          );

      if (!mounted) return;

      setState(() {
        _otpSent = true;
        _sentPhoneE164 = phoneNumber;
        _resendCooldown = 60;
      });
      _startResendTimerIfNeeded();
      
      _showSuccess('ভেরিফিকেশন কোড পাঠানো হয়েছে $_maskedPhone নম্বরে');
      _otpFocusNode.requestFocus();
      
    } catch (e) {
      _showError(e.toString());
      setState(() => _otpSent = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otpCode = _otpController.text.trim();
    if (otpCode.length != 6) {
      _showError('৬ অঙ্কের ভেরিফিকেশন কোড দিন');
      return;
    }

    final phoneNumber = _fullPhoneNumber;
    final name = _nameController.text.trim();
    final authNotifier = ref.read(authProvider.notifier);

    try {
      if (_isSignup) {
        await authNotifier.signUpWithPhone(phoneNumber, otpCode, name);
      } else {
        await authNotifier.signInWithPhone(phoneNumber, otpCode);
      }
      _showSuccess(_isSignup ? 'অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে!' : 'সফলভাবে লগইন করেছেন!');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) {
      _showError('পুনরায় কোড পাঠাতে $_resendCooldown সেকেন্ড অপেক্ষা করুন');
      return;
    }

    _otpController.clear();
    await _sendOtp();
  }

  void _goToEmailAuth() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(_emailAuthRoute);
  }

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        inputDecoration: InputDecoration(
          hintText: 'দেশ খুঁজুন',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountryCode = '+${country.phoneCode}';
        });
      },
    );
  }

  String _normalizePhoneNumber() {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return _selectedCountryCode;
    }

    // Bangladesh mobile numbers are commonly entered as 01XXXXXXXXX.
    // Convert that to +8801XXXXXXXXX before sending to Firebase.
    if (_selectedCountryCode == '+880') {
      if (digits.startsWith('0') && digits.length == 11) {
        return '+880${digits.substring(1)}';
      }
      if (digits.length == 10 && digits.startsWith('1')) {
        return '+880$digits';
      }
    }

    return '$_selectedCountryCode$digits';
  }

  String? _validateName(String? value) {
    if (_isSignup && (value == null || value.trim().isEmpty)) {
      return 'নাম দিন';
    }
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'নাম কমপক্ষে ২ অক্ষরের হতে হবে';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'মোবাইল নম্বর দিন';
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9 || digits.length > 11) {
      return 'সঠিক মোবাইল নম্বর দিন';
    }
    return null;
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _selectCountry,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCountryCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: AppColors.gold, size: 20),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: '১XXXXXXXXX',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (_) => _validatePhone(_phoneController.text),
              onFieldSubmitted: (_) => _sendOtp(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: PinCodeTextField(
        controller: _otpController,
        focusNode: _otpFocusNode,
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(12),
          fieldHeight: 55,
          fieldWidth: 50,
          activeFillColor: AppColors.background,
          inactiveFillColor: AppColors.background,
          selectedFillColor: AppColors.background,
          activeColor: AppColors.gold,
          inactiveColor: Colors.grey.shade600,
          selectedColor: AppColors.gold,
        ),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        onCompleted: (_) => _verifyOtp(),
        appContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.error != null && mounted) {
        _showError(next.error!);
      }
      if (next.user != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/dashboard');
        });
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios, color: AppColors.gold, size: 18),
          ),
          onPressed: _goToEmailAuth,
        ),
        title: Text(
          _isSignup ? 'ফোন সাইন আপ' : 'ফোন লগইন',
          style: AppTextStyles.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animated Icon
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.gold.withValues(alpha: 0.2),
                                AppColors.gold.withValues(alpha: 0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone_android,
                            color: AppColors.gold,
                            size: 40,
                          ),
                        ),
                      ),

                      // Title
                      Text(
                        _isSignup ? 'অ্যাকাউন্ট তৈরি করুন' : 'স্বাগতম',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _otpSent
                            ? 'নিচের ৬ অঙ্কের কোডটি দিন'
                            : (_isSignup 
                                ? 'ফোন নম্বর ব্যবহার করে সাইন আপ করুন' 
                                : 'ফোন নম্বর ব্যবহার করে লগইন করুন'),
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_otpSent && _sentPhoneE164 != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _maskedPhone,
                          style: AppTextStyles.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Name Field (signup only)
                      if (_isSignup && !_otpSent) ...[
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          validator: _validateName,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'আপনার নাম',
                            hintText: 'আপনার নাম লিখুন',
                            prefixIcon: const Icon(Icons.person_outline, color: AppColors.gold),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Phone Input
                      if (!_otpSent) ...[
                        _buildPhoneInput(),
                        const SizedBox(height: 8),
                        Text(
                          'এই নম্বরে একটি ভেরিফিকেশন কোড পাঠানো হবে',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        GoldenButton(
                          text: 'ভেরিফিকেশন কোড পাঠান',
                          isLoading: authState.isLoading,
                          onPressed: _sendOtp,
                          icon: Icons.send_outlined,
                        ),
                      ],

                      // OTP Input
                      if (_otpSent) ...[
                        _buildOtpInput(),
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'কোড পাননি? ',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            GestureDetector(
                              onTap: _resendCooldown > 0 || authState.isLoading 
                                  ? null 
                                  : _resendOtp,
                              child: Text(
                                _resendCooldown > 0 
                                    ? '$_resendCooldown সেকেন্ড পরে পুনরায় চেষ্টা করুন' 
                                    : 'পুনরায় পাঠান',
                                style: TextStyle(
                                  color: _resendCooldown > 0 || authState.isLoading
                                      ? Colors.grey.shade600
                                      : AppColors.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        GoldenButton(
                          text: _isSignup ? 'সাইন আপ সম্পন্ন করুন' : 'ভেরিফাই করে লগইন করুন',
                          isLoading: authState.isLoading,
                          onPressed: _verifyOtp,
                          icon: Icons.check_circle_outline,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade700)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'অথবা',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade700)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Switch to Email Auth
                      TextButton(
                        onPressed: _goToEmailAuth,
                        child: Text(
                          _isSignup 
                              ? 'ইমেইল দিয়ে সাইন আপ করুন' 
                              : 'ইমেইল দিয়ে লগইন করুন',
                          style: TextStyle(
                            color: AppColors.gold.withValues(alpha: 0.8),
                            fontSize: 14,
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