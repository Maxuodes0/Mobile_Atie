import 'package:intl/intl.dart';

final NumberFormat _moneyFmt = NumberFormat('#,##0.##', 'en_US');

String formatSar(String raw) {
  final value = double.tryParse(raw) ?? 0;
  return '${_moneyFmt.format(value)} SAR';
}

String formatPercent(String raw) {
  final value = double.tryParse(raw) ?? 0;
  if (value == value.roundToDouble()) return '${value.toStringAsFixed(0)}%';
  return '${value.toStringAsFixed(2)}%';
}
