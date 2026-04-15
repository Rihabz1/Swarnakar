import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/core/providers/core_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(isSubscribedProvider);

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
          AppStrings.settingsTitle,
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Card
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'R',
                          style: AppTextStyles.hindSiliguri(
                            fontSize: 16,
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
                            'Md. Abdur Rahim',
                            style: AppTextStyles.hindSiliguri(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            'rahim@example.com',
                            style: AppTextStyles.hindSiliguri(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isSubscribed)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.1),
                                border: Border.all(
                                  color: AppColors.gold.withOpacity(0.3),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppStrings.premiumMember,
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 8.5,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.gold,
                        size: 14,
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
                    color: AppColors.error.withOpacity(0.25),
                    width: 1,
                  ),
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.go('/login');
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.04),
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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.15),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.hindSiliguri(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (showBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'প্রিমিয়াম',
                style: AppTextStyles.hindSiliguri(
                  fontSize: 8,
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
