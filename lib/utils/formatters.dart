import 'package:intl/intl.dart';

const String sarSymbol = '\u20C1';

String _localizedNumber(double value, String pattern, String? locale) {
  // Financial figures intentionally use Latin digits in both app languages.
  return NumberFormat(pattern, 'en_US').format(value);
}

/// Keeps localized labels/month names while displaying every digit as 0-9.
String toLatinDigits(String value) {
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  const easternArabic = '۰۱۲۳۴۵۶۷۸۹';
  return value.replaceAllMapped(RegExp('[٠-٩۰-۹]'), (match) {
    final char = match[0]!;
    final arabicIndex = arabicIndic.indexOf(char);
    if (arabicIndex >= 0) return arabicIndex.toString();
    return easternArabic.indexOf(char).toString();
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
