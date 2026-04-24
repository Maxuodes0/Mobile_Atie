import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PeriodFiltersBar extends StatelessWidget {
  final int? year; // null = all years
  final int? quarter; // null = all quarters (only meaningful when year != null)
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<int?> onQuarterChanged;
  final int yearsBack;
  final List<int>? availableYears;

  const PeriodFiltersBar({
    super.key,
    required this.year,
    required this.quarter,
    required this.onYearChanged,
    required this.onQuarterChanged,
    this.yearsBack = 6,
    this.availableYears,
  });

  @override
  Widget build(BuildContext context) {
    final nowYear = DateTime.now().year;
    final rawYears =
        availableYears ?? List<int>.generate(yearsBack, (i) => nowYear - i);
    final years = rawYears.toSet().toList()..sort((a, b) => b.compareTo(a));

    Widget dropdown<T>({
      required T? value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?>? onChanged,
    }) {
      return Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            isDense: true,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    final yearDropdown = dropdown<int>(
      value: year,
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('كل السنوات')),
        ...years.map(
          (y) => DropdownMenuItem<int>(value: y, child: Text(y.toString())),
        ),
      ],
      onChanged: onYearChanged,
    );

    final quarterEnabled = year != null;
    final quarterDropdown = dropdown<int>(
      value: quarterEnabled ? quarter : null,
      items: const [
        DropdownMenuItem<int>(value: null, child: Text('كل الأرباع')),
        DropdownMenuItem<int>(value: 1, child: Text('Q1')),
        DropdownMenuItem<int>(value: 2, child: Text('Q2')),
        DropdownMenuItem<int>(value: 3, child: Text('Q3')),
        DropdownMenuItem<int>(value: 4, child: Text('Q4')),
      ],
      onChanged: quarterEnabled ? onQuarterChanged : null,
    );

    return Row(
      children: [
        Expanded(child: yearDropdown),
        const SizedBox(width: 10),
        Expanded(
          child: Opacity(
            opacity: quarterEnabled ? 1 : 0.55,
            child: quarterDropdown,
          ),
        ),
      ],
    );
  }
}
