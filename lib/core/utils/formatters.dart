import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');
final _dayMonthFormat = DateFormat('dd/MM');
final _dateTimeFormat = DateFormat('HH:mm • dd/MM/yyyy');
final _moneyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

String formatDate(DateTime value) => _dateFormat.format(value);

String formatDayMonth(DateTime value) => _dayMonthFormat.format(value);

String formatDateTime(DateTime value) => _dateTimeFormat.format(value);

String formatMoney(num value) => _moneyFormat.format(value);

String formatKg(num value) {
  final rounded = value % 1 == 0
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  return '$rounded kg';
}

String formatOrderCode(String value) {
  final raw = value.trim().replaceFirst(
    RegExp(r'^DON_?', caseSensitive: false),
    '',
  );
  final compact = raw.length <= 8 ? raw : raw.substring(raw.length - 8);
  return 'Đơn #${compact.toUpperCase()}';
}
