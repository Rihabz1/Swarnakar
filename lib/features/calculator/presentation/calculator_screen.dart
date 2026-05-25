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
import 'package:swarnakar/features/gold_price/providers/gold_price_provider.dart';
import 'package:swarnakar/features/silver_price/providers/silver_price_provider.dart';
import 'package:swarnakar/shared/models/price_model.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  late TextEditingController _weightController;
  late TextEditingController _laborController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _laborController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _laborController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(calculatorResultProvider);
    final goldPricesAsync = ref.watch(goldPricesProvider);
    final silverPricesAsync = ref.watch(silverPricesProvider);
    final rateOptions = _buildRateOptions(goldPricesAsync, silverPricesAsync);
    final selectedRateOption = ref.watch(calculatorRateOptionProvider);

    _ensureRateSelection(rateOptions, selectedRateOption);

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
              _buildRateDropdown(ref, rateOptions, selectedRateOption),
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
                  final unit = ref.read(calculatorUnitProvider);
                  final weight = double.tryParse(_weightController.text) ?? 0;
                  final rate = ref.read(calculatorRateProvider);
                  final labor = double.tryParse(_laborController.text) ?? 0;

                  ref.read(calculatorWeightProvider.notifier).state = weight;
                  ref.read(calculatorLaborProvider.notifier).state = labor;

                  final result = computeCalculatorResult(
                    unit: unit,
                    weight: weight,
                    rate: rate,
                    labor: labor,
                  );
                  ref.read(calculatorResultProvider.notifier).state = result;

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

  void _ensureRateSelection(
    List<CalculatorRateOption> options,
    CalculatorRateOption? selected,
  ) {
    if (options.isEmpty) {
      return;
    }
    if (selected != null && options.contains(selected)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final option = options.first;
      ref.read(calculatorRateOptionProvider.notifier).state = option;
      ref.read(calculatorRateProvider.notifier).state = option.ratePerBhori;
    });
  }

  Widget _buildRateDropdown(
    WidgetRef ref,
    List<CalculatorRateOption> options,
    CalculatorRateOption? selected,
  ) {
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
          child: DropdownButton<CalculatorRateOption>(
            value: selected != null && options.contains(selected) ? selected : null,
            hint: Text(
              AppStrings.marketRatePerBhori,
              style: AppTextStyles.hindSiliguri(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: options.isEmpty
                ? null
                : (option) {
                    if (option == null) return;
                    ref.read(calculatorRateOptionProvider.notifier).state = option;
                    ref.read(calculatorRateProvider.notifier).state = option.ratePerBhori;
                  },
            items: options
                .map((option) => DropdownMenuItem(
                      value: option,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              option.label,
                              style: AppTextStyles.hindSiliguri(
                                fontSize: 12,
                                color: AppColors.gold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.formatBDT(option.price),
                            style: AppTextStyles.hindSiliguri(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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

  List<CalculatorRateOption> _buildRateOptions(
    AsyncValue<List<PriceModel>> goldPricesAsync,
    AsyncValue<List<PriceModel>> silverPricesAsync,
  ) {
    final goldPrices = goldPricesAsync.maybeWhen(
      data: (prices) => prices,
      orElse: () => const <PriceModel>[],
    );
    final silverPrices = silverPricesAsync.maybeWhen(
      data: (prices) => prices,
      orElse: () => const <PriceModel>[],
    );

    final options = <CalculatorRateOption>[];
    for (final price in goldPrices) {
      options.add(
        CalculatorRateOption(
          id: 'gold:${price.label}',
          label: '${AppStrings.gold} • ${price.label}',
          price: price.price,
          unit: price.unit,
        ),
      );
    }
    for (final price in silverPrices) {
      options.add(
        CalculatorRateOption(
          id: 'silver:${price.label}',
          label: '${AppStrings.silver} • ${price.label}',
          price: price.price,
          unit: price.unit,
        ),
      );
    }

    return options;
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
