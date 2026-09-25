const String sarSymbol = '\u20C1';

/// Formats a decimal string without passing monetary digits through `double`.
/// The server remains the source of truth; this only groups and displays it.
String? _formatDecimal(String raw, {int places = 2}) {
  final match = RegExp(r'^(-?)(\d+)(?:\.(\d+))?$').firstMatch(raw.trim());
  if (match == null) return null;
  final negative = match.group(1) == '-';
  final whole = BigInt.parse(match.group(2)!);
  final fraction = match.group(3) ?? '';
  final scale = BigInt.from(10).pow(places);
  final kept = fraction.padRight(places, '0').substring(0, places);
  var units = whole * scale + BigInt.parse(kept.isEmpty ? '0' : kept);
  if (fraction.length > places && int.parse(fraction[places]) >= 5) {
    units += BigInt.one;
  }
  final wholeText = (units ~/ scale).toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
  final fractionText = (units % scale).toString().padLeft(places, '0');
  final sign = negative && units != BigInt.zero ? '-' : '';
  return places == 0 ? '$sign$wholeText' : '$sign$wholeText.$fractionText';
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
  if (raw == null) return '—';
  final value = _formatDecimal(raw);
  if (value == null) return '—';
  return '\u2066$sarSymbol\u00A0$value\u2069';
}

String formatPercent(String? raw, {String? locale}) {
  if (raw == null) return '—';
  final value = _formatDecimal(raw);
  if (value == null) return '—';
  return '\u2066$value%\u2069';
}
