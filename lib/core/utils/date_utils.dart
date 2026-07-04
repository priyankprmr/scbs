import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd MMM yyyy');
final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

String formatDate(DateTime date) => _dateFormat.format(date);
String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);
