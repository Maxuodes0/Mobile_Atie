import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
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
      return const Scaffold(
        backgroundColor: AppTheme.pageBg,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final kpis = _controller.data?.kpis;
    final range = computePeriodRange(
        year: _controller.year, quarter: _controller.quarter);

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              _controller.load(refreshYears: true, forceRefresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              AppPageHeader(
                title: context.tr(en: 'Finance', ar: 'المالية'),
                subtitle: context.tr(
                  en: 'Revenue and cost reports',
                  ar: 'تقارير الإيرادات والتكاليف',
                ),
                showLogout: false,
                showBack: Navigator.of(context).canPop(),
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
                TextButton.icon(
                  onPressed: () => _controller.load(forceRefresh: true),
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr(en: 'Retry', ar: 'إعادة المحاولة')),
                ),
                const SizedBox(height: 12),
              ],
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.94,
                children: [
                  SummaryCard(
                    title: context.tr(
                        en: 'Revenue excl. VAT', ar: 'إيرادات بدون ضريبة'),
                    value: formatSar(kpis?.totalProjectValueWithoutVat),
                    icon: Icons.attach_money,
                    accent: AppTheme.ink,
                  ),
                  SummaryCard(
                    title: context.tr(en: 'Total costs', ar: 'إجمالي التكاليف'),
                    value: formatSar(kpis?.totalCosts),
                    icon: Icons.payments_outlined,
                    accent: AppTheme.accent,
                  ),
                  SummaryCard(
                    title: context.tr(en: 'Profit margin', ar: 'هامش الربح'),
                    value: formatPercent(kpis?.profitMargin),
                    icon: Icons.percent,
                    accent: AppTheme.ink,
                  ),
                  SummaryCard(
                    title: context.tr(en: 'Collected', ar: 'المحصّل'),
                    value: formatSar(kpis?.totalCollectedAmount),
                    icon: Icons.account_balance_wallet_outlined,
                    accent: AppTheme.accent,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ReportCard(
                title: context.tr(en: 'Revenue report', ar: 'تقرير الإيرادات'),
                subtitle: context.tr(
                  en: 'Project value excluding VAT',
                  ar: 'قيمة المشاريع بدون ضريبة',
                ),
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => FinanceReportScreen(
                        title: context.tr(
                            en: 'Revenue report', ar: 'تقرير الإيرادات'),
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
                title: context.tr(
                    en: 'Team costs report', ar: 'تقرير تكاليف الفريق'),
                subtitle: context.tr(
                  en: 'Total team pay by person',
                  ar: 'إجمالي رواتب الفريق حسب الشخص',
                ),
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => FinanceReportScreen(
                        title: context.tr(
                            en: 'Team costs report', ar: 'تقرير تكاليف الفريق'),
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
                title:
                    context.tr(en: 'Collections report', ar: 'تقرير التحصيل'),
                subtitle: context.tr(
                  en: 'All recorded collections',
                  ar: 'جميع التحصيلات المسجلة',
                ),
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => FinanceReportScreen(
                        title: context.tr(
                            en: 'Collections report', ar: 'تقرير التحصيل'),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
        ),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        )),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
