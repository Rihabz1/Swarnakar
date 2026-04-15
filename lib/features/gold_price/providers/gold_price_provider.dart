import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/shared/models/price_model.dart';
import 'package:swarnakar/features/gold_price/data/gold_price_mock.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

final goldPricesProvider = Provider<List<PriceModel>>((ref) {
  return mockGoldPrices;
});

final goldPricesBySection = Provider<Map<String, List<PriceModel>>>((ref) {
  final prices = ref.watch(goldPricesProvider);
  return {
    AppStrings.currentDhakaPrices: prices.where((p) => !p.label.contains('পুরাতন') && !p.label.contains('পাকা') && !p.label.contains('টুকরা')).toList(),
    AppStrings.oldGoldPrices: prices.where((p) => p.label.contains('পুরাতন')).toList(),
    AppStrings.pureFineGold: prices.where((p) => p.label.contains('পাকা') || p.label.contains('টুকরা')).toList(),
  };
});
