import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/features/gold_price/data/gold_price_mock.dart';
import 'package:swarnakar/features/silver_price/data/silver_price_mock.dart';

// Dashboard stats
final dashboardGoldPriceProvider = Provider<double>((ref) {
  return mockGoldPrices.isNotEmpty ? mockGoldPrices[0].price : 0;
});

final dashboardSilverPriceProvider = Provider<double>((ref) {
  return mockSilverPrices.isNotEmpty ? mockSilverPrices[0].price : 0;
});
