import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import 'finance_collections_screen.dart';
import 'finance_project_costs_screen.dart';
import 'finance_ui.dart';

class FinanceProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const FinanceProjectDetailScreen({super.key, required this.projectId});

  @override
  State<FinanceProjectDetailScreen> createState() =>
      _FinanceProjectDetailScreenState();
}

class _FinanceProjectDetailScreenState
    extends State<FinanceProjectDetailScreen> {
  FinanceProjectDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result =
          await AppServices.finance.getProjectFinancialDetail(widget.projectId);
      if (!mounted) return;
      setState(() {
        _detail = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _detail = null;
        _error = error.toString();
        _loading = false;
      });
    }
  }

  String? _amount(FinanceProjectDetail detail, List<String> keys) {
    for (final key in keys) {
      final value = detail.financials[key];
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  String _relatedName(Map<String, dynamic> project, String key) {
    final value = project[key];
    if (value is Map) {
      return financeField(Map<String, dynamic>.from(value), ['name']);
    }
    return '—';
  }

  Future<void> _openHistory(Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final project = detail?.project;
    final projectName = project == null
        ? context.tr(en: 'Project finance', ar: 'مالية المشروع')
        : financeField(project, ['name', 'projectName']);
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
          title: Text(context.tr(en: 'Project finance', ar: 'مالية المشروع'))),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 36),
          children: [
            Text(projectName,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            if (project != null) ...[
              const SizedBox(height: 4),
              Text(
                  _relatedName(project, 'client') != '—'
                      ? _relatedName(project, 'client')
                      : _relatedName(project, 'operatingCompany'),
                  style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            if (_loading && detail == null)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              FinanceErrorState(message: _error, onRetry: _load)
            else if (detail != null) ...[
              FinanceSurface(
                color: AppTheme.dashboardMint,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr(en: 'Net profit', ar: 'صافي الربح'),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(financeMoney(_amount(detail, ['netProfit'])),
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w900)),
                      if (_amount(detail, ['profitMargin']) != null) ...[
                        const SizedBox(height: 8),
                        FinanceLabelValue(
                          label:
                              context.tr(en: 'Profit margin', ar: 'هامش الربح'),
                          value:
                              financePercent(_amount(detail, ['profitMargin'])),
                        ),
                      ],
                    ]),
              ),
              const SizedBox(height: 12),
              FinanceSurface(
                  child: Column(children: [
                FinanceLabelValue(
                    label: context.tr(
                        en: 'Contract excluding VAT', ar: 'العقد بدون الضريبة'),
                    value: financeMoney(_amount(detail, [
                      'contractValueWithoutVat',
                      'projectValueWithoutVat'
                    ]))),
                FinanceLabelValue(
                    label: context.tr(en: 'VAT', ar: 'الضريبة'),
                    value: financeMoney(_amount(detail, ['vatAmount', 'vat']))),
                FinanceLabelValue(
                    label: context.tr(
                        en: 'Contract including VAT', ar: 'العقد شامل الضريبة'),
                    value: financeMoney(_amount(detail,
                        ['contractValueWithVat', 'projectValueWithVat'])),
                    prominent: true),
                const Divider(height: 22),
                FinanceLabelValue(
                    label: context.tr(en: 'Team costs', ar: 'تكاليف الفريق'),
                    value: financeMoney(_amount(detail, ['teamCosts']))),
                FinanceLabelValue(
                    label: context.tr(en: 'Other costs', ar: 'التكاليف الأخرى'),
                    value: financeMoney(_amount(detail, ['otherCosts']))),
                FinanceLabelValue(
                    label: context.tr(en: 'Total costs', ar: 'إجمالي التكاليف'),
                    value: financeMoney(_amount(detail, ['totalCosts'])),
                    prominent: true),
                const Divider(height: 22),
                FinanceLabelValue(
                    label: context.tr(en: 'Collected', ar: 'المحصّل'),
                    value: financeMoney(_amount(
                        detail, ['collectedAmount', 'totalCollectedAmount']))),
                FinanceLabelValue(
                    label:
                        context.tr(en: 'Remaining', ar: 'المتبقي غير المحصل'),
                    value: financeMoney(_amount(
                        detail, ['outstandingAmount', 'uncollectedAmount'])),
                    prominent: true),
              ])),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                    child: Text(
                        context.tr(
                            en: 'Collections history', ar: 'سجل التحصيلات'),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900))),
                TextButton(
                    onPressed: () => _openHistory(FinanceCollectionsScreen(
                        query: FinanceQuery(projectId: widget.projectId))),
                    child: Text(context.tr(en: 'See all', ar: 'عرض الكل'))),
              ]),
              if (detail.collections.rows.isEmpty)
                FinanceEmptyState(
                    message: context.tr(
                        en: 'No collections yet', ar: 'لا توجد تحصيلات بعد'))
              else
                ...detail.collections.rows.take(5).map((row) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FinanceSurface(
                          child: Column(children: [
                        FinanceLabelValue(
                            label: context.tr(en: 'Amount', ar: 'المبلغ'),
                            value: financeMoney(
                                row['collectedAmount'] ?? row['amount']),
                            prominent: true),
                        FinanceLabelValue(
                            label: context.tr(en: 'Date', ar: 'التاريخ'),
                            value: financeDate(row['collectedDate'])),
                        if (row['referenceNumber'] != null)
                          FinanceLabelValue(
                              label: context.tr(en: 'Reference', ar: 'المرجع'),
                              value: row['referenceNumber'].toString()),
                      ])),
                    )),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: Text(
                        context.tr(en: 'Cost breakdown', ar: 'تفصيل التكاليف'),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900))),
                TextButton(
                    onPressed: () => _openHistory(
                        FinanceProjectCostsScreen(projectId: widget.projectId)),
                    child: Text(context.tr(en: 'See all', ar: 'عرض الكل'))),
              ]),
              if (detail.costs.rows.isEmpty)
                FinanceEmptyState(
                    message: context.tr(
                        en: 'No costs recorded', ar: 'لا توجد تكاليف مسجلة'))
              else
                ...detail.costs.rows.take(5).map((row) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FinanceSurface(
                          child: Column(children: [
                        FinanceLabelValue(
                            label: row['description']
                                        ?.toString()
                                        .trim()
                                        .isNotEmpty ==
                                    true
                                ? financeField(row, ['description', 'name'])
                                : financeCostCategory(context,
                                    row['category'] ?? row['costType']),
                            value:
                                financeMoney(row['amount'] ?? row['totalCost']),
                            prominent: true),
                        if (row['category'] != null)
                          FinanceLabelValue(
                              label: context.tr(en: 'Category', ar: 'الفئة'),
                              value: financeCostCategory(
                                  context, row['category'])),
                      ])),
                    )),
            ],
          ],
        ),
      )),
    );
  }
}
