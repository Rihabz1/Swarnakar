import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/features/converter/domain/weight_converter.dart';

void main() {
  group('convertWeight', () {
    final conversionCases = <({
      String description,
      double value,
      String from,
      String to,
      double expected,
    })>[
      (
        description: 'grams to bhori',
        value: 11.664,
        from: AppStrings.gramUnit,
        to: AppStrings.bhoriUnit,
        expected: 1,
      ),
      (
        description: 'bhori to grams',
        value: 1,
        from: AppStrings.bhoriUnit,
        to: AppStrings.gramUnit,
        expected: 11.664,
      ),
      (
        description: 'grams to troy ounces',
        value: 31.1035,
        from: AppStrings.gramUnit,
        to: AppStrings.ounceUnit,
        expected: 1,
      ),
      (
        description: 'troy ounces to grams',
        value: 1,
        from: AppStrings.ounceUnit,
        to: AppStrings.gramUnit,
        expected: 31.1035,
      ),
      (
        description: 'bhori to troy ounces',
        value: 1,
        from: AppStrings.bhoriUnit,
        to: AppStrings.ounceUnit,
        expected: gramsPerBhori / gramsPerTroyOunce,
      ),
      (
        description: 'troy ounces to bhori',
        value: 1,
        from: AppStrings.ounceUnit,
        to: AppStrings.bhoriUnit,
        expected: gramsPerTroyOunce / gramsPerBhori,
      ),
    ];

    for (final testCase in conversionCases) {
      test(testCase.description, () {
        final result = convertWeight(
          value: testCase.value,
          fromUnit: testCase.from,
          toUnit: testCase.to,
        );

        expect(result, closeTo(testCase.expected, 0.0000001));
      });
    }

    for (final unit in [
      AppStrings.gramUnit,
      AppStrings.bhoriUnit,
      AppStrings.ounceUnit,
    ]) {
      test('preserves a value when converting $unit to itself', () {
        final result = convertWeight(
          value: 123.456,
          fromUnit: unit,
          toUnit: unit,
        );

        expect(result, closeTo(123.456, 0.0000001));
      });
    }

    test('preserves zero across different units', () {
      final result = convertWeight(
        value: 0,
        fromUnit: AppStrings.bhoriUnit,
        toUnit: AppStrings.ounceUnit,
      );

      expect(result, 0);
    });

    test('supports small decimal quantities without losing precision', () {
      final result = convertWeight(
        value: 0.001,
        fromUnit: AppStrings.bhoriUnit,
        toUnit: AppStrings.gramUnit,
      );

      expect(result, closeTo(0.011664, 0.000000001));
    });

    test('a round trip returns the original quantity', () {
      const original = 7.375;
      final ounces = convertWeight(
        value: original,
        fromUnit: AppStrings.bhoriUnit,
        toUnit: AppStrings.ounceUnit,
      );
      final result = convertWeight(
        value: ounces,
        fromUnit: AppStrings.ounceUnit,
        toUnit: AppStrings.bhoriUnit,
      );

      expect(result, closeTo(original, 0.0000001));
    });

    test('rejects an unsupported source unit', () {
      expect(
        () => convertWeight(
          value: 1,
          fromUnit: 'kilogram',
          toUnit: AppStrings.gramUnit,
        ),
        throwsArgumentError,
      );
    });

    test('rejects an unsupported destination unit', () {
      expect(
        () => convertWeight(
          value: 1,
          fromUnit: AppStrings.gramUnit,
          toUnit: 'kilogram',
        ),
        throwsArgumentError,
      );
    });
  });
}
