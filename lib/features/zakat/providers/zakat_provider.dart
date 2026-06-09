import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swarnakar/core/providers/connectivity_provider.dart';

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

    final double silverNisabBDT =
        (nisabData?['silver_nisab'] ?? 52860.0).toDouble();
    final double goldNisabBDT =
        (nisabData?['gold_nisab'] ?? 895200.0).toDouble();

    const goldRatePerBhori = 248000.0;
    final goldValueBDT = (goldGrams / 11.664) * goldRatePerBhori;

    const silverRatePerGram = 9.3;
    final silverValueBDT = silverGrams * silverRatePerGram;

    final totalAssets =
        goldValueBDT + silverValueBDT + cash + bizGoods + receivable - debts;

    // Determine the active Nisab limit based on asset mix
    final bool hasOnlyGold = goldGrams > 0 &&
        silverGrams == 0 &&
        cash == 0 &&
        bizGoods == 0 &&
        receivable == 0;
    final activeNisabBDT = hasOnlyGold ? goldNisabBDT : silverNisabBDT;

    final isEligible = totalAssets >= activeNisabBDT;
    final zakatAmount = isEligible ? totalAssets * 0.025 : 0.0;

    state = {
      'totalAssets': totalAssets,
      'isEligible': isEligible,
      'zakatAmount': zakatAmount,
      'nisabLimit': activeNisabBDT,
    };
  }
}

final zakatCalculatorProvider =
    NotifierProvider.autoDispose<ZakatCalculator, Map<String, dynamic>?>(() {
  return ZakatCalculator();
});
