import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

String financeMoney(Object? value) => formatSar(value?.toString());
String financePercent(Object? value) => formatPercent(value?.toString());

String financeDate(Object? value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return '—';
  // Financial calendar dates arrive as ISO strings. Preserve their recorded
  // calendar day; local timezone conversion could shift an invoice/collection
  // date backward or forward by one day.
  final isoDay = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:T|$)').firstMatch(raw);
  if (isoDay != null) {
    return '${isoDay.group(3)}/${isoDay.group(2)}/${isoDay.group(1)}';
  }
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return toLatinDigits(raw);
  return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
}

String financeField(Map<String, dynamic> row, List<String> keys) {
  for (final key in keys) {
    final value = row[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return toLatinDigits(value.toString());
    }
  }
  return '—';
}

/// Display labels only. Filters and exports retain the original category value.
String financeCostCategory(BuildContext context, Object? value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return '—';
  return switch (raw.toUpperCase()) {
    'TEAM' => context.tr(en: 'Team costs', ar: 'تكاليف الفريق'),
    'OTHER' => context.tr(en: 'Other costs', ar: 'تكاليف أخرى'),
    'MATERIAL' => context.tr(en: 'Materials', ar: 'مواد'),
    'EQUIPMENT' => context.tr(en: 'Equipment', ar: 'معدات'),
    'TRANSPORTATION' => context.tr(en: 'Transportation', ar: 'نقل'),
    'FOOD' => context.tr(en: 'Food', ar: 'طعام'),
    'PERCENTAGE' => context.tr(en: 'Percentage', ar: 'نسبة'),
    'FLIGHT' => context.tr(en: 'Flights', ar: 'طيران'),
    'TRAVEL' => context.tr(en: 'Travel', ar: 'سفر'),
    'ACCOMMODATION' => context.tr(en: 'Accommodation', ar: 'إقامة'),
    'HOSPITALITY' => context.tr(en: 'Hospitality', ar: 'ضيافة'),
    'PRINTING' => context.tr(en: 'Printing', ar: 'طباعة'),
    'GIFTS' => context.tr(en: 'Gifts', ar: 'هدايا'),
    'DESIGN' => context.tr(en: 'Design', ar: 'تصميم'),
    'LABOR' => context.tr(en: 'Labor', ar: 'عمالة'),
    'SUBCONTRACTOR' => context.tr(en: 'Subcontractor', ar: 'مقاول من الباطن'),
    'UNCATEGORIZED' ||
    'UNASSIGNED' =>
      context.tr(en: 'Uncategorized', ar: 'غير مصنف'),
    _ => toLatinDigits(raw),
  };
}

String financeMetricTitle(BuildContext context, String metric) {
  switch (metric) {
    case 'contractValue':
      return context.tr(en: 'Total contract value', ar: 'إجمالي قيمة العقود');
    case 'collected':
      return context.tr(en: 'Collected amounts', ar: 'المبالغ المحصلة');
    case 'uncollected':
      return context.tr(en: 'Uncollected amounts', ar: 'المبالغ غير المحصلة');
    case 'costs':
      return context.tr(en: 'Project costs', ar: 'تكاليف المشاريع');
    case 'netProfit':
      return context.tr(en: 'Net profit', ar: 'صافي الربح');
    case 'collectionRate':
      return context.tr(en: 'Collection rate', ar: 'نسبة التحصيل');
    default:
      return metric;
  }
}

String financeReportTitle(BuildContext context, String type) {
  switch (type) {
    case 'revenue':
      return context.tr(en: 'Revenue', ar: 'الإيرادات');
    case 'collection-status':
      return context.tr(
          en: 'Collected vs outstanding', ar: 'المحصّل وغير المحصّل');
    case 'aging':
      return context.tr(en: 'Aging', ar: 'أعمار المستحقات');
    case 'costs':
      return context.tr(en: 'Cost breakdown', ar: 'تفصيل التكاليف');
    case 'profitability':
      return context.tr(en: 'Profitability', ar: 'الربحية');
    case 'vat':
      return context.tr(en: 'VAT', ar: 'ضريبة القيمة المضافة');
    case 'cash-flow':
      return context.tr(en: 'Cash flow', ar: 'التدفق النقدي');
    case 'entities':
      return context.tr(
          en: 'Clients & operators', ar: 'العملاء والشركات المشغلة');
    case 'comparison':
      return context.tr(en: 'Period comparison', ar: 'مقارنة الفترات');
    default:
      return type;
  }
}

class FinanceSurface extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  const FinanceSurface({
    super.key,
    required this.child,
    this.color = AppTheme.surface,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: AppTheme.border.withValues(alpha: .65)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: child,
      );
}

class FinanceMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  const FinanceMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            width: 244,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: foreground,
                        fontSize: 17,
                        fontWeight: FontWeight.w900)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(value,
                      style: TextStyle(
                          color: foreground,
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [FontFeature.tabularFigures()])),
                ),
                Row(children: [
                  Expanded(
                    child: Text(caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: foreground.withValues(alpha: .7),
                            fontSize: 12)),
                  ),
                  Icon(Icons.arrow_outward_rounded,
                      size: 18, color: foreground),
                ]),
              ],
            ),
          ),
        ),
      );
}

class FinanceActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const FinanceActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => FinanceSurface(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: AppTheme.softSurface,
                    borderRadius: BorderRadius.circular(15)),
                child: Icon(icon, color: AppTheme.ink),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppTheme.muted, fontSize: 12)),
                    ]),
              ),
              Icon(
                  context.isArabic
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: AppTheme.muted),
            ]),
          ),
        ),
      );
}

class FinanceLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool prominent;

  const FinanceLabelValue(
      {super.key,
      required this.label,
      required this.value,
      this.prominent = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: prominent ? AppTheme.ink : AppTheme.muted,
                    fontSize: prominent ? 15 : 13,
                    fontWeight: prominent ? FontWeight.w800 : FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: prominent ? 17 : 13,
                    fontWeight: prominent ? FontWeight.w900 : FontWeight.w700)),
          ),
        ]),
      );
}

class FinancePeriodPicker extends StatelessWidget {
  final int? year;
  final String quarter;
  final List<int> availableYears;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<String> onQuarterChanged;

  const FinancePeriodPicker({
    super.key,
    required this.year,
    required this.quarter,
    required this.availableYears,
    required this.onYearChanged,
    required this.onQuarterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final years = <int>{
      DateTime.now().year,
      ...availableYears,
      if (year != null) year!
    }.toList()
      ..sort((a, b) => b.compareTo(a));
    return Row(children: [
      Expanded(
        child: DropdownButtonFormField<int>(
          key: ValueKey('finance-year-${year ?? 0}'),
          initialValue: year ?? 0,
          isExpanded: true,
          decoration:
              InputDecoration(labelText: context.tr(en: 'Year', ar: 'السنة')),
          items: [
            DropdownMenuItem(
                value: 0,
                child: Text(context.tr(en: 'All years', ar: 'كل السنوات'),
                    overflow: TextOverflow.ellipsis)),
            ...years.map((value) =>
                DropdownMenuItem(value: value, child: Text('$value'))),
          ],
          onChanged: (value) => onYearChanged(value == 0 ? null : value),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: DropdownButtonFormField<String>(
          key: ValueKey('finance-quarter-$quarter'),
          initialValue: quarter,
          isExpanded: true,
          decoration: InputDecoration(
              labelText: context.tr(en: 'Quarter', ar: 'الربع')),
          items: [
            DropdownMenuItem(
                value: 'ALL',
                child: Text(context.tr(en: 'All quarters', ar: 'كل الأرباع'),
                    overflow: TextOverflow.ellipsis)),
            for (var quarter = 1; quarter <= 4; quarter++)
              DropdownMenuItem(
                  value: 'Q$quarter',
                  child:
                      Text(context.tr(en: 'Q$quarter', ar: 'الربع $quarter'))),
          ],
          onChanged:
              year == null ? null : (value) => onQuarterChanged(value ?? 'ALL'),
        ),
      ),
    ]);
  }
}

class FinancePageFooter extends StatelessWidget {
  final FinancePageMeta meta;
  final ValueChanged<int> onPageChanged;

  const FinancePageFooter(
      {super.key, required this.meta, required this.onPageChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
        IconButton(
          onPressed: meta.page > 1 ? () => onPageChanged(meta.page - 1) : null,
          icon: Icon(context.isArabic
              ? Icons.chevron_right_rounded
              : Icons.chevron_left_rounded),
          tooltip: context.tr(en: 'Previous page', ar: 'الصفحة السابقة'),
        ),
        Expanded(
          child: Text(
            context.tr(
              en: 'Page ${meta.page} of ${meta.totalPages.clamp(1, 999999)} · ${meta.total} results',
              ar: 'الصفحة ${meta.page} من ${meta.totalPages.clamp(1, 999999)} · ${meta.total} نتيجة',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ),
        IconButton(
          onPressed: meta.page < meta.totalPages
              ? () => onPageChanged(meta.page + 1)
              : null,
          icon: Icon(context.isArabic
              ? Icons.chevron_left_rounded
              : Icons.chevron_right_rounded),
          tooltip: context.tr(en: 'Next page', ar: 'الصفحة التالية'),
        ),
      ]);
}

class FinanceEmptyState extends StatelessWidget {
  final String message;
  const FinanceEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) => FinanceSurface(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(children: [
            const Icon(Icons.inbox_outlined, color: AppTheme.muted, size: 32),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.muted, fontSize: 14)),
          ]),
        ),
      );
}

class FinanceErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;
  const FinanceErrorState({super.key, required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) => FinanceSurface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              context.tr(
                  en: 'Financial data is unavailable',
                  ar: 'البيانات المالية غير متاحة'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 5),
          Text(
              message ??
                  context.tr(
                      en: 'Please try again.', ar: 'يرجى المحاولة مرة أخرى.'),
              style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
          const SizedBox(height: 12),
          TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr(en: 'Retry', ar: 'إعادة المحاولة'))),
        ]),
      );
}
