import 'package:flutter/material.dart';

import '../../../data/models/finance_dashboard.dart';
import '../../../data/models/monthly_collection_point.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/mini_line_chart.dart';
import 'dashboard_chart_card.dart';

class DashboardCollectionsCard extends StatelessWidget {
  final FinanceKpis? kpis;
  final List<MonthlyCollectionPoint> collections;

  const DashboardCollectionsCard({
    super.key,
    required this.kpis,
    required this.collections,
  });

  @override
  Widget build(BuildContext context) {
    final collectedSeries = collections.map((p) => p.collected).toList();
    final months = collections.map((p) => p.month).toList();

    return DashboardChartCard(
      title: context.tr(en: 'Collected funds', ar: 'الأموال المحصلة'),
      value: formatSar(kpis?.totalCollectedAmount ?? '0'),
      secondaryValue: context.tr(
        en: 'Outstanding: ${formatSar(kpis?.outstandingAmount ?? '0')}',
        ar: 'غير محصل: ${formatSar(kpis?.outstandingAmount ?? '0')}',
      ),
      subtitle: context.tr(en: 'By month', ar: 'حسب الأشهر'),
      chart: SizedBox(
        height: 240,
        child: MiniLineChart(
          values: collectedSeries,
          color: AppTheme.primary,
          highlightColor: AppTheme.accent,
          labels: months,
        ),
      ),
    );
  }
}
