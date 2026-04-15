import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/shared/models/price_model.dart';
import 'package:swarnakar/features/silver_price/data/silver_price_mock.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

final silverPricesProvider = Provider<List<PriceModel>>((ref) {
  return mockSilverPrices;
});

final silverPricesBySection = Provider<Map<String, List<PriceModel>>>((ref) {
  final prices = ref.watch(silverPricesProvider);
  return {
    AppStrings.newSilver: prices.where((p) => !p.label.contains('চাঁদি') && !p.label.contains('এসিড')).toList(),
    AppStrings.silverAndAcidKaim: prices.where((p) => p.label.contains('চাঁদি') || p.label.contains('এসিড')).toList(),
  };
});
