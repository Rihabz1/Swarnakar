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
import 'package:swarnakar/features/calculator/providers/calculator_provider.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  late TextEditingController _weightController;
  late TextEditingController _rateController;
  late TextEditingController _laborController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _rateController = TextEditingController();
    _laborController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    _laborController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(calculatorResultProvider);

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
          AppStrings.calculatorTitle,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            child: Column(
            children: [
              _buildUnitDropdown(ref),
              const SizedBox(height: 12),
              GoldenInputField(
                hint: AppStrings.enterQuantity,
                icon: Icons.scale_outlined,
                keyboardType: TextInputType.number,
                controller: _weightController,
              ),
              const SizedBox(height: 12),
              GoldenInputField(
                hint: AppStrings.marketRatePerBhori,
                icon: Icons.currency_exchange,
                keyboardType: TextInputType.number,
                controller: _rateController,
              ),
              const SizedBox(height: 12),
              GoldenInputField(
                hint: AppStrings.laborCharge,
                icon: Icons.build_outlined,
                keyboardType: TextInputType.number,
                controller: _laborController,
              ),
              const SizedBox(height: 20),
              GoldenButton(
                text: AppStrings.calculate,
                onPressed: () {
                  final weight = double.tryParse(_weightController.text) ?? 0;
                  final rate = double.tryParse(_rateController.text) ?? 0;
                  final labor = double.tryParse(_laborController.text) ?? 0;

                  ref.read(calculatorWeightProvider.notifier).state = weight;
                  ref.read(calculatorRateProvider.notifier).state = rate;
                  ref.read(calculatorLaborProvider.notifier).state = labor;

                  // Providers will auto-calculate based on watched values
                },
              ),
              const SizedBox(height: 20),
              if (result != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildResultCard(result),
                ),
            ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/calculator'),
        onTap: (index) {},
      ),
    );
  }

  Widget _buildUnitDropdown(WidgetRef ref) {
    final unit = ref.watch(calculatorUnitProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: unit,
            onChanged: (newUnit) {
              if (newUnit != null) {
                ref.read(calculatorUnitProvider.notifier).state = newUnit;
              }
            },
            items: [AppStrings.byGram, AppStrings.byBhori, AppStrings.byAna]
                .map((u) => DropdownMenuItem(
                      value: u,
                      child: Text(
                        u,
                        style: AppTextStyles.hindSiliguri(
                          fontSize: 12,
                          color: AppColors.gold,
                        ),
                      ),
                    ))
                .toList(),
            icon: const Icon(
              Icons.expand_more,
              color: AppColors.gold,
              size: 18,
            ),
            isExpanded: true,
            dropdownColor: AppColors.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, double> result) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildResultRow(
            AppStrings.metalValue,
            CurrencyFormatter.formatBDT(result['metalValue'] ?? 0),
          ),
          const SizedBox(height: 8),
          _buildResultRow(
            AppStrings.labor,
            CurrencyFormatter.formatBDT(result['labor'] ?? 0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: AppColors.gold.withValues(alpha: 0.15),
            ),
          ),
          _buildResultRow(
            AppStrings.totalPrice,
            CurrencyFormatter.formatBDT(result['totalValue'] ?? 0),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false}) {
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
            fontSize: isBold ? 20 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}
