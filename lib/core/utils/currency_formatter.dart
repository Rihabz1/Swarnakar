import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _bdtFormat = NumberFormat('#,##0', 'bn_BD');
  static final NumberFormat _bdtDecimal = NumberFormat('#,##0.00', 'bn_BD');

  /// Format amount to BDT with comma separators
  static String formatBDT(double amount, {bool showDecimal = false}) {
    if (showDecimal) {
      return '৳ ${_bdtDecimal.format(amount)}';
    }
    return '৳ ${_bdtFormat.format(amount.toInt())}';
  }

  /// Format number without currency
  static String formatNumber(double amount, {bool showDecimal = false}) {
    if (showDecimal) {
      return _bdtDecimal.format(amount);
    }
    return _bdtFormat.format(amount.toInt());
  }

  /// Get just the numeric part in Bengali
  static String formatBengaliNumber(double amount) {
    return _bdtFormat.format(amount.toInt());
  }

  /// Format grams with Bengali text
  static String formatGrams(double grams) {
    return '${_bdtDecimal.format(grams)} গ্রাম';
  }

  /// Format percentage
  static String formatPercentage(double percent) {
    return '${_bdtDecimal.format(percent)}%';
  }
}
