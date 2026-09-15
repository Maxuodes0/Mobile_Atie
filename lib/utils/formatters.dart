import 'package:intl/intl.dart';

const String sarSymbol = '\u20C1';

String _localizedNumber(double value, String pattern, String? locale) {
  final activeLocale = locale ?? Intl.defaultLocale ?? 'en_US';
  final text = NumberFormat(pattern, activeLocale).format(value);
  if (!activeLocale.startsWith('ar')) return text;
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return text.replaceAllMapped(RegExp(r'[0-9,.]'), (match) {
    final char = match[0]!;
    if (char == ',') return '٬';
    if (char == '.') return '٫';
    return digits[int.parse(char)];
  });
}

/// Display parsing only: never use this value as a financial source of truth.
double? parseFinancialValue(Object? raw) {
  if (raw == null) return null;
  final text = raw.toString().trim();
  if (!RegExp(r'^-?\d+(?:\.\d+)?$').hasMatch(text)) return null;
  final value = double.tryParse(text);
  return value != null && value.isFinite ? value : null;
}

String formatSar(String? raw, {String? locale}) {
  final value = parseFinancialValue(raw);
  if (value == null) return '—';
  return '\u2066$sarSymbol\u00A0${_localizedNumber(value, '#,##0.00', locale)}\u2069';
}

String formatPercent(String? raw, {String? locale}) {
  final value = parseFinancialValue(raw);
  if (value == null) return '—';
  return '\u2066${_localizedNumber(value, '0.00', locale)}%\u2069';
}
