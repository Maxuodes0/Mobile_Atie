import 'package:flutter/material.dart';

import '../../../data/models/finance_dashboard.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/app_services.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../utils/period_range.dart';
import '../../finance_report_screen.dart';

class DashboardKpiGrid extends StatelessWidget {
  final FinanceKpis? kpis;

  const DashboardKpiGrid({
    super.key,
    required this.kpis,
  });

  void _openReport(
    BuildContext context, {
    required String title,
    required String reportType,
  }) {
    final selection = AppServices.periodFilters.selection.value;
    final range = computePeriodRange(
      year: selection.year,
      quarter: selection.quarter,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FinanceReportScreen(
          title: title,
          reportType: reportType,
          from: range.from,
          to: range.to,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = <_MetricCardData>[
      _MetricCardData(
        title: context.tr(
          en: 'Total contract value',
          ar: 'إجمالي قيمة العقود',
        ),
        caption: context.tr(en: 'Revenue', ar: 'الإيرادات'),
        value: formatSar(kpis?.totalProjectValueWithoutVat),
        background: AppTheme.dashboardPaper,
        foreground: AppTheme.dashboardInk,
        onTap: () => _openReport(
          context,
          title: context.tr(en: 'Revenue report', ar: 'تقرير الإيرادات'),
          reportType: 'REVENUE_REPORT',
        ),
      ),
      _MetricCardData(
        title: context.tr(en: 'Collected', ar: 'المبالغ المحصلة'),
        caption: context.tr(en: 'Cash received', ar: 'المبالغ المستلمة'),
        value: formatSar(kpis?.totalCollectedAmount),
        background: AppTheme.dashboardMint,
        foreground: AppTheme.dashboardInk,
        onTap: () => _openReport(
          context,
          title: context.tr(en: 'Collections report', ar: 'تقرير التحصيل'),
          reportType: 'COLLECTIONS_REPORT',
        ),
      ),
      _MetricCardData(
        title: context.tr(en: 'Outstanding', ar: 'المبالغ غير المحصلة'),
        caption: context.tr(en: 'Awaiting collection', ar: 'بانتظار التحصيل'),
        value: formatSar(kpis?.outstandingAmount),
        background: AppTheme.dashboardGraphite,
        foreground: AppTheme.dashboardInk,
        onTap: () => _openReport(
          context,
          title: context.tr(
            en: 'Outstanding report',
            ar: 'تقرير غير المحصل',
          ),
          reportType: 'OUTSTANDING_REPORT',
        ),
      ),
      _MetricCardData(
        title: context.tr(en: 'Project costs', ar: 'تكاليف المشاريع'),
        caption: context.tr(en: 'Total spending', ar: 'إجمالي المصروفات'),
        value: formatSar(kpis?.totalCosts),
        background: AppTheme.dashboardInk,
        foreground: AppTheme.dashboardPaper,
        onTap: () => _openReport(
          context,
          title: context.tr(en: 'Project costs', ar: 'تكاليف المشاريع'),
          reportType: 'PROJECT_COSTS_REPORT',
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cardWidth = (availableWidth * 0.84).clamp(276.0, 348.0);

        return SizedBox(
          height: 220,
          child: ListView.separated(
            key: const ValueKey('dashboard-kpi-scroll'),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: cardWidth,
                child: _DashboardMetricCard(
                  key: ValueKey('dashboard-kpi-card-$index'),
                  data: cards[index],
                  index: index + 1,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MetricCardData {
  final String title;
  final String caption;
  final String value;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _MetricCardData({
    required this.title,
    required this.caption,
    required this.value,
    required this.background,
    required this.foreground,
    required this.onTap,
  });
}

class _DashboardMetricCard extends StatelessWidget {
  final _MetricCardData data;
  final int index;

  const _DashboardMetricCard({
    super.key,
    required this.data,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return Semantics(
      button: true,
      label: '${data.title}: ${data.value}',
      child: Material(
        color: data.background,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: data.onTap,
          child: SizedBox(
            width: double.infinity,
            height: 220,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: data.foreground,
                            fontFamily: AppTheme.dashboardFontFamily,
                            fontFamilyFallback: AppTheme.currencyFontFallback,
                            fontSize: 27,
                            height: 0.95,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: data.foreground.withOpacitySafe(0.42),
                          fontFamily: AppTheme.dashboardFontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    data.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: data.foreground.withOpacitySafe(0.54),
                      fontFamily: AppTheme.dashboardFontFamily,
                      fontFamilyFallback: AppTheme.currencyFontFallback,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 66,
                          child: FittedBox(
                            alignment: AlignmentDirectional.centerStart,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              data.value,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: data.foreground,
                                fontFamily: AppTheme.dashboardFontFamily,
                                fontFamilyFallback:
                                    AppTheme.currencyFontFallback,
                                fontSize: 60,
                                height: 0.9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.7,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Text(
                          direction == TextDirection.rtl ? '<' : '>',
                          style: TextStyle(
                            color: data.foreground,
                            fontFamily: AppTheme.dashboardFontFamily,
                            fontSize: 30,
                            height: 0.8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
