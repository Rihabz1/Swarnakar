import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/features/reports/providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(activeReportFilterProvider);
    final reports = ref.watch(filteredReportsProvider);

    final filterTags = [
      AppStrings.all,
      AppStrings.gold,
      AppStrings.silver,
      AppStrings.zakat,
    ];

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
          AppStrings.reportsTitle,
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: filterTags.map((tag) {
                  final isActive = filter == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(activeReportFilterProvider.notifier).state = tag;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.gold.withOpacity(0.12) : Colors.transparent,
                          border: Border.all(
                            color: isActive ? AppColors.gold.withOpacity(0.4) : AppColors.gold.withOpacity(0.2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.hindSiliguri(
                            fontSize: 9.5,
                            color: isActive ? AppColors.gold : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        left: BorderSide(
                          color: AppColors.gold,
                          width: 3,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.type,
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 9,
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                report.item,
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                report.date,
                                style: AppTextStyles.hindSiliguri(
                                  fontSize: 9,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          report.value,
                          style: AppTextStyles.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/reports'),
        onTap: (index) {},
      ),
    );
  }
}
