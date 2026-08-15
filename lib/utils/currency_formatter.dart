import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currency) {
    if (currency == 'BDT') {
      return '৳${NumberFormat('#,##0.00').format(amount)}';
    } else {
      return '\$${NumberFormat('#,##0.00').format(amount)}';
    }
  }

  static String formatCompact(double amount, String currency) {
    if (currency == 'BDT') {
      return '৳${NumberFormat.compact().format(amount)}';
    } else {
      return '\$${NumberFormat.compact().format(amount)}';
    }
  }
}
