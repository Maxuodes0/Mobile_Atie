import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import 'finance_filters.dart';
import 'finance_project_detail_screen.dart';
import 'finance_results.dart';
import 'finance_ui.dart';

class FinanceDrilldownScreen extends StatefulWidget {
  final String metric;
  final String title;
  final FinanceQuery query;

  const FinanceDrilldownScreen(
      {super.key,
      required this.metric,
      required this.title,
      required this.query});

  @override
  State<FinanceDrilldownScreen> createState() => _FinanceDrilldownScreenState();
}

class _FinanceDrilldownScreenState extends State<FinanceDrilldownScreen> {
  late FinanceQuery _query;
  FinanceDataPage? _data;
  bool _loading = true;
  String? _error;
  int _ticket = 0;

  bool get _isRate => widget.metric == 'collectionRate';
  bool get _isCollection => widget.metric == 'collected' || _isRate;

  @override
  void initState() {
    super.initState();
    _query = widget.query;
    _load();
  }

  Future<void> _load() async {
    final ticket = ++_ticket;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result =
          await AppServices.finance.getKpiDetails(widget.metric, _query);
      if (!mounted || ticket != _ticket) return;
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || ticket != _ticket) return;
      setState(() {
        _data = null;
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _change(FinanceQuery query) {
    setState(() => _query = query);
    _load();
  }

  Future<void> _filters() async {
    final changed = await showFinanceFilters(context, _query,
        includeCategory: widget.metric == 'costs');
    if (changed != null) _change(changed);
  }

  void _openProject(String? id) {
    if (id == null || id.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => FinanceProjectDetailScreen(projectId: id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final display = _isRate ? financePercent : financeMoney;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
          children: [
            FinanceQueryBar(
              initialSearch: _query.search,
              onSearch: (value) => _change(value.trim().isEmpty
                  ? _query.copyWith(clearSearch: true, page: 1)
                  : _query.copyWith(search: value.trim(), page: 1)),
              onFilters: _filters,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                initialValue: _query.sortField ?? 'date',
                decoration: InputDecoration(
                    labelText: context.tr(en: 'Sort by', ar: 'ترتيب حسب')),
                items: [
                  DropdownMenuItem(
                      value: 'date',
                      child: Text(context.tr(en: 'Date', ar: 'التاريخ'))),
                  DropdownMenuItem(
                      value: 'startDate',
                      child: Text(context.tr(
                          en: 'Project start', ar: 'بداية المشروع'))),
                  DropdownMenuItem(
                      value: 'name',
                      child: Text(context.tr(en: 'Project', ar: 'المشروع'))),
                  DropdownMenuItem(
                      value: 'value',
                      child: Text(context.tr(en: 'Amount', ar: 'المبلغ'))),
                ],
                onChanged: (value) =>
                    _change(_query.copyWith(sortField: value, page: 1)),
              )),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: context.tr(en: 'Reverse order', ar: 'عكس الترتيب'),
                onPressed: () => _change(_query.copyWith(
                    sortDir: _query.sortDir == 'asc' ? 'desc' : 'asc',
                    page: 1)),
                icon: const Icon(Icons.swap_vert_rounded),
              ),
            ]),
            const SizedBox(height: 14),
            FinanceResults(
              data: data,
              error: _error,
              loading: _loading,
              onRetry: _load,
              onPage: (page) => _change(_query.copyWith(page: page)),
              header: data == null
                  ? null
                  : Column(children: [
                      FinanceSurface(
                        color: AppTheme.dashboardMint,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  context.tr(
                                      en: 'Dashboard card total',
                                      ar: 'إجمالي بطاقة الداشبورد'),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(display(data.cardTotal),
                                  style: const TextStyle(
                                      fontSize: 29,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 10),
                              FinanceLabelValue(
                                label: context.tr(
                                    en: 'Filtered total',
                                    ar: 'الإجمالي بعد الفلترة'),
                                value: display(data.filteredTotal),
                                prominent: true,
                              ),
                            ]),
                      ),
                      const SizedBox(height: 10),
                      FinanceSurface(
                        child: Row(children: [
                          Icon(
                              data.matchesCard == true
                                  ? Icons.verified_outlined
                                  : Icons.filter_alt_outlined,
                              color: AppTheme.ink),
                          const SizedBox(width: 9),
                          Expanded(
                              child: Text(
                                  data.matchesCard == true
                                      ? context.tr(
                                          en:
                                              'Matches the dashboard period total',
                                          ar: 'يطابق إجمالي فترة الداشبورد')
                                      : context.tr(
                                          en:
                                              'Additional filters narrow this view',
                                          ar:
                                              'الفلاتر الإضافية ضيّقت هذه النتائج'),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700))),
                        ]),
                      ),
                      if (_isRate && data.basis.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        FinanceSurface(
                            child: Column(children: [
                          FinanceLabelValue(
                              label: context.tr(
                                  en: 'Collected (rate basis)',
                                  ar: 'المحصّل (أساس النسبة)'),
                              value:
                                  financeMoney(data.basis['collectedAmount'])),
                          FinanceLabelValue(
                              label: context.tr(
                                  en: 'Contract including VAT (rate basis)',
                                  ar: 'العقد شامل الضريبة (أساس النسبة)'),
                              value: financeMoney(
                                  data.basis['contractValueWithVat'])),
                        ])),
                      ],
                    ]),
              rowBuilder: (context, row) => FinanceSurface(
                padding: EdgeInsets.zero,
                child: InkWell(
                  onTap: () => _openProject(row['projectId']?.toString()),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(financeField(row, ['projectName', 'name']),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(
                              financeField(
                                  row, ['clientName', 'operatingCompanyName']),
                              style: const TextStyle(
                                  color: AppTheme.muted, fontSize: 12)),
                          const SizedBox(height: 8),
                          FinanceLabelValue(
                            label: context.tr(en: 'Amount', ar: 'المبلغ'),
                            value: financeMoney(_isCollection
                                ? row['collectedAmount'] ?? row['amount']
                                : row['value']),
                            prominent: true,
                          ),
                          FinanceLabelValue(
                            label: context.tr(en: 'Date', ar: 'التاريخ'),
                            value: financeDate(_isCollection
                                ? row['collectedDate']
                                : row['startDate']),
                          ),
                        ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
