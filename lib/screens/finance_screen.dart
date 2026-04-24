import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/period_range.dart';
import '../widgets/app_page_header.dart';
import '../widgets/error_banner.dart';
import '../widgets/inline_loading_bar.dart';
import '../widgets/period_filters_bar.dart';
import '../widgets/summary_card.dart';
import 'finance/finance_screen_controller.dart';
import 'finance_report_screen.dart';

class FinanceScreen extends StatefulWidget {
  final bool isActive;

  const FinanceScreen({
    super.key,
    required this.isActive,
  });

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late final FinanceScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FinanceScreenController();
    _controller.addListener(_onControllerChanged);
    _controller.setActive(widget.isActive);
  }

  @override
  void didUpdateWidget(covariant FinanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _controller.setActive(widget.isActive);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final kpis = _controller.data?.kpis;
    final range = computePeriodRange(
        year: _controller.year, quarter: _controller.quarter);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () =>
            _controller.load(refreshYears: true, forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppPageHeader(
              title: 'المالية',
              subtitle: 'تقارير الإيرادات والتكاليف',
            ),
            const SizedBox(height: 14),
            IgnorePointer(
              ignoring: _controller.updating,
              child: Opacity(
                opacity: _controller.updating ? 0.65 : 1,
                child: PeriodFiltersBar(
                  year: _controller.year,
                  quarter: _controller.quarter,
                  availableYears: List<int>.from(_controller.availableYears),
                  onYearChanged: (y) {
                    _controller.updateSharedFilter(
                      year: y,
                      quarter: y == null ? null : _controller.quarter,
                    );
                  },
                  onQuarterChanged: (q) {
                    _controller.updateSharedFilter(
                      year: _controller.year,
                      quarter: _controller.year == null ? null : q,
                    );
                  },
                ),
              ),
            ),
            InlineLoadingBar(visible: _controller.updating),
            const SizedBox(height: 16),
            if (_controller.error != null) ...[
              ErrorBanner(message: _controller.error!),
              const SizedBox(height: 12),
            ],
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: [
                SummaryCard(
                  title: 'إيرادات بدون ضريبة',
                  value: formatSar(kpis?.totalProjectValueWithoutVat ?? '0'),
                  icon: Icons.attach_money,
                  accent: const Color(0xFF4F9E8D),
                ),
                SummaryCard(
                  title: 'إجمالي التكاليف',
                  value: formatSar(kpis?.totalCosts ?? '0'),
                  icon: Icons.payments_outlined,
                  accent: const Color(0xFFF59E0B),
                ),
                SummaryCard(
                  title: 'هامش الربح',
                  value: formatPercent(kpis?.profitMargin ?? '0'),
                  icon: Icons.percent,
                  accent: const Color(0xFF3B82F6),
                ),
                SummaryCard(
                  title: 'المحصّل',
                  value: formatSar(kpis?.totalCollectedAmount ?? '0'),
                  icon: Icons.account_balance_wallet_outlined,
                  accent: const Color(0xFF10B981),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ReportCard(
              title: 'تقرير الإيرادات',
              subtitle: 'قيمة المشاريع بدون ضريبة',
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FinanceReportScreen(
                      title: 'تقرير الإيرادات',
                      reportType: 'REVENUE_REPORT',
                      from: range.from,
                      to: range.to,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ReportCard(
              title: 'تقرير تكاليف الفريق',
              subtitle: 'إجمالي رواتب الفريق حسب الشخص',
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FinanceReportScreen(
                      title: 'تقرير تكاليف الفريق',
                      reportType: 'TEAM_COSTS_REPORT',
                      from: range.from,
                      to: range.to,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ReportCard(
              title: 'تقرير التحصيل',
              subtitle: 'جميع التحصيلات المسجلة',
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FinanceReportScreen(
                      title: 'تقرير التحصيل',
                      reportType: 'COLLECTIONS_REPORT',
                      from: range.from,
                      to: range.to,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onOpen;

  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(color: AppTheme.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
