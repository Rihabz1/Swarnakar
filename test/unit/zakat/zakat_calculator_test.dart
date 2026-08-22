import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/features/zakat/domain/zakat_calculator.dart';

void main() {
  ZakatCalculation calculateCash({
    required double cash,
    double debts = 0,
    double silverNisab = defaultSilverNisabBdt,
  }) {
    return calculateZakat(
      goldGrams: 0,
      silverGrams: 0,
      cash: cash,
      businessGoods: 0,
      receivable: 0,
      debts: debts,
      silverNisabBdt: silverNisab,
    );
  }

  group('calculateZakat eligibility boundaries', () {
    test('is not eligible one taka below the silver nisab', () {
      final result = calculateCash(cash: defaultSilverNisabBdt - 1);

      expect(result.isEligible, isFalse);
      expect(result.zakatAmount, 0);
      expect(result.nisabLimit, defaultSilverNisabBdt);
    });

    test('is eligible exactly at the silver nisab', () {
      final result = calculateCash(cash: defaultSilverNisabBdt);

      expect(result.isEligible, isTrue);
      expect(result.zakatAmount, closeTo(1321.5, 0.000001));
    });

    test('is eligible one taka above the silver nisab', () {
      final result = calculateCash(cash: defaultSilverNisabBdt + 1);

      expect(result.isEligible, isTrue);
      expect(
        result.zakatAmount,
        closeTo((defaultSilverNisabBdt + 1) * zakatRate, 0.000001),
      );
    });

    test('zero assets are not eligible', () {
      final result = calculateCash(cash: 0);

      expect(result.totalAssets, 0);
      expect(result.isEligible, isFalse);
      expect(result.zakatAmount, 0);
    });
  });

  group('calculateZakat asset composition', () {
    test('gold-only assets use the gold nisab', () {
      final result = calculateZakat(
        goldGrams: 1,
        silverGrams: 0,
        cash: 0,
        businessGoods: 0,
        receivable: 0,
        debts: 0,
      );

      expect(result.nisabLimit, defaultGoldNisabBdt);
    });

    test('gold plus cash uses the silver nisab', () {
      final result = calculateZakat(
        goldGrams: 1,
        silverGrams: 0,
        cash: 1,
        businessGoods: 0,
        receivable: 0,
        debts: 0,
      );

      expect(result.nisabLimit, defaultSilverNisabBdt);
    });

    test('includes every asset category and subtracts debts', () {
      final result = calculateZakat(
        goldGrams: gramsPerBhoriForZakat,
        silverGrams: 100,
        cash: 10000,
        businessGoods: 20000,
        receivable: 30000,
        debts: 5000,
      );

      const expected = defaultGoldRatePerBhori +
          (100 * defaultSilverRatePerGram) +
          10000 +
          20000 +
          30000 -
          5000;
      expect(result.totalAssets, closeTo(expected, 0.000001));
      expect(result.zakatAmount, closeTo(expected * zakatRate, 0.000001));
    });

    test('debts can reduce assets below the nisab', () {
      final result = calculateCash(cash: 60000, debts: 10000);

      expect(result.totalAssets, 50000);
      expect(result.isEligible, isFalse);
      expect(result.zakatAmount, 0);
    });

    test('supports custom market rates and nisab values', () {
      final result = calculateZakat(
        goldGrams: gramsPerBhoriForZakat,
        silverGrams: 10,
        cash: 0,
        businessGoods: 0,
        receivable: 0,
        debts: 0,
        goldNisabBdt: 1000000,
        silverNisabBdt: 100000,
        goldRatePerBhori: 300000,
        silverRatePerGram: 100,
      );

      expect(result.totalAssets, 301000);
      expect(result.nisabLimit, 100000);
      expect(result.isEligible, isTrue);
      expect(result.zakatAmount, 7525);
    });
  });

  group('ZakatCalculation', () {
    test('serializes to the map shape consumed by the current UI', () {
      const result = ZakatCalculation(
        totalAssets: 100000,
        isEligible: true,
        zakatAmount: 2500,
        nisabLimit: 52860,
      );

      expect(result.toMap(), {
        'totalAssets': 100000.0,
        'isEligible': true,
        'zakatAmount': 2500.0,
        'nisabLimit': 52860.0,
      });
    });
  });
}
