import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/utils/currency_formatter.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';
import 'package:swarnakar/shared/widgets/golden_button.dart';
import 'package:swarnakar/features/zakat/providers/zakat_provider.dart';

class ZakatScreen extends ConsumerStatefulWidget {
  const ZakatScreen({super.key});

  @override
  ConsumerState<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends ConsumerState<ZakatScreen> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(zakatResultProvider);

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
          AppStrings.zakatTitle,
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          child: Column(
            children: [
              _buildNisabReferenceCard(),
              const SizedBox(height: 20),
              GoldenInputField(
                hint: AppStrings.totalGoldGrams,
                icon: Icons.diamond_outlined,
                keyboardType: TextInputType.number,
                controller: controllers[0],
              ),
              const SizedBox(height: 12),
              GoldenInputField(
                hint: AppStrings.totalSilverGrams,
                icon: Icons.circle_outlined,
                keyboardType: TextInputType.number,
                controller: controllers[1],
              ),
              const SizedBox(height: 12),
              GoldenInputField(
                hint: AppStrings.cashAndSavings,
                icon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
                controller: controllers[2],
              ),
              const SizedBox(height: 12),
              GoldenInputField(
                hint: AppStrings.businessGoodsValue,
                icon: Icons.store_outlined,
                keyboardType: TextInputType.number,
                controller: controllers[3],
              ),
              const SizedBox(height: 12),
              GoldenInputField(
                hint: AppStrings.receivableAmount,
                icon: Icons.arrow_forward_outlined,
                keyboardType: TextInputType.number,
                controller: controllers[4],
              ),
              const SizedBox(height: 12),
              GoldenInputField(
                hint: AppStrings.deductLoans,
                icon: Icons.remove_circle_outline,
                keyboardType: TextInputType.number,
                controller: controllers[5],
              ),
              const SizedBox(height: 20),
              GoldenButton(
                text: AppStrings.calculateZakat,
                onPressed: () {
                  final goldGrams = double.tryParse(controllers[0].text) ?? 0;
                  final silverGrams = double.tryParse(controllers[1].text) ?? 0;
                  final cash = double.tryParse(controllers[2].text) ?? 0;
                  final bizGoods = double.tryParse(controllers[3].text) ?? 0;
                  final receivable = double.tryParse(controllers[4].text) ?? 0;
                  final debts = double.tryParse(controllers[5].text) ?? 0;

                  ref.read(zakatGoldGramsProvider.notifier).state = goldGrams;
                  ref.read(zakatSilverGramsProvider.notifier).state = silverGrams;
                  ref.read(zakatCashProvider.notifier).state = cash;
                  ref.read(zakatBizGoodsProvider.notifier).state = bizGoods;
                  ref.read(zakatReceivableProvider.notifier).state = receivable;
                  ref.read(zakatDebtsProvider.notifier).state = debts;

                  // Providers will auto-calculate based on watched values
                },
              ),
              const SizedBox(height: 20),
              if (result != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildResultCard(result),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/zakat'),
        onTap: (index) {},
      ),
    );
  }

  Widget _buildNisabReferenceCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.nisabLimit,
            style: AppTextStyles.hindSiliguri(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.goldNisab,
            style: AppTextStyles.hindSiliguri(
              fontSize: 10,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.silverNisab,
            style: AppTextStyles.hindSiliguri(
              fontSize: 10,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildResultRow(
            AppStrings.zakatableAssets,
            CurrencyFormatter.formatBDT(result['totalAssets'] ?? 0),
          ),
          const SizedBox(height: 12),
          _buildResultRow(
            AppStrings.nisabStatus,
            result['isEligible'] == true ? AppStrings.zakatEligible : AppStrings.nisabNotMet,
            valueColor: result['isEligible'] == true ? AppColors.success : AppColors.error,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: AppColors.gold.withOpacity(0.15),
            ),
          ),
          _buildResultRow(
            AppStrings.zakatAmount,
            CurrencyFormatter.formatBDT(result['zakatAmount'] ?? 0),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.hindSiliguri(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.hindSiliguri(
            fontSize: isBold ? 18 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? AppColors.gold,
          ),
        ),
      ],
    );
  }
}
