import 'package:flutter/foundation.dart';

class PeriodFilterSelection {
  final int? year;
  final int? quarter;

  const PeriodFilterSelection({
    this.year,
    this.quarter,
  });
}

class PeriodFilterController {
  final ValueNotifier<PeriodFilterSelection> selection =
      ValueNotifier<PeriodFilterSelection>(
    const PeriodFilterSelection(),
  );

  int? get year => selection.value.year;
  int? get quarter => selection.value.quarter;

  void setSelection({
    required int? year,
    required int? quarter,
  }) {
    final normalizedQuarter = year == null ? null : quarter;
    final current = selection.value;
    if (current.year == year && current.quarter == normalizedQuarter) return;
    selection.value = PeriodFilterSelection(
      year: year,
      quarter: normalizedQuarter,
    );
  }
}
