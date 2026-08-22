import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/mappers/price_mapper.dart';

void main() {
  group('parsePriceValue', () {
    test('parses integer, double, and numeric string values', () {
      expect(parsePriceValue(100), 100);
      expect(parsePriceValue(100.5), 100.5);
      expect(parsePriceValue(' 100.75 '), 100.75);
    });

    test('returns null for null, empty, and non-numeric values', () {
      expect(parsePriceValue(null), isNull);
      expect(parsePriceValue(''), isNull);
      expect(parsePriceValue('not-a-price'), isNull);
    });
  });

  group('parsePriceUpdatedAt', () {
    test('converts a Firestore Timestamp to ISO-8601', () {
      final date = DateTime.utc(2026, 4, 14, 9, 30);
      expect(parsePriceUpdatedAt(Timestamp.fromDate(date)),
          date.toIso8601String());
    });

    test('converts DateTime and preserves string values', () {
      final date = DateTime.utc(2026, 4, 14);
      expect(parsePriceUpdatedAt(date), date.toIso8601String());
      expect(parsePriceUpdatedAt('today'), 'today');
      expect(parsePriceUpdatedAt(null), isEmpty);
    });
  });

  group('mapGoldPrices', () {
    test('maps all known fields in stable display order', () {
      final prices = mapGoldPrices({
        'gold_22k': 1,
        'gold_21k': '2',
        'gold_22k_old': 3.0,
        'gold_21k_old': 4,
        'gold_paka': 5,
        'gold_tukra': 6,
        'updatedAt': '2026-04-14',
      });

      expect(prices.map((price) => price.label), [
        AppStrings.karat22,
        AppStrings.karat21,
        AppStrings.oldKarat22,
        AppStrings.oldKarat21,
        AppStrings.pureAcid,
        AppStrings.pieceGold,
      ]);
      expect(prices.map((price) => price.price), [1, 2, 3, 4, 5, 6]);
      expect(
          prices.every((price) => price.unit == AppStrings.perBhori), isTrue);
      expect(prices.every((price) => price.updatedAt == '2026-04-14'), isTrue);
    });

    test('omits missing and invalid values and handles null data', () {
      expect(mapGoldPrices(null), isEmpty);
      final prices = mapGoldPrices({
        'gold_22k': 100,
        'gold_21k': 'invalid',
        'gold_paka': null,
      });
      expect(prices, hasLength(1));
      expect(prices.single.label, AppStrings.karat22);
    });
  });

  group('mapSilverPrices and grouping', () {
    test('maps and groups regular and acid/chandi values', () {
      final prices = mapSilverPrices({
        'silver_22k': 1,
        'silver_21k': 2,
        'silver_chandi': 3,
        'silver_acid_kaim': 4,
      });
      final groups = groupSilverPrices(prices);

      expect(groups[AppStrings.newSilver], hasLength(2));
      expect(groups[AppStrings.silverAndAcidKaim], hasLength(2));
      expect(
        groups[AppStrings.silverAndAcidKaim]!.map((price) => price.label),
        [AppStrings.silverRopya, AppStrings.acidKaim],
      );
    });
  });

  test('groupGoldPrices places every price into its expected section', () {
    final groups = groupGoldPrices(mapGoldPrices({
      'gold_22k': 1,
      'gold_21k': 2,
      'gold_22k_old': 3,
      'gold_21k_old': 4,
      'gold_paka': 5,
      'gold_tukra': 6,
    }));

    expect(groups[AppStrings.currentDhakaPrices], hasLength(2));
    expect(groups[AppStrings.oldGoldPrices], hasLength(2));
    expect(groups[AppStrings.pureFineGold], hasLength(2));
  });
}
