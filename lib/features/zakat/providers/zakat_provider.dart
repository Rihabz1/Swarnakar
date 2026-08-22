import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swarnakar/core/providers/connectivity_provider.dart';
import 'package:swarnakar/features/zakat/domain/zakat_calculator.dart';

final zakatNisabProvider =
    StreamProvider.autoDispose<Map<String, dynamic>>((ref) async* {
  await requireInternet(ref);
  yield* FirebaseFirestore.instance
      .collection('zakat')
      .doc('nisab')
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      return snapshot.data()!;
    }
    return {
      'gold_nisab': 895200.0,
      'silver_nisab': 52860.0,
    };
  });
});

class ZakatCalculator extends AutoDisposeNotifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() {
    return null;
  }

  void calculate({
    required double goldGrams,
    required double silverGrams,
    required double cash,
    required double bizGoods,
    required double receivable,
    required double debts,
  }) {
    final nisabAsync = ref.read(zakatNisabProvider);
    final nisabData = nisabAsync.value;

    state = calculateZakat(
      goldGrams: goldGrams,
      silverGrams: silverGrams,
      cash: cash,
      businessGoods: bizGoods,
      receivable: receivable,
      debts: debts,
      silverNisabBdt:
          (nisabData?['silver_nisab'] ?? defaultSilverNisabBdt).toDouble(),
      goldNisabBdt:
          (nisabData?['gold_nisab'] ?? defaultGoldNisabBdt).toDouble(),
    ).toMap();
  }
}

final zakatCalculatorProvider =
    NotifierProvider.autoDispose<ZakatCalculator, Map<String, dynamic>?>(() {
  return ZakatCalculator();
});
