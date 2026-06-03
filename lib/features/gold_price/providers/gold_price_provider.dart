import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/models/price_model.dart';

final goldPricesProvider = StreamProvider<List<PriceModel>>((ref) {
  return FirebaseFirestore.instance.collection('prices').doc('current').snapshots().map((snapshot) {
    final data = snapshot.data();
    if (data == null) {
      return <PriceModel>[];
    }

    final updatedAt = _readUpdatedAt(data['updatedAt']);
    final prices = <PriceModel>[];

    _addPrice(prices, label: AppStrings.karat22, value: data['gold_22k'], updatedAt: updatedAt);
    _addPrice(prices, label: AppStrings.karat21, value: data['gold_21k'], updatedAt: updatedAt);
    _addPrice(prices, label: AppStrings.oldKarat22, value: data['gold_22k_old'], updatedAt: updatedAt);
    _addPrice(prices, label: AppStrings.oldKarat21, value: data['gold_21k_old'], updatedAt: updatedAt);
    _addPrice(
      prices,
      label: AppStrings.pureAcid,
      value: data['gold_paka'],
      updatedAt: updatedAt,
      unit: '10 গ্রাম',
    );
    _addPrice(prices, label: AppStrings.pieceGold, value: data['gold_tukra'], updatedAt: updatedAt);

    return prices;
  });
});

final goldPricesBySection = Provider<AsyncValue<Map<String, List<PriceModel>>>>((ref) {
  final pricesAsync = ref.watch(goldPricesProvider);

  return pricesAsync.whenData((prices) {

    return {
      AppStrings.currentDhakaPrices: prices
          .where((p) => !p.label.contains('পুরাতন') && !p.label.contains('পাকা') && !p.label.contains('টুকরা'))
          .toList(),
      AppStrings.oldGoldPrices: prices.where((p) => p.label.contains('পুরাতন')).toList(),
      AppStrings.pureFineGold: prices.where((p) => p.label.contains('পাকা') || p.label.contains('টুকরা')).toList(),
    };
  });
});

void _addPrice(
  List<PriceModel> prices, {
  required String label,
  required Object? value,
  required String updatedAt,
  String unit = AppStrings.perBhori,
}) {
  final price = _readDoubleOrNull(value);
  if (price == null) return;
  prices.add(
    PriceModel(
      label: label,
      price: price,
      unit: unit,
      updatedAt: updatedAt,
    ),
  );
}

double? _readDoubleOrNull(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String _readUpdatedAt(Object? value) {
  if (value is Timestamp) {
    return value.toDate().toIso8601String();
  }
  return value?.toString() ?? '';
}
