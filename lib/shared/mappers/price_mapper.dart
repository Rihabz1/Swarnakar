import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/models/price_model.dart';

double? parsePriceValue(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '');
}

String parsePriceUpdatedAt(Object? value) {
  if (value is Timestamp) return value.toDate().toUtc().toIso8601String();
  if (value is DateTime) return value.toIso8601String();
  return value?.toString() ?? '';
}

List<PriceModel> mapGoldPrices(Map<String, dynamic>? data) {
  if (data == null) return [];
  final updatedAt = parsePriceUpdatedAt(data['updatedAt']);
  return _mapFields(data, updatedAt, const [
    ('gold_22k', AppStrings.karat22),
    ('gold_21k', AppStrings.karat21),
    ('gold_22k_old', AppStrings.oldKarat22),
    ('gold_21k_old', AppStrings.oldKarat21),
    ('gold_paka', AppStrings.pureAcid),
    ('gold_tukra', AppStrings.pieceGold),
  ]);
}

List<PriceModel> mapSilverPrices(Map<String, dynamic>? data) {
  if (data == null) return [];
  final updatedAt = parsePriceUpdatedAt(data['updatedAt']);
  return _mapFields(data, updatedAt, const [
    ('silver_22k', AppStrings.newSilverKarat22),
    ('silver_21k', AppStrings.newSilverKarat21),
    ('silver_chandi', AppStrings.silverRopya),
    ('silver_acid_kaim', AppStrings.acidKaim),
  ]);
}

Map<String, List<PriceModel>> groupGoldPrices(List<PriceModel> prices) {
  return {
    AppStrings.oldGoldPrices: [
      ...prices.where((price) => price.label == AppStrings.oldKarat22),
      ...prices.where((price) => price.label == AppStrings.oldKarat21),
    ],
    AppStrings.currentDhakaPrices: [
      ...prices.where((price) => price.label == AppStrings.karat22),
      ...prices.where((price) => price.label == AppStrings.karat21),
    ],
    AppStrings.pureFineGold: [
      ...prices.where((price) => price.label == AppStrings.pureAcid),
      ...prices.where((price) => price.label == AppStrings.pieceGold),
    ],
  };
}

Map<String, List<PriceModel>> groupSilverPrices(List<PriceModel> prices) {
  return {
    AppStrings.newSilver: prices
        .where((price) =>
            price.label != AppStrings.silverRopya &&
            price.label != AppStrings.acidKaim)
        .toList(),
    AppStrings.silverAndAcidKaim: prices
        .where((price) =>
            price.label == AppStrings.silverRopya ||
            price.label == AppStrings.acidKaim)
        .toList(),
  };
}

List<PriceModel> _mapFields(
  Map<String, dynamic> data,
  String updatedAt,
  List<(String, String)> fields,
) {
  final prices = <PriceModel>[];
  for (final (field, label) in fields) {
    final price = parsePriceValue(data[field]);
    if (price == null) continue;
    prices.add(PriceModel(
      label: label,
      price: price,
      unit: AppStrings.perBhori,
      updatedAt: updatedAt,
    ));
  }
  return prices;
}
