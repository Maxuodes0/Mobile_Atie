import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'ios_select_field.dart';

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
      required String title,
      required T? value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?>? onChanged,
    }) {
      return IosSelectField<T>(
        sheetTitle: title,
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 13, 14, 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
        ),
      );
    }

    final yearDropdown = dropdown<int>(
      title: context.tr(en: 'Year', ar: 'السنة'),
      value: year,
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text(context.tr(en: 'All years', ar: 'كل السنوات')),
        ),
        ...years.map(
          (y) => DropdownMenuItem<int>(value: y, child: Text(y.toString())),
        ),
      ],
      onChanged: onYearChanged,
    );

    final quarterEnabled = year != null;
    final quarterDropdown = dropdown<int>(
      title: context.tr(en: 'Quarter', ar: 'الربع'),
      value: quarterEnabled ? quarter : null,
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text(context.tr(en: 'All quarters', ar: 'كل الأرباع')),
        ),
        DropdownMenuItem<int>(
          value: 1,
          child: Text(context.tr(en: 'Q1', ar: 'الربع الأول')),
        ),
        DropdownMenuItem<int>(
          value: 2,
          child: Text(context.tr(en: 'Q2', ar: 'الربع الثاني')),
        ),
        DropdownMenuItem<int>(
          value: 3,
          child: Text(context.tr(en: 'Q3', ar: 'الربع الثالث')),
        ),
        DropdownMenuItem<int>(
          value: 4,
          child: Text(context.tr(en: 'Q4', ar: 'الربع الرابع')),
        ),
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
