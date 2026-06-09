import 'package:flutter_riverpod/flutter_riverpod.dart';

final calculatorUnitProvider = StateProvider<String>((ref) => 'গ্রাম হিসেবে');

final calculatorWeightProvider = StateProvider<double>((ref) => 0);
final calculatorRateProvider = StateProvider<double>((ref) => 0);
final calculatorLaborProvider = StateProvider<double>((ref) => 0);

final calculatorResultProvider =
    StateProvider<Map<String, double>?>((ref) => null);

Map<String, double>? computeCalculatorResult({
  required String unit,
  required double weight,
  required double rate,
  required double labor,
}) {
  if (weight == 0 || rate == 0) {
    return null;
  }

  final metalValue = weight * rate;
  final totalValue = metalValue + labor;

  return {
    'metalValue': metalValue,
    'labor': labor.toDouble(),
    'totalValue': totalValue,
  };
}

final calculateGoldProvider = FutureProvider.autoDispose((ref) async {
  final unit = ref.watch(calculatorUnitProvider);
  final weight = ref.watch(calculatorWeightProvider);
  final rate = ref.watch(calculatorRateProvider);
  final labor = ref.watch(calculatorLaborProvider);
  final result = computeCalculatorResult(
    unit: unit,
    weight: weight,
    rate: rate,
    labor: labor,
  );
  ref.watch(calculatorResultProvider.notifier).state = result;
  return result;
});
