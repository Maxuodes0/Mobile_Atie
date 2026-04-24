class PeriodRange {
  final String? from; // YYYY-MM-DD
  final String? to; // YYYY-MM-DD

  const PeriodRange({this.from, this.to});
}

String _two(int n) => n.toString().padLeft(2, '0');

// Returns a simple YYYY-MM-DD range from (inclusive) -> to (inclusive).
// - If `year` is null, returns an empty range (no filtering).
// - If `quarter` is provided, it must be 1..4.
PeriodRange computePeriodRange({required int? year, int? quarter}) {
  if (year == null) return const PeriodRange();

  if (quarter == null) {
    return PeriodRange(from: '$year-01-01', to: '$year-12-31');
  }

  final q = quarter.clamp(1, 4);
  final startMonth = (q - 1) * 3 + 1;
  final endMonth = startMonth + 2;
  // Day 0 of next month gives the last day of the current month.
  final endDay = DateTime(year, endMonth + 1, 0).day;

  final from = '$year-${_two(startMonth)}-01';
  final to = '$year-${_two(endMonth)}-${_two(endDay)}';
  return PeriodRange(from: from, to: to);
}

