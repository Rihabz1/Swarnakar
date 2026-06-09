import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/providers/connectivity_provider.dart';
import 'package:swarnakar/shared/models/price_model.dart';

final silverPricesProvider = StreamProvider<List<PriceModel>>((ref) async* {
  await requireInternet(ref);
  yield* FirebaseFirestore.instance
      .collection('prices')
      .doc('current')
      .snapshots()
      .map((snapshot) {
    final data = snapshot.data();
    if (data == null) {
      return <PriceModel>[];
    }

    final updatedAt = _readUpdatedAt(data['updatedAt']);
    final prices = <PriceModel>[];

    _addPrice(prices,
        label: AppStrings.newSilverKarat22,
        value: data['silver_22k'],
        updatedAt: updatedAt);
    _addPrice(prices,
        label: AppStrings.newSilverKarat21,
        value: data['silver_21k'],
        updatedAt: updatedAt);
    _addPrice(prices,
        label: AppStrings.silverRopya,
        value: data['silver_chandi'],
        updatedAt: updatedAt);
    _addPrice(prices,
        label: AppStrings.acidKaim,
        value: data['silver_acid_kaim'],
        updatedAt: updatedAt);

    return prices;
  });
});

final silverPricesBySection =
    Provider<AsyncValue<Map<String, List<PriceModel>>>>((ref) {
  final pricesAsync = ref.watch(silverPricesProvider);

  return pricesAsync.whenData((prices) {
    return {
      AppStrings.newSilver: prices
          .where((p) => !p.label.contains('চাঁদি') && !p.label.contains('এসিড'))
          .toList(),
      AppStrings.silverAndAcidKaim: prices
          .where((p) => p.label.contains('চাঁদি') || p.label.contains('এসিড'))
          .toList(),
    };
  });
});

void _addPrice(
  List<PriceModel> prices, {
  required String label,
  required Object? value,
  required String updatedAt,
}) {
  final price = _readDoubleOrNull(value);
  if (price == null) return;
  prices.add(
    PriceModel(
      label: label,
      price: price,
      unit: AppStrings.perBhori,
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
