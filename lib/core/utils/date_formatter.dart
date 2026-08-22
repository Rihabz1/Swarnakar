import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _bnDateTime =
      DateFormat('dd MMMM yyyy, hh:mm a', 'bn_BD');

  static String formatUpdatedAt(String? raw) {
    if (raw == null) return '';
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return _bnDateTime.format(parsed);
    }

    return trimmed;
  }
}
