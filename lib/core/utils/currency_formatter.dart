import 'package:intl/intl.dart';

final _inrFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

String formatCurrency(double amount) => _inrFormat.format(amount);
