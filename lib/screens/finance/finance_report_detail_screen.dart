import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import 'finance_filters.dart';
import 'finance_project_detail_screen.dart';
import 'finance_results.dart';
import 'finance_ui.dart';

class FinanceReportDetailScreen extends StatefulWidget {
  final String type;
  final FinanceQuery query;

  const FinanceReportDetailScreen(
      {super.key, required this.type, required this.query});

  @override
  State<FinanceReportDetailScreen> createState() =>
      _FinanceReportDetailScreenState();
}

class _FinanceReportDetailScreenState extends State<FinanceReportDetailScreen> {
  late FinanceQuery _query;
  FinanceDataPage? _data;
  bool _loading = true;
  String? _error;
  String? _exporting;
  int _requestId = 0;

  bool get _isComparison => widget.type == 'comparison';
  bool get _isAging => widget.type == 'aging';
  bool get _canExport =>
      AppServices.session.access.value?.actions.contains('finance.export') ??
      false;

  void _accessChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    AppServices.session.access.addListener(_accessChanged);
    _query = _isComparison && widget.query.year == null
        ? widget.query.copyWith(year: DateTime.now().year)
        : widget.query;
    if (widget.type == 'profitability' && _query.sortField == null) {
      _query = _query.copyWith(sortField: 'netProfit', sortDir: 'desc');
    }
    _load();
  }

  @override
  void dispose() {
    AppServices.session.access.removeListener(_accessChanged);
    super.dispose();
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result =
          await AppServices.finance.getMobileReport(widget.type, _query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _data = null;
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _change(FinanceQuery query) {
    setState(() => _query = query.copyWith(page: 1));
    _load();
  }

  Future<void> _filters() async {
    final changed = await showFinanceFilters(context, _query,
        includeCategory: widget.type == 'costs', includeDates: !_isComparison);
    if (changed == null) return;
    if (_isComparison) {
      if (changed.year == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.tr(
          en: 'Choose a year for comparison.',
          ar: 'اختر سنة للمقارنة.',
        ))));
        return;
      }
      _change(changed.copyWith(
          compare:
              changed.quarter == 'ALL' ? 'previous-year' : 'previous-quarter'));
    } else {
      _change(changed);
    }
  }

  Future<void> _export(String format) async {
    if (!_canExport || _exporting != null || _data?.unavailable == true) return;
    setState(() => _exporting = format);
    try {
      final result = await AppServices.finance.exportReport(
        widget.type,
        format,
        _query,
        locale: Localizations.localeOf(context).languageCode,
      );
      if (!mounted) return;
      await AppServices.financeExports.share(result, context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _exporting = null);
    }
  }

  List<(String id, String name)> _groupOptions(BuildContext context) =>
      switch (widget.type) {
        'revenue' => [
            ('project', context.tr(en: 'Project', ar: 'المشروع')),
            ('period', context.tr(en: 'Period', ar: 'الفترة')),
            ('client', context.tr(en: 'Client', ar: 'العميل')),
            (
              'operator',
              context.tr(en: 'Operating company', ar: 'الشركة المشغلة')
            ),
          ],
        'costs' => [
            ('project', context.tr(en: 'Project', ar: 'المشروع')),
            ('period', context.tr(en: 'Period', ar: 'الفترة')),
            ('category', context.tr(en: 'Category', ar: 'الفئة')),
          ],
        'cash-flow' => [
            ('month', context.tr(en: 'Month', ar: 'الشهر')),
            ('quarter', context.tr(en: 'Quarter', ar: 'الربع')),
          ],
        'entities' => [
            ('client', context.tr(en: 'Client', ar: 'العميل')),
            (
              'operator',
              context.tr(en: 'Operating company', ar: 'الشركة المشغلة')
            ),
          ],
        _ => [],
      };

  String _label(BuildContext context, String field) => switch (field) {
        'contractValueWithoutVat' =>
          context.tr(en: 'Contract excluding VAT', ar: 'العقد بدون الضريبة'),
        'contractValueWithVat' =>
          context.tr(en: 'Contract including VAT', ar: 'العقد شامل الضريبة'),
        'vatAmount' => context.tr(en: 'VAT', ar: 'الضريبة'),
        'collectedAmount' => context.tr(en: 'Collected', ar: 'المحصّل'),
        'historicalCollectedAmount' =>
          context.tr(en: 'Collected to date', ar: 'إجمالي المحصّل تاريخيًا'),
        'outstandingAmount' => context.tr(en: 'Outstanding', ar: 'غير المحصّل'),
        'collectionRate' =>
          context.tr(en: 'Collection rate', ar: 'نسبة التحصيل'),
        'teamCosts' => context.tr(en: 'Team costs', ar: 'تكاليف الفريق'),
        'otherCosts' => context.tr(en: 'Other costs', ar: 'تكاليف أخرى'),
        'totalCosts' => context.tr(en: 'Total costs', ar: 'إجمالي التكاليف'),
        'netProfit' => context.tr(en: 'Net profit', ar: 'صافي الربح'),
        'profitMargin' => context.tr(en: 'Profit margin', ar: 'هامش الربح'),
        'projectCount' => context.tr(en: 'Projects', ar: 'المشاريع'),
        'collectionCount' => context.tr(en: 'Collections', ar: 'التحصيلات'),
        _ => field,
      };

  List<String> _fields() => switch (widget.type) {
        'revenue' => ['contractValueWithoutVat', 'projectCount'],
        'collection-status' => [
            'contractValueWithVat',
            'collectedAmount',
            'outstandingAmount',
            'collectionRate'
          ],
        'costs' => ['teamCosts', 'otherCosts', 'totalCosts'],
        'profitability' => [
            'contractValueWithoutVat',
            'totalCosts',
            'netProfit',
            'profitMargin'
          ],
        'vat' => [
            'contractValueWithoutVat',
            'vatAmount',
            'contractValueWithVat'
          ],
        'cash-flow' => ['collectedAmount', 'collectionCount'],
        'entities' => [
            'contractValueWithoutVat',
            'collectedAmount',
            'outstandingAmount',
            'totalCosts',
            'netProfit',
            'collectionRate',
            'projectCount'
          ],
        'comparison' => [
            'contractValueWithoutVat',
            'collectedAmount',
            'outstandingAmount',
            'totalCosts',
            'netProfit',
            'collectionRate',
            'projectCount'
          ],
        _ => [],
      };

  String _displayValue(String field, Object? value) {
    if (field.endsWith('Rate') || field == 'profitMargin') {
      return financePercent(value);
    }
    if (field.endsWith('Count')) return toLatinDigits(value?.toString() ?? '—');
    return financeMoney(value);
  }

  Widget _reportSummary(BuildContext context, FinanceDataPage data) {
    if (data.totals.isEmpty) return const SizedBox.shrink();
    return FinanceSurface(
      color: AppTheme.dashboardMint,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.tr(en: 'Report totals', ar: 'إجماليات التقرير'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        for (final field in _fields())
          if (data.totals.containsKey(field))
            FinanceLabelValue(
              label: _label(context, field),
              value: _displayValue(field, data.totals[field]),
              prominent: field == _fields().first,
            ),
      ]),
    );
  }

  Widget _comparisonChanges(BuildContext context, FinanceDataPage data) {
    if (!_isComparison || data.deltas.isEmpty) return const SizedBox.shrink();
    const fields = [
      'contractValueWithoutVat',
      'collectedAmount',
      'outstandingAmount',
      'totalCosts',
      'netProfit',
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: FinanceSurface(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              context.tr(
                  en: 'Change vs previous period',
                  ar: 'التغير عن الفترة السابقة'),
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final field in fields)
            if (data.deltas[field] is Map)
              FinanceLabelValue(
                label: _label(context, field),
                value:
                    '${financeMoney((data.deltas[field] as Map)['changeAmount'])}  ·  '
                    '${financePercent((data.deltas[field] as Map)['changePercent'])}',
              ),
        ],
      )),
    );
  }

  Widget _reportRow(BuildContext context, Map<String, dynamic> row) {
    final rawTitle = financeField(row, [
      'projectName',
      'groupName',
      'entityName',
      'periodLabel',
      'period',
      'category'
    ]);
    final title = widget.type == 'costs' && row['category'] != null
        ? financeCostCategory(context, row['category'])
        : rawTitle == 'Unassigned'
            ? context.tr(en: 'Unassigned', ar: 'غير محدد')
            : rawTitle;
    final subtitle = financeField(row, ['clientName', 'operatingCompanyName']);
    final projectId = row['projectId']?.toString();
    final category = widget.type == 'costs' && _query.groupBy == 'category'
        ? row['category']?.toString()
        : null;
    return FinanceSurface(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: projectId != null
            ? () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) =>
                    FinanceProjectDetailScreen(projectId: projectId)))
            : category != null
                ? () => _change(
                    _query.copyWith(costCategory: category, groupBy: 'project'))
                : null,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            if (subtitle != '—') ...[
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
            ],
            const SizedBox(height: 8),
            for (final field in _fields())
              if (row.containsKey(field))
                FinanceLabelValue(
                  label: _label(context, field),
                  value: _displayValue(field, row[field]),
                  prominent: field == _fields().first,
                ),
            if (projectId != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                    context.tr(
                        en: 'View project finance →',
                        ar: 'عرض مالية المشروع ←'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            if (category != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                    context.tr(
                        en: 'View projects in this category →',
                        ar: 'عرض مشاريع هذه الفئة ←'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800)),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _cashFlowChart(BuildContext context, FinanceDataPage data) {
    if (widget.type != 'cash-flow' || data.rows.isEmpty) {
      return const SizedBox.shrink();
    }
    // Geometry only: every value is supplied and aggregated by the server.
    final values = data.rows
        .map((row) => parseFinancialValue(row['collectedAmount']))
        .toList();
    final maximum = values
        .whereType<double>()
        .fold<double>(0, (max, value) => value > max ? value : max);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FinanceSurface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              context.tr(
                  en: 'Collections on this page',
                  ar: 'التحصيلات في هذه الصفحة'),
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.rows.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final row = data.rows[index];
                final value = values[index] ?? 0;
                final fraction =
                    maximum <= 0 ? 0.0 : (value / maximum).clamp(0.0, 1.0);
                return SizedBox(
                  width: 54,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: fraction == 0 ? .02 : fraction,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: AppTheme.ink,
                                    borderRadius: BorderRadius.circular(8))),
                          ),
                        )),
                        const SizedBox(height: 8),
                        Text(financeField(row, ['period']),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.muted)),
                      ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupOptions(context);
    final data = _data;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(title: Text(financeReportTitle(context, widget.type))),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
          children: [
            if (_isAging && data?.unavailable == true) ...[
              FinanceSurface(
                color: AppTheme.dashboardPaper,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          context.tr(
                              en: 'Aging report is not available yet',
                              ar: 'تقرير أعمار المستحقات غير متاح بعد'),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 9),
                      Text(
                          context.tr(
                            en: 'The system has no verified receivable due date. Project completion dates cannot be used to calculate aging buckets.',
                            ar: 'لا يوجد في النظام تاريخ استحقاق مالي موثّق. لا يمكن استخدام تاريخ انتهاء المشروع لحساب أعمار المستحقات.',
                          ),
                          style: const TextStyle(
                              color: AppTheme.muted, fontSize: 13)),
                    ]),
              ),
            ] else ...[
              FinanceQueryBar(
                initialSearch: _query.search,
                onSearch: (value) => _change(value.trim().isEmpty
                    ? _query.copyWith(clearSearch: true)
                    : _query.copyWith(search: value.trim())),
                onFilters: _filters,
              ),
              if (groups.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('finance-report-group-${_query.groupBy}'),
                  initialValue: _query.groupBy ?? groups.first.$1,
                  decoration: InputDecoration(
                      labelText: context.tr(en: 'Group by', ar: 'التجميع حسب')),
                  items: groups
                      .map((item) => DropdownMenuItem(
                          value: item.$1, child: Text(item.$2)))
                      .toList(),
                  onChanged: (value) =>
                      _change(_query.copyWith(groupBy: value)),
                ),
              ],
              if (widget.type == 'profitability') ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: DropdownButtonFormField<String>(
                    key: ValueKey('finance-profit-sort-${_query.sortField}'),
                    initialValue: _query.sortField ?? 'netProfit',
                    decoration: InputDecoration(
                      labelText: context.tr(en: 'Rank by', ar: 'الترتيب حسب'),
                    ),
                    items: [
                      (
                        'netProfit',
                        context.tr(en: 'Net profit', ar: 'صافي الربح')
                      ),
                      (
                        'profitMargin',
                        context.tr(en: 'Profit margin', ar: 'هامش الربح')
                      ),
                      (
                        'contractValueWithoutVat',
                        context.tr(en: 'Contract value', ar: 'قيمة العقد')
                      ),
                      (
                        'totalCosts',
                        context.tr(en: 'Total costs', ar: 'إجمالي التكاليف')
                      ),
                    ]
                        .map((item) => DropdownMenuItem(
                            value: item.$1, child: Text(item.$2)))
                        .toList(),
                    onChanged: (value) =>
                        _change(_query.copyWith(sortField: value)),
                  )),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip:
                        context.tr(en: 'Reverse ranking', ar: 'عكس الترتيب'),
                    onPressed: () => _change(_query.copyWith(
                      sortField: _query.sortField ?? 'netProfit',
                      sortDir: _query.sortDir == 'asc' ? 'desc' : 'asc',
                    )),
                    icon: const Icon(Icons.swap_vert_rounded),
                  ),
                ]),
              ],
              if (_isComparison) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(
                      'finance-report-compare-${_query.quarter}-${_query.compare}'),
                  initialValue: _query.compare ??
                      (_query.quarter == 'ALL'
                          ? 'previous-year'
                          : 'previous-quarter'),
                  decoration: InputDecoration(
                      labelText:
                          context.tr(en: 'Compare with', ar: 'المقارنة مع')),
                  items: _query.quarter == 'ALL'
                      ? [
                          DropdownMenuItem(
                              value: 'previous-year',
                              child: Text(context.tr(
                                  en: 'Previous year', ar: 'السنة السابقة')))
                        ]
                      : [
                          DropdownMenuItem(
                              value: 'previous-quarter',
                              child: Text(context.tr(
                                  en: 'Previous quarter', ar: 'الربع السابق'))),
                          DropdownMenuItem(
                              value: 'same-quarter-last-year',
                              child: Text(context.tr(
                                  en: 'Same quarter last year',
                                  ar: 'نفس الربع السنة الماضية'))),
                        ],
                  onChanged: (value) =>
                      _change(_query.copyWith(compare: value)),
                ),
              ],
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                  onPressed: _canExport &&
                          _exporting == null &&
                          !_loading &&
                          data != null
                      ? () => _export('pdf')
                      : null,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(context.tr(en: 'Export PDF', ar: 'تصدير PDF')),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: OutlinedButton.icon(
                  onPressed: _canExport &&
                          _exporting == null &&
                          !_loading &&
                          data != null
                      ? () => _export('xlsx')
                      : null,
                  icon: const Icon(Icons.table_chart_outlined),
                  label:
                      Text(context.tr(en: 'Export Excel', ar: 'تصدير Excel')),
                )),
              ]),
              if (!_canExport)
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                      context.tr(
                        en: 'Your access does not include report export.',
                        ar: 'صلاحيتك لا تشمل تصدير التقارير.',
                      ),
                      style:
                          const TextStyle(color: AppTheme.muted, fontSize: 12)),
                ),
              if (_exporting != null)
                const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 14),
            ],
            if (_isAging && data?.unavailable == true)
              const SizedBox.shrink()
            else
              FinanceResults(
                data: data,
                error: _error,
                loading: _loading,
                onRetry: _load,
                onPage: (page) {
                  setState(() => _query = _query.copyWith(page: page));
                  _load();
                },
                header: data == null
                    ? null
                    : Column(children: [
                        _reportSummary(context, data),
                        _comparisonChanges(context, data),
                        const SizedBox(height: 14),
                        _cashFlowChart(context, data),
                      ]),
                rowBuilder: _reportRow,
              ),
          ],
        ),
      )),
    );
  }
}
