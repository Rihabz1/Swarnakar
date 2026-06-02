import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/core/providers/core_providers.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'package:swarnakar/features/auth/data/firebase_auth_service.dart';
import 'package:swarnakar/shared/models/user_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _displayContact(UserModel user) {
    return user.phone.isEmpty ? 'মোবাইল নম্বর যোগ করুন' : user.phone;
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, UserModel profile) {
    final nameController = TextEditingController(text: profile.name);
    final shopController = TextEditingController(text: profile.shopName);
    final addressController = TextEditingController(text: profile.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> handleSave() async {
              final name = nameController.text.trim();
              final shopName = shopController.text.trim();
              final address = addressController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('নাম দিন।')));
                return;
              }

              setSheetState(() => isSaving = true);
              try {
                await FirebaseAuthService.instance.updateUserProfile(
                  name: name,
                  shopName: shopName,
                  address: address,
                );
                ref.invalidate(userProfileProvider);
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              } catch (e) {
                final message = e is AuthException
                    ? (e.message ?? 'প্রোফাইল আপডেট ব্যর্থ হয়েছে।')
                    : 'প্রোফাইল আপডেট ব্যর্থ হয়েছে।';
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
                setSheetState(() => isSaving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'প্রোফাইল এডিট',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GoldenInputField(
                        hint: 'নাম',
                        icon: Icons.person_outline,
                        controller: nameController,
                      ),
                      const SizedBox(height: 12),
                      GoldenInputField(
                        hint: 'দোকানের নাম',
                        icon: Icons.storefront_outlined,
                        controller: shopController,
                      ),
                      const SizedBox(height: 12),
                      GoldenInputField(
                        hint: 'ঠিকানা',
                        icon: Icons.location_on_outlined,
                        controller: addressController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 18),
                      GoldenButton(
                        text: 'সংরক্ষণ করুন',
                        isLoading: isSaving,
                        onPressed: handleSave,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      shopController.dispose();
      addressController.dispose();
    });
  }

  void _showChangePasswordSheet(BuildContext context, UserModel profile) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> handleSave() async {
              final current = currentController.text;
              final next = newController.text;
              final confirm = confirmController.text;
              final whitespaceRegex = RegExp(r'\s');

              if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('সবগুলো তথ্য দিন।')));
                return;
              }
              if (whitespaceRegex.hasMatch(current) || whitespaceRegex.hasMatch(next)) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('পাসওয়ার্ডে স্পেস ব্যবহার করা যাবে না।')));
                return;
              }
              if (next.length < 8) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।')));
                return;
              }
              if (next != confirm) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('পাসওয়ার্ড মিলছে না।')));
                return;
              }

              setSheetState(() => isSaving = true);
              try {
                await FirebaseAuthService.instance.changePasswordForCurrentUser(
                  currentPassword: current,
                  newPassword: next,
                  phone: profile.phone,
                );
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('পাসওয়ার্ড আপডেট হয়েছে।')));
              } catch (e) {
                final message = e is AuthException
                    ? (e.message ?? 'পাসওয়ার্ড আপডেট ব্যর্থ হয়েছে।')
                    : 'পাসওয়ার্ড আপডেট ব্যর্থ হয়েছে।';
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
                setSheetState(() => isSaving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'পাসওয়ার্ড পরিবর্তন করুন',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GoldenInputField(
                        hint: 'বর্তমান পাসওয়ার্ড',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: currentController,
                      ),
                      const SizedBox(height: 12),
                      GoldenInputField(
                        hint: 'নতুন পাসওয়ার্ড',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: newController,
                      ),
                      const SizedBox(height: 12),
                      GoldenInputField(
                        hint: 'পাসওয়ার্ড নিশ্চিত করুন',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: confirmController,
                      ),
                      const SizedBox(height: 18),
                      GoldenButton(
                        text: 'আপডেট করুন',
                        isLoading: isSaving,
                        onPressed: handleSave,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      currentController.dispose();
      newController.dispose();
      confirmController.dispose();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final fallbackSubscribed = ref.watch(isSubscribedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.gold,
            size: 18,
          ),
        ),
        title: Text(
          AppStrings.settingsTitle,
          style: AppTextStyles.hindSiliguri(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Profile Card
            Padding(
              padding: const EdgeInsets.all(14),
              child: profileAsync.when(
                data: (profile) {
                  final user = profile ?? UserModel(
                    uid: '',
                    name: 'ব্যবহারকারী',
                    email: '',
                    phone: '',
                    shopName: '',
                    address: '',
                    isSubscribed: false,
                    plan: '',
                    subExpires: null,
                  );
                  final isSubscribed = profile?.isSubscribed ?? fallbackSubscribed;
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.getInitials(),
                              style: AppTextStyles.hindSiliguri(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name.isEmpty ? 'ব্যবহারকারী' : user.name,
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                _displayContact(user),
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (isSubscribed)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    AppStrings.premiumMember,
                                    style: AppTextStyles.hindSiliguri(
                                      fontSize: 9,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: profile == null
                              ? null
                              : () => _showEditProfileSheet(context, ref, profile),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.gold,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'লোড হচ্ছে...',
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (_, __) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'প্রোফাইল লোড করা যায়নি',
                    style: AppTextStyles.hindSiliguri(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            // Settings Group 1
            _buildSettingsGroup([
              _buildSettingsRow(AppStrings.notifications, Icons.notifications_none),
              _buildSettingsRow(AppStrings.language, Icons.language),
              _buildSettingsRow(
                AppStrings.subscription,
                Icons.workspace_premium,
                showBadge: fallbackSubscribed,
              ),
            ]),
            // Settings Group 2
            _buildSettingsGroup([
              _buildSettingsRow('পাসওয়ার্ড পরিবর্তন করুন', Icons.lock_outline, onTap: () {
                profileAsync.whenData((profile) {
                  if (profile == null) return;
                  _showChangePasswordSheet(context, profile);
                });
              }),
              _buildSettingsRow(AppStrings.privacyPolicy, Icons.privacy_tip_outlined),
              _buildSettingsRow(AppStrings.termsOfService, Icons.description_outlined),
              _buildSettingsRow(AppStrings.about, Icons.info_outlined),
            ]),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      FirebaseAuthService.instance.clearSession().then((_) {
                        if (context.mounted) {
                          context.go('/login');
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          AppStrings.logout,
                          style: AppTextStyles.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/settings'),
        onTap: (index) {},
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    String label,
    IconData icon, {
    bool showBadge = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.gold,
                size: 15,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.hindSiliguri(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (showBadge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'প্রিমিয়াম',
                  style: AppTextStyles.hindSiliguri(
                    fontSize: 9,
                    color: AppColors.gold,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
