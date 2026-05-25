import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalculatorRateOption {
  final String id;
  final String label;
  final double price;
  final String unit;

  const CalculatorRateOption({
    required this.id,
    required this.label,
    required this.price,
    required this.unit,
  });

  static const double _gramsPerBhori = 11.664;

  double get ratePerBhori {
    if (unit == '10 গ্রাম') {
      return price * (_gramsPerBhori / 10);
    }
    return price;
  }

  @override
  bool operator ==(Object other) {
    return other is CalculatorRateOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

final calculatorUnitProvider = StateProvider<String>((ref) => 'গ্রাম হিসেবে');

final calculatorWeightProvider = StateProvider<double>((ref) => 0);
final calculatorRateProvider = StateProvider<double>((ref) => 0);
final calculatorRateOptionProvider = StateProvider<CalculatorRateOption?>((ref) => null);
final calculatorLaborProvider = StateProvider<double>((ref) => 0);

final calculatorResultProvider = StateProvider<Map<String, double>?>((ref) => null);

Map<String, double>? computeCalculatorResult({
  required String unit,
  required double weight,
  required double rate,
  required double labor,
}) {
  if (weight == 0 || rate == 0) {
    return null;
  }

  final weightInBhori = _weightToBhori(unit, weight);
  final metalValue = weightInBhori * rate;
  final totalValue = metalValue + labor;

  return {
    'metalValue': metalValue,
    'labor': labor.toDouble(),
    'totalValue': totalValue,
  };
}

double _weightToBhori(String unit, double weight) {
  if (unit == 'গ্রাম হিসেবে') {
    return weight / 11.664;
  }
  if (unit == 'ভরি হিসেবে') {
    return weight;
  }
  if (unit == 'আনা হিসেবে') {
    return weight / 16;
  }
  return weight;
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
