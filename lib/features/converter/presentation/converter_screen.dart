import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/features/converter/domain/weight_converter.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'package:swarnakar/shared/widgets/golden_input_field.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late final TextEditingController _inputController;
  late final NumberFormat _numberFormat;

  String _fromUnit = AppStrings.gramUnit;
  String _toUnit = AppStrings.bhoriUnit;
  String _output = '';

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _numberFormat = NumberFormat('#,##0.###', 'bn_BD');
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final units = [
      AppStrings.gramUnit,
      AppStrings.bhoriUnit,
      AppStrings.ounceUnit,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            context.go('/dashboard');
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.gold,
            size: 18,
          ),
        ),
        title: Text(
          AppStrings.converterTitle,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          child: Column(
            children: [
              _buildUnitSelectorRow(units),
              const SizedBox(height: 12),
              GoldenInputField(
                hint: AppStrings.enterQuantity,
                icon: Icons.scale_outlined,
                keyboardType: TextInputType.number,
                controller: _inputController,
                onChanged: (_) => _recalculate(),
              ),
              const SizedBox(height: 18),
              _buildResultCard(),
              const SizedBox(height: 12),
              _buildConversionHint(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/converter'),
        onTap: (index) {},
      ),
    );
  }

  Widget _buildUnitSelectorRow(List<String> units) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildUnitColumn(
              title: AppStrings.fromUnit,
              value: _fromUnit,
              units: units,
              titleAlignment: Alignment.center,
              columnAlignment: CrossAxisAlignment.center,
              dropdownAlignment: Alignment.center,
              onChanged: (value) {
                setState(() {
                  _fromUnit = value;
                });
                _recalculate();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: _swapUnits,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: AppColors.gold,
                  size: 18,
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildUnitColumn(
              title: AppStrings.toUnit,
              value: _toUnit,
              units: units,
              titleAlignment: Alignment.center,
              columnAlignment: CrossAxisAlignment.center,
              dropdownAlignment: Alignment.center,
              onChanged: (value) {
                setState(() {
                  _toUnit = value;
                });
                _recalculate();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitColumn({
    required String title,
    required String value,
    required List<String> units,
    required AlignmentGeometry titleAlignment,
    required CrossAxisAlignment columnAlignment,
    required AlignmentGeometry dropdownAlignment,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: columnAlignment,
      children: [
        Align(
          alignment: titleAlignment,
          child: Text(
            title,
            style: AppTextStyles.hindSiliguri(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: dropdownAlignment,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: (newValue) {
                if (newValue == null) return;
                onChanged(newValue);
              },
              items: units
                  .map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(
                          unit,
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
              dropdownColor: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    final displayValue = _output.isEmpty ? '--' : _output;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.convertedValue,
            style: AppTextStyles.hindSiliguri(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$displayValue $_toUnit',
            style: AppTextStyles.hindSiliguri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionHint() {
    final bhoriToGram = _numberFormat.format(gramsPerBhori);
    final ounceToGram = _numberFormat.format(gramsPerTroyOunce);
    final bhoriToOunce =
        _numberFormat.format(gramsPerBhori / gramsPerTroyOunce);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.14),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'দ্রুত রূপান্তর',
            style: AppTextStyles.hindSiliguri(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '১ ভরি = $bhoriToGram গ্রাম',
            style: AppTextStyles.hindSiliguri(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '১ আউন্স = $ounceToGram গ্রাম',
            style: AppTextStyles.hindSiliguri(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '১ ভরি = $bhoriToOunce আউন্স',
            style: AppTextStyles.hindSiliguri(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _recalculate() {
    final value = double.tryParse(_inputController.text.trim()) ?? 0;
    if (value == 0) {
      setState(() {
        _output = '';
      });
      return;
    }

    final converted = convertWeight(
      value: value,
      fromUnit: _fromUnit,
      toUnit: _toUnit,
    );
    setState(() {
      _output = _numberFormat.format(converted);
    });
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _recalculate();
  }
}
