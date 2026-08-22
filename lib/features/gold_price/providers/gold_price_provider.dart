import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/providers/connectivity_provider.dart';
import 'package:swarnakar/shared/mappers/price_mapper.dart';
import 'package:swarnakar/shared/models/price_model.dart';

final goldPricesProvider = StreamProvider<List<PriceModel>>((ref) async* {
  await requireInternet(ref);
  yield* FirebaseFirestore.instance
      .collection('prices')
      .doc('current')
      .snapshots()
      .map((snapshot) => mapGoldPrices(snapshot.data()));
});

final goldPricesBySection =
    Provider<AsyncValue<Map<String, List<PriceModel>>>>((ref) {
  final pricesAsync = ref.watch(goldPricesProvider);

  return pricesAsync.whenData(groupGoldPrices);
});
