import 'package:flutter_riverpod/flutter_riverpod.dart';

final zakatGoldGramsProvider = StateProvider<double>((ref) => 0);
final zakatSilverGramsProvider = StateProvider<double>((ref) => 0);
final zakatCashProvider = StateProvider<double>((ref) => 0);
final zakatBizGoodsProvider = StateProvider<double>((ref) => 0);
final zakatReceivableProvider = StateProvider<double>((ref) => 0);
final zakatDebtsProvider = StateProvider<double>((ref) => 0);

final zakatResultProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final calculateZakatProvider = FutureProvider.autoDispose((ref) async {
  final goldGrams = ref.watch(zakatGoldGramsProvider);
  final silverGrams = ref.watch(zakatSilverGramsProvider);
  final cash = ref.watch(zakatCashProvider);
  final bizGoods = ref.watch(zakatBizGoodsProvider);
  final receivable = ref.watch(zakatReceivableProvider);
  final debts = ref.watch(zakatDebtsProvider);

  // Current gold rate per bhori: 248000, silver nisab: 52860
  const goldRatePerBhori = 248000.0;
  const silverNisabBDT = 52860.0; // Used as nisab threshold (Hanafi method)

  // Convert grams to bhori: 1 bhori = 11.664 grams
  final goldValueBDT = (goldGrams / 11.664) * goldRatePerBhori;

  // For silver: approximate rate per gram based on new silver rates
  const silverRatePerGram = 9.3; // ~5700 per bhori / 11.664 grams
  final silverValueBDT = silverGrams * silverRatePerGram;

  final totalAssets = goldValueBDT + silverValueBDT + cash + bizGoods + receivable - debts;
  final isEligible = totalAssets >= silverNisabBDT;
  final zakatAmount = isEligible ? totalAssets * 0.025 : 0.0;

  final result = {
    'totalAssets': totalAssets,
    'isEligible': isEligible,
    'zakatAmount': zakatAmount,
    'nisabLimit': silverNisabBDT,
  };

  ref.watch(zakatResultProvider.notifier).state = result;
  return result;
});
