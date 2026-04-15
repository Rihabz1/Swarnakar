import 'package:flutter_riverpod/flutter_riverpod.dart';

final calculatorUnitProvider = StateProvider<String>((ref) => 'গ্রাম হিসেবে');

final calculatorWeightProvider = StateProvider<double>((ref) => 0);
final calculatorRateProvider = StateProvider<double>((ref) => 0);
final calculatorLaborProvider = StateProvider<double>((ref) => 0);

final calculatorResultProvider = StateProvider<Map<String, double>?>((ref) => null);

final calculateGoldProvider = FutureProvider.autoDispose((ref) async {
  final unit = ref.watch(calculatorUnitProvider);
  final weight = ref.watch(calculatorWeightProvider);
  final rate = ref.watch(calculatorRateProvider);
  final labor = ref.watch(calculatorLaborProvider);

  if (weight == 0 || rate == 0) {
    ref.watch(calculatorResultProvider.notifier).state = null;
    return null;
  }

  // Convert to bhori first
  double weightInBhori = 0;
  if (unit == 'গ্রাম হিসেবে') {
    weightInBhori = weight / 11.664;
  } else if (unit == 'ভরি হিসেবে') {
    weightInBhori = weight;
  } else if (unit == 'আনা হিসেবে') {
    weightInBhori = weight / 16;
  }

  final metalValue = weightInBhori * rate;
  final totalValue = metalValue + labor;

  final result = {
    'metalValue': metalValue,
    'labor': labor.toDouble(),
    'totalValue': totalValue,
  };

  ref.watch(calculatorResultProvider.notifier).state = result;
  return result;
});
