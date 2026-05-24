import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/shared/models/price_model.dart';

final silverPricesProvider = StreamProvider<List<PriceModel>>((ref) {
  return FirebaseFirestore.instance.collection('prices').snapshots().map((snapshot) {
    final doc = _pickPricesDoc(snapshot.docs);
    if (doc == null) {
      return <PriceModel>[];
    }

    final data = doc.data();
    final updatedAt = _readUpdatedAt(data['updatedAt']);
    final prices = <PriceModel>[];

    _addPrice(prices, label: 'Silver', value: data['silver'], updatedAt: updatedAt);

    return prices;
  });
});

final silverPricesBySection = Provider<AsyncValue<Map<String, List<PriceModel>>>>((ref) {
  final pricesAsync = ref.watch(silverPricesProvider);
  return pricesAsync.whenData((prices) {
    return {
      AppStrings.newSilver: prices.where((p) => !p.label.contains('চাঁদি') && !p.label.contains('এসিড')).toList(),
      AppStrings.silverAndAcidKaim: prices.where((p) => p.label.contains('চাঁদি') || p.label.contains('এসিড')).toList(),
    };
  });
});

QueryDocumentSnapshot<Map<String, dynamic>>? _pickPricesDoc(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  if (docs.isEmpty) return null;
  for (final doc in docs) {
    if (doc.id == 'current') {
      return doc;
    }
  }
  return docs.first;
}

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
