import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');
final _dayMonthFormat = DateFormat('dd/MM');
final _moneyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

String formatDate(DateTime value) => _dateFormat.format(value);

String formatDayMonth(DateTime value) => _dayMonthFormat.format(value);

String formatMoney(num value) => _moneyFormat.format(value);

String formatKg(num value) {
  final rounded = value % 1 == 0
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  return '$rounded kg';
}
