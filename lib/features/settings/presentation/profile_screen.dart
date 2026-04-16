import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'package:swarnakar/features/settings/providers/profile_provider.dart';
import 'package:swarnakar/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    // Load profile data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _initializeControllers(Map<String, dynamic>? profile) {
    if (profile != null && _nameController.text.isEmpty) {
      _nameController.text = profile['name'] ?? '';
      _emailController.text = profile['email'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _addressController.text = profile['address'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    _initializeControllers(profileState.profile);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'প্রোফাইল',
          style: AppTextStyles.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        actions: [
          if (!profileState.isEditing && profileState.profile != null)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.gold),
              onPressed: profileNotifier.toggleEdit,
            ),
        ],
      ),
      body: profileState.isLoading && profileState.profile == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            )
          : profileState.error != null && profileState.profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'প্রোফাইল লোড করতে ব্যর্থ',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profileState.error ?? 'অজানা ত্রুটি',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: GoldenButton(
                          text: 'আবার চেষ্টা করুন',
                          onPressed: () =>
                              ref.read(profileProvider.notifier).loadProfile(),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileHeader(profileState),
                      const SizedBox(height: 24),
                      _buildStatsGrid(profileState.stats),
                      const SizedBox(height: 24),
                      _buildProfileForm(profileState, profileNotifier),
                      const SizedBox(height: 24),
                      _buildChangePasswordSection(context, profileNotifier, profileState),
                      const SizedBox(height: 24),
                      _buildDangerZone(context, authNotifier, profileNotifier),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(ProfileState state) {
    final name = _nameController.text.isEmpty ? 'আপনার নাম' : _nameController.text;
    final email = _emailController.text;

    return FadeInDown(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gold.withValues(alpha: 0.3),
                  AppColors.gold.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: AppTextStyles.hindSiliguri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: AppTextStyles.hindSiliguri(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic>? stats) {
    if (stats == null || stats.isEmpty) {
      return const SizedBox();
    }

    final items = [
      {
        'icon': Icons.calculate,
        'label': 'গণনা',
        'value': stats['totalCalculations'] ?? 0
      },
      {
        'icon': Icons.description,
        'label': 'রিপোর্ট',
        'value': stats['savedReports'] ?? 0
      },
      {
        'icon': Icons.star,
        'label': 'পছন্দ',
        'value': stats['favoritePrices'] ?? 0
      },
      {
        'icon': Icons.subscriptions,
        'label': 'সাবস্ক্রিপশন বাকি',
        'value': '${stats['subscriptionDaysLeft'] ?? 0} দিন'
      },
    ];

    return FadeInUp(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData,
                    color: AppColors.gold, size: 28),
                const SizedBox(height: 8),
                Text(
                  item['value'].toString(),
                  style: AppTextStyles.hindSiliguri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  item['label'] as String,
                  style: AppTextStyles.hindSiliguri(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileForm(ProfileState state, ProfileNotifier notifier) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ব্যক্তিগত তথ্য',
              style: AppTextStyles.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: 'পূর্ণ নাম',
              controller: _nameController,
              enabled: state.isEditing,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'ইমেইল',
              controller: _emailController,
              enabled: false,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'ফোন নম্বর',
              controller: _phoneController,
              enabled: state.isEditing,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'ঠিকানা',
              controller: _addressController,
              enabled: state.isEditing,
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            if (state.isEditing) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GoldenButton(
                      text: 'বাতিল',
                      onPressed: () {
                        notifier.toggleEdit();
                        _initializeControllers(state.profile);
                      },
                      isLoading: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GoldenButton(
                      text: 'সংরক্ষণ করুন',
                      onPressed: () async {
                        await notifier.updateProfile({
                          'name': _nameController.text,
                          'phone': _phoneController.text,
                          'address': _addressController.text,
                        });
                        if (mounted && !state.isLoading) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('প্রোফাইল আপডেট হয়েছে'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      isLoading: state.isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.hindSiliguri(
        fontSize: 14,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.hindSiliguri(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        fillColor: AppColors.background.withValues(alpha: 0.5),
        filled: true,
      ),
    );
  }

  Widget _buildChangePasswordSection(
    BuildContext context,
    ProfileNotifier notifier,
    ProfileState state,
  ) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'পাসওয়ার্ড নিরাপত্তা',
              style: AppTextStyles.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'আপনার অ্যাকাউন্টের নিরাপত্তার জন্য নিয়মিত পাসওয়ার্ড পরিবর্তন করুন।',
              style: AppTextStyles.hindSiliguri(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            GoldenButton(
              text: 'পাসওয়ার্ড পরিবর্তন করুন',
              onPressed: () => _showChangePasswordDialog(context, notifier, state),
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    ProfileNotifier notifier,
    ProfileState state,
  ) {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'পাসওয়ার্ড পরিবর্তন করুন',
          style: AppTextStyles.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'বর্তমান পাসওয়ার্ড',
                hint: 'আপনার বর্তমান পাসওয়ার্ড দিন',
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'নতুন পাসওয়ার্ড',
                hint: 'নতুন পাসওয়ার্ড দিন (কমপক্ষে ৬ অক্ষর)',
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'পাসওয়ার্ড নিশ্চিত করুন',
                hint: 'পাসওয়ার্ড আবার দিন',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'বাতিল',
              style: AppTextStyles.hindSiliguri(
                fontSize: 14,
                color: AppColors.gold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_validatePasswordChange()) {
                await notifier.changePassword(
                  currentPassword: _currentPasswordController.text,
                  newPassword: _newPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তিত হয়েছে'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: Text(
              'সংরক্ষণ করুন',
              style: AppTextStyles.hindSiliguri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: AppTextStyles.hindSiliguri(
        fontSize: 14,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.hindSiliguri(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.hindSiliguri(
          fontSize: 12,
          color: Colors.white24,
        ),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gold, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        fillColor: AppColors.background.withValues(alpha: 0.5),
        filled: true,
      ),
    );
  }

  bool _validatePasswordChange() {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty) {
      _showPasswordError('বর্তমান পাসওয়ার্ড দিন।');
      return false;
    }

    if (newPass.isEmpty) {
      _showPasswordError('নতুন পাসওয়ার্ড দিন।');
      return false;
    }

    if (newPass.length < 6) {
      _showPasswordError('পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।');
      return false;
    }

    if (newPass != confirm) {
      _showPasswordError('পাসওয়ার্ড মিলছে না।');
      return false;
    }

    if (current == newPass) {
      _showPasswordError('নতুন পাসওয়ার্ড আগেরটির মতো হতে পারে না।');
      return false;
    }

    return true;
  }

  void _showPasswordError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildDangerZone(
    BuildContext context,
    AuthNotifier authNotifier,
    ProfileNotifier profileNotifier,
  ) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'বিপদজনক অঞ্চল',
              style: AppTextStyles.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'একবার অ্যাকাউন্ট ডিলিট করলে তা পুনরুদ্ধার করা যাবে না।',
              style: AppTextStyles.hindSiliguri(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            GoldenButton(
              text: 'অ্যাকাউন্ট ডিলিট করুন',
              onPressed: () =>
                  _showDeleteConfirmation(context, authNotifier, profileNotifier),
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AuthNotifier authNotifier,
    ProfileNotifier profileNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'অ্যাকাউন্ট ডিলিট?',
          style: AppTextStyles.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্ট ডিলিট করতে চান? এই কাজটি অপরিবর্তনীয়।',
          style: AppTextStyles.hindSiliguri(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'বাতিল',
              style: AppTextStyles.hindSiliguri(
                fontSize: 14,
                color: AppColors.gold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await profileNotifier.deleteAccount();
              await authNotifier.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              'ডিলিট',
              style: AppTextStyles.hindSiliguri(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
