import 'package:flutter/material.dart';

import '../data/models/finance_dashboard.dart';
import '../data/models/finance_module.dart';
import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_page_header.dart';
import 'finance/finance_collections_screen.dart';
import 'finance/finance_costs_screen.dart';
import 'finance/finance_drilldown_screen.dart';
import 'finance/finance_reports_screen.dart';
import 'finance/finance_ui.dart';

class FinanceScreen extends StatefulWidget {
  final bool isActive;
  const FinanceScreen({super.key, required this.isActive});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  FinanceQuery _query = FinanceQuery(year: DateTime.now().year);
  FinanceDashboard? _dashboard;
  List<int> _years = const [];
  bool _loading = true;
  bool _updating = false;
  String? _error;
  int _requestId = 0;
  bool _loaded = false;

  bool get _canReadReports {
    final role = AppServices.session.user.value?.role.toUpperCase();
    final screen = role == 'ADMIN'
        ? 'admin.finance.reports'
        : role == 'PROGRAM_MANAGER'
            ? 'programManager.finance.reports'
            : null;
    final access = AppServices.session.access.value;
    return screen != null &&
        access != null &&
        access.actions.contains('finance.read') &&
        access.screens.contains(screen);
  }

  void _accessChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    AppServices.session.access.addListener(_accessChanged);
    if (widget.isActive) _load();
  }

  @override
  void dispose() {
    AppServices.session.access.removeListener(_accessChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FinanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive && !_loaded) _load();
  }

  Future<void> _load({bool refresh = false}) async {
    _loaded = true;
    final ticket = ++_requestId;
    setState(() {
      _error = null;
      _loading = _dashboard == null;
      _updating = _dashboard != null;
    });
    try {
      final results = await Future.wait<dynamic>([
        AppServices.finance.getDashboard(
          year: _query.year,
          quarter: _query.quarter,
          forceRefresh: refresh,
        ),
        if (_years.isEmpty || refresh)
          AppServices.finance
              .availableYears(forceRefresh: refresh)
              .catchError((_) => <int>[]),
      ]);
      if (!mounted || ticket != _requestId) return;
      setState(() {
        _dashboard = results[0] as FinanceDashboard;
        if (results.length > 1) _years = results[1] as List<int>;
        _loading = false;
        _updating = false;
      });
    } catch (error) {
      if (!mounted || ticket != _requestId) return;
      setState(() {
        _error = error.toString();
        _loading = false;
        _updating = false;
        _dashboard =
            null; // A failed calculation must not look like genuine zero finance data.
      });
    }
  }

  void _periodChanged(FinanceQuery next) {
    setState(() => _query = next.copyWith(page: 1));
    _load();
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted && widget.isActive) _load();
  }

  @override
  Widget build(BuildContext context) {
    final kpis = _dashboard?.kpis;
    final metrics =
        <({String id, String value, String caption, Color bg, Color fg})>[
      (
        id: 'contractValue',
        value: financeMoney(kpis?.totalProjectValueWithoutVat),
        caption: context.tr(en: 'Excluding VAT', ar: 'بدون الضريبة'),
        bg: AppTheme.dashboardPaper,
        fg: AppTheme.dashboardInk
      ),
      (
        id: 'collected',
        value: financeMoney(kpis?.totalCollectedAmount),
        caption: context.tr(
            en: 'Received by collection date', ar: 'حسب تاريخ التحصيل'),
        bg: AppTheme.dashboardMint,
        fg: AppTheme.dashboardInk
      ),
      (
        id: 'uncollected',
        value: financeMoney(
            kpis?.allTimeOutstandingAmount ?? kpis?.outstandingAmount),
        caption: context.tr(
            en: 'All outstanding, across all years',
            ar: 'كامل المبلغ غير المحصّل لكل السنوات'),
        bg: const Color(0xFFE2DDD7),
        fg: AppTheme.dashboardInk
      ),
      (
        id: 'costs',
        value: financeMoney(kpis?.totalCosts),
        caption:
            context.tr(en: 'Team and other costs', ar: 'تكاليف الفريق وغيرها'),
        bg: AppTheme.dashboardGraphite,
        fg: Colors.white
      ),
      (
        id: 'netProfit',
        value: financeMoney(kpis?.netProfit),
        caption: context.tr(
            en: 'Excluding VAT less costs', ar: 'بدون الضريبة بعد التكاليف'),
        bg: AppTheme.dashboardInk,
        fg: Colors.white
      ),
      if (_query.year == null)
        (
          id: 'collectionRate',
          value: financePercent(kpis?.collectionRate),
          caption:
              context.tr(en: 'Finance methodology', ar: 'وفق منهجية المالية'),
          bg: const Color(0xFFB8CEC6),
          fg: AppTheme.dashboardInk
        ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _load(refresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
            children: [
              AppPageHeader(
                title: context.tr(en: 'Finance', ar: 'المالية'),
                subtitle: context.tr(
                    en: 'Your financial picture, one period at a time',
                    ar: 'الصورة المالية للفترة التي تختارها'),
                showLogout: false,
                showBack: Navigator.of(context).canPop(),
              ),
              const SizedBox(height: 18),
              FinancePeriodPicker(
                year: _query.year,
                quarter: _query.quarter,
                availableYears: _years,
                onYearChanged: (year) => _periodChanged(year == null
                    ? _query.copyWith(clearYear: true, quarter: 'ALL')
                    : _query.copyWith(year: year)),
                onQuarterChanged: (quarter) =>
                    _periodChanged(_query.copyWith(quarter: quarter)),
              ),
              if (_updating) const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 22),
              Text(context.tr(en: 'Overview', ar: 'نظرة عامة'),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(
                  context.tr(
                      en: 'Tap a card to see the reconciled details.',
                      ar: 'اضغط على البطاقة لعرض التفاصيل المطابقة.'),
                  style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
              const SizedBox(height: 16),
              if (_loading)
                const SizedBox(
                    height: 208,
                    child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                FinanceErrorState(message: _error, onRetry: _load)
              else ...[
                SizedBox(
                  height: 202,
                  child: ListView.separated(
                    key: const ValueKey('finance-kpi-scroll'),
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: metrics.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final metric = metrics[index];
                      return FinanceMetricCard(
                        key: ValueKey('finance-kpi-${metric.id}'),
                        title: financeMetricTitle(context, metric.id),
                        value: metric.value,
                        caption: metric.caption,
                        color: metric.bg,
                        foreground: metric.fg,
                        onTap: () => _open(FinanceDrilldownScreen(
                          metric: metric.id,
                          title: financeMetricTitle(context, metric.id),
                          query: metric.id == 'uncollected'
                              ? _query.copyWith(clearYear: true, quarter: 'ALL')
                              : _query,
                        )),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(context.tr(en: 'Explore', ar: 'استكشف'),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                FinanceActionTile(
                  title: context.tr(en: 'Collections', ar: 'التحصيلات'),
                  subtitle: context.tr(
                      en: 'Payments received and their projects',
                      ar: 'المبالغ المحصلة ومشاريعها'),
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => _open(FinanceCollectionsScreen(query: _query)),
                ),
                const SizedBox(height: 10),
                FinanceActionTile(
                  title: context.tr(en: 'Cost breakdown', ar: 'تفصيل التكاليف'),
                  subtitle: context.tr(
                      en: 'Team, other, and total costs',
                      ar: 'تكاليف الفريق وغيرها والإجمالي'),
                  icon: Icons.receipt_long_outlined,
                  onTap: () => _open(FinanceCostsScreen(query: _query)),
                ),
                const SizedBox(height: 10),
                if (_canReadReports)
                  FinanceActionTile(
                    title: context.tr(
                        en: 'Financial reports', ar: 'التقارير المالية'),
                    subtitle: context.tr(
                        en: 'Revenue, profitability, VAT, cash flow and more',
                        ar: 'الإيرادات والربحية والضريبة والتدفق النقدي والمزيد'),
                    icon: Icons.insights_outlined,
                    onTap: () => _open(FinanceReportsScreen(query: _query)),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
