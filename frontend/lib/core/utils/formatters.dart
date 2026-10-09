import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  static final NumberFormat _compactFormat = NumberFormat.compact(locale: 'en_IN');

  static String formatCurrency(num value) {
    return _currencyFormat.format(value);
  }

  static String formatPercent(num value, {bool showSign = true}) {
    final prefix = (showSign && value > 0) ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }

  static String formatCompact(num value) {
    return _compactFormat.format(value);
  }

  static String formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd MMM, HH:mm').format(dt);
    } catch (_) {
      return rawDate;
    }
  }
}
