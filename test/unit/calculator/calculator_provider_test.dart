import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/features/calculator/providers/calculator_provider.dart';

void main() {
  group('computeCalculatorResult', () {
    test('returns the metal value, labour, and total for valid inputs', () {
      final result = computeCalculatorResult(
        unit: AppStrings.byGram,
        weight: 10,
        rate: 7500,
        labor: 1200,
      );

      expect(
        result,
        equals({
          'metalValue': 75000.0,
          'labor': 1200.0,
          'totalValue': 76200.0,
        }),
      );
    });

    test('supports decimal weight, rate, and labour values', () {
      final result = computeCalculatorResult(
        unit: AppStrings.byGram,
        weight: 2.5,
        rate: 8123.45,
        labor: 750.25,
      );

      expect(result, isNotNull);
      expect(result!['metalValue'], closeTo(20308.625, 0.000001));
      expect(result['labor'], closeTo(750.25, 0.000001));
      expect(result['totalValue'], closeTo(21058.875, 0.000001));
    });

    test('allows a zero labour charge', () {
      final result = computeCalculatorResult(
        unit: AppStrings.byBhori,
        weight: 2,
        rate: 248000,
        labor: 0,
      );

      expect(result, isNotNull);
      expect(result!['metalValue'], 496000);
      expect(result['labor'], 0);
      expect(result['totalValue'], 496000);
    });

    test('returns null when weight is zero', () {
      final result = computeCalculatorResult(
        unit: AppStrings.byGram,
        weight: 0,
        rate: 7500,
        labor: 500,
      );

      expect(result, isNull);
    });

    test('returns null when rate is zero', () {
      final result = computeCalculatorResult(
        unit: AppStrings.byGram,
        weight: 10,
        rate: 0,
        labor: 500,
      );

      expect(result, isNull);
    });

    test('returns null when both required numeric inputs are zero', () {
      final result = computeCalculatorResult(
        unit: AppStrings.byAna,
        weight: 0,
        rate: 0,
        labor: 500,
      );

      expect(result, isNull);
    });

    test('does not lose precision for small valid quantities', () {
      final result = computeCalculatorResult(
        unit: AppStrings.byGram,
        weight: 0.001,
        rate: 100000,
        labor: 0.01,
      );

      expect(result, isNotNull);
      expect(result!['metalValue'], closeTo(100, 0.000001));
      expect(result['totalValue'], closeTo(100.01, 0.000001));
    });

    test('handles large finite business values', () {
      final result = computeCalculatorResult(
        unit: AppStrings.byBhori,
        weight: 10000,
        rate: 1000000,
        labor: 500000,
      );

      expect(result, isNotNull);
      expect(result!['metalValue'], 10000000000);
      expect(result['totalValue'], 10000500000);
    });

    test(
      'documents that unit selection currently does not transform the formula',
      () {
        Map<String, double>? calculateFor(String unit) {
          return computeCalculatorResult(
            unit: unit,
            weight: 2,
            rate: 100,
            labor: 10,
          );
        }

        expect(calculateFor(AppStrings.byGram), calculateFor(AppStrings.byAna));
        expect(
          calculateFor(AppStrings.byAna),
          calculateFor(AppStrings.byBhori),
        );
      },
    );
  });
}
