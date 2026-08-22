import 'package:swarnakar/core/constants/app_strings.dart';

const double gramsPerBhori = 11.664;
const double gramsPerTroyOunce = 31.1035;

/// Converts [value] between the weight units supported by the converter UI.
///
/// Keeping this arithmetic outside the widget makes the business rules
/// independently testable and reusable.
double convertWeight({
  required double value,
  required String fromUnit,
  required String toUnit,
}) {
  final grams = switch (fromUnit) {
    AppStrings.gramUnit => value,
    AppStrings.bhoriUnit => value * gramsPerBhori,
    AppStrings.ounceUnit => value * gramsPerTroyOunce,
    _ => throw ArgumentError.value(fromUnit, 'fromUnit', 'Unsupported unit'),
  };

  return switch (toUnit) {
    AppStrings.gramUnit => grams,
    AppStrings.bhoriUnit => grams / gramsPerBhori,
    AppStrings.ounceUnit => grams / gramsPerTroyOunce,
    _ => throw ArgumentError.value(toUnit, 'toUnit', 'Unsupported unit'),
  };
}
