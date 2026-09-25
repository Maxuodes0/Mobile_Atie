import 'package:flutter/material.dart';

import '../../../data/models/finance_dashboard.dart';
import '../../../data/models/monthly_collection_point.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/mini_line_chart.dart';

class DashboardCollectionsCard extends StatefulWidget {
  final FinanceKpis? kpis;
  final List<MonthlyCollectionPoint> collections;

  const DashboardCollectionsCard({
    super.key,
    required this.kpis,
    required this.collections,
  });

  @override
  State<DashboardCollectionsCard> createState() =>
      _DashboardCollectionsCardState();
}

class _DashboardCollectionsCardState extends State<DashboardCollectionsCard> {
  int? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final collectedSeries = widget.collections.map((p) => p.collected).toList();
    final months = widget.collections.map((p) => p.month).toList();
    final kpis = widget.kpis;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.dashboardPaper,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  context.tr(en: 'Collection rhythm', ar: 'حركة التحصيل'),
                  style: const TextStyle(
                    color: AppTheme.dashboardInk,
                    fontFamily: AppTheme.dashboardFontFamily,
                    fontFamilyFallback: AppTheme.currencyFontFallback,
                    fontSize: 28,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                width: 13,
                height: 13,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  color: AppTheme.dashboardMint,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
                en: 'Collected during the period', ar: 'المحصل خلال الفترة'),
            style: const TextStyle(
              color: AppTheme.dashboardMuted,
              fontFamily: AppTheme.dashboardFontFamily,
              fontFamilyFallback: AppTheme.currencyFontFallback,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 54,
            child: FittedBox(
              alignment: AlignmentDirectional.centerStart,
              fit: BoxFit.scaleDown,
              child: Text(
                formatSar(kpis?.totalCollectedAmount),
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: AppTheme.dashboardInk,
                  fontFamily: AppTheme.dashboardFontFamily,
                  fontFamilyFallback: AppTheme.currencyFontFallback,
                  fontSize: 52,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: LayoutBuilder(builder: (context, constraints) {
              final chartWidth =
                  collectedSeries.length * 68.0 > constraints.maxWidth
                      ? collectedSeries.length * 68.0
                      : constraints.maxWidth;
              return SingleChildScrollView(
                key: const ValueKey('collection-rhythm-scroll'),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: chartWidth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: collectedSeries.isEmpty
                        ? null
                        : (details) {
                            final position = ((details.localPosition.dx - 16) /
                                    (chartWidth - 32)) *
                                (collectedSeries.length - 1);
                            setState(() => _selectedMonth = position
                                .round()
                                .clamp(0, collectedSeries.length - 1));
                          },
                    child: MiniLineChart(
                      values: collectedSeries,
                      color: AppTheme.dashboardInk,
                      highlightColor: AppTheme.dashboardMint,
                      labels: months,
                      backgroundColor: AppTheme.dashboardPaper,
                      labelStyle: const TextStyle(
                        color: AppTheme.dashboardMuted,
                        fontFamily: AppTheme.dashboardFontFamily,
                        fontFamilyFallback: AppTheme.currencyFontFallback,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedMonth != null &&
                    _selectedMonth! < widget.collections.length
                ? '${widget.collections[_selectedMonth!].month}: ${formatSar(widget.collections[_selectedMonth!].collected.toStringAsFixed(2))}'
                : context.tr(
                    en: 'Swipe to explore; tap a month for its amount',
                    ar: 'اسحب للاستكشاف واضغط على الشهر لمعرفة المبلغ'),
            style: const TextStyle(
                color: AppTheme.dashboardMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr(en: 'Still outstanding', ar: 'المتبقي للتحصيل'),
                  style: const TextStyle(
                    color: AppTheme.dashboardMuted,
                    fontFamily: AppTheme.dashboardFontFamily,
                    fontFamilyFallback: AppTheme.currencyFontFallback,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatSar(
                    kpis?.allTimeOutstandingAmount ?? kpis?.outstandingAmount),
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: AppTheme.dashboardInk,
                  fontFamily: AppTheme.dashboardFontFamily,
                  fontFamilyFallback: AppTheme.currencyFontFallback,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
