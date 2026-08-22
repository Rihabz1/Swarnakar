const double defaultGoldNisabBdt = 895200;
const double defaultSilverNisabBdt = 52860;
const double defaultGoldRatePerBhori = 248000;
const double defaultSilverRatePerGram = 9.3;
const double gramsPerBhoriForZakat = 11.664;
const double zakatRate = 0.025;

class ZakatCalculation {
  const ZakatCalculation({
    required this.totalAssets,
    required this.isEligible,
    required this.zakatAmount,
    required this.nisabLimit,
  });

  final double totalAssets;
  final bool isEligible;
  final double zakatAmount;
  final double nisabLimit;

  Map<String, dynamic> toMap() {
    return {
      'totalAssets': totalAssets,
      'isEligible': isEligible,
      'zakatAmount': zakatAmount,
      'nisabLimit': nisabLimit,
    };
  }
}

ZakatCalculation calculateZakat({
  required double goldGrams,
  required double silverGrams,
  required double cash,
  required double businessGoods,
  required double receivable,
  required double debts,
  double goldNisabBdt = defaultGoldNisabBdt,
  double silverNisabBdt = defaultSilverNisabBdt,
  double goldRatePerBhori = defaultGoldRatePerBhori,
  double silverRatePerGram = defaultSilverRatePerGram,
}) {
  final goldValue = (goldGrams / gramsPerBhoriForZakat) * goldRatePerBhori;
  final silverValue = silverGrams * silverRatePerGram;
  final totalAssets =
      goldValue + silverValue + cash + businessGoods + receivable - debts;

  final hasOnlyGold = goldGrams > 0 &&
      silverGrams == 0 &&
      cash == 0 &&
      businessGoods == 0 &&
      receivable == 0;
  final nisabLimit = hasOnlyGold ? goldNisabBdt : silverNisabBdt;
  final isEligible = totalAssets >= nisabLimit;

  return ZakatCalculation(
    totalAssets: totalAssets,
    isEligible: isEligible,
    zakatAmount: isEligible ? totalAssets * zakatRate : 0,
    nisabLimit: nisabLimit,
  );
}
