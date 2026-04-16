import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/features/auth/providers/auth_provider.dart';

final profileDocProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  return ref.watch(firebaseServiceProvider).getUserData(uid);
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _resolveName({
    required User? firebaseUser,
    required Map<String, dynamic>? profileDoc,
    required String? providerName,
  }) {
    final fromProvider = providerName?.trim() ?? '';
    if (fromProvider.isNotEmpty) {
      return fromProvider;
    }

    final fromFirestore = (profileDoc?['name'] as String?)?.trim() ?? '';
    if (fromFirestore.isNotEmpty) {
      return fromFirestore;
    }

    final fromFirebase = firebaseUser?.displayName?.trim() ?? '';
    if (fromFirebase.isNotEmpty) {
      return fromFirebase;
    }

    return 'Guest User';
  }

  String _resolveEmail({
    required User? firebaseUser,
    required Map<String, dynamic>? profileDoc,
    required String? providerEmail,
  }) {
    final fromProvider = providerEmail?.trim() ?? '';
    if (fromProvider.isNotEmpty) {
      return fromProvider;
    }

    final fromFirestore = (profileDoc?['email'] as String?)?.trim() ?? '';
    if (fromFirestore.isNotEmpty) {
      return fromFirestore;
    }

    final fromFirebase = firebaseUser?.email?.trim() ?? '';
    if (fromFirebase.isNotEmpty) {
      return fromFirebase;
    }

    return 'No email';
  }

  String _initials(String name, String email) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && trimmed != 'Guest User') {
      final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.length == 1) {
        return parts.first.substring(0, 1).toUpperCase();
      }
      final first = parts.first.substring(0, 1);
      final second = parts[1].substring(0, 1);
      return '$first$second'.toUpperCase();
    }
    if (email.isNotEmpty && email != 'No email') {
      return email.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;
    final profileDocAsync = firebaseUser == null
        ? const AsyncValue<Map<String, dynamic>?>.data(null)
        : ref.watch(profileDocProvider(firebaseUser.uid));

    final profileDoc = profileDocAsync.valueOrNull;
    final name = _resolveName(
      firebaseUser: firebaseUser,
      profileDoc: profileDoc,
      providerName: authState.user?.name,
    );
    final email = _resolveEmail(
      firebaseUser: firebaseUser,
      profileDoc: profileDoc,
      providerEmail: authState.user?.email,
    );
    final photoUrl = firebaseUser?.photoURL;
    final isSubscribed =
        authState.user?.isSubscribed ?? (profileDoc?['isSubscribed'] as bool?) ?? false;

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
              child: Container(
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
                      child: ClipOval(
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      _initials(name, email),
                                      style: AppTextStyles.hindSiliguri(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  _initials(name, email),
                                  style: AppTextStyles.hindSiliguri(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gold,
                                  ),
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
                            name,
                            style: AppTextStyles.hindSiliguri(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            email,
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
                    Container(
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
                  ],
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
                showBadge: isSubscribed,
              ),
            ]),
            // Settings Group 2
            _buildSettingsGroup([
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
                      ref.read(authProvider.notifier).signOut().then((_) {
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

  Widget _buildSettingsRow(String label, IconData icon, {bool showBadge = false}) {
    return Padding(
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
    );
  }
}
