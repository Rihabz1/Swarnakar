import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/features/gold_price/providers/gold_price_provider.dart';
import 'package:swarnakar/features/silver_price/providers/silver_price_provider.dart';

// Dashboard stats
final dashboardGoldPriceProvider = Provider<AsyncValue<double>>((ref) {
  final pricesAsync = ref.watch(goldPricesProvider);
  return pricesAsync.whenData((prices) => prices.isNotEmpty ? prices.first.price : 0);
});

final dashboardSilverPriceProvider = Provider<AsyncValue<double>>((ref) {
  final pricesAsync = ref.watch(silverPricesProvider);
  return pricesAsync.whenData((prices) => prices.isNotEmpty ? prices.first.price : 0);
});
