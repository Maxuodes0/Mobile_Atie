import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import 'finance_filters.dart';
import 'finance_project_detail_screen.dart';
import 'finance_results.dart';
import 'finance_ui.dart';

class FinanceCostsScreen extends StatefulWidget {
  final FinanceQuery query;

  const FinanceCostsScreen({super.key, required this.query});

  @override
  State<FinanceCostsScreen> createState() => _FinanceCostsScreenState();
}

class _FinanceCostsScreenState extends State<FinanceCostsScreen> {
  late FinanceQuery _query;
  FinanceDataPage? _data;
  bool _loading = true;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _query = widget.query;
    _load();
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await AppServices.finance.getCosts(_query);
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
    setState(() => _query = query);
    _load();
  }

  Future<void> _filters() async {
    final query =
        await showFinanceFilters(context, _query, includeCategory: true);
    if (query != null) _change(query);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.pageBg,
        appBar: AppBar(
            title:
                Text(context.tr(en: 'Project costs', ar: 'تكاليف المشاريع'))),
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
                const SizedBox(height: 14),
                FinanceResults(
                  data: _data,
                  error: _error,
                  loading: _loading,
                  onRetry: _load,
                  onPage: (page) => _change(_query.copyWith(page: page)),
                  header: _data == null
                      ? null
                      : FinanceSurface(
                          color: AppTheme.dashboardMint,
                          child: FinanceLabelValue(
                            label: context.tr(
                              en: 'Filtered costs total',
                              ar: 'إجمالي التكاليف المفلترة',
                            ),
                            value: financeMoney(_data!.filteredTotal),
                            prominent: true,
                          ),
                        ),
                  rowBuilder: (context, row) => FinanceSurface(
                    padding: EdgeInsets.zero,
                    child: InkWell(
                      onTap: row['projectId'] == null
                          ? null
                          : () => Navigator.of(context)
                                  .push(MaterialPageRoute<void>(
                                builder: (_) => FinanceProjectDetailScreen(
                                  projectId: row['projectId'].toString(),
                                ),
                              )),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(17),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              financeField(row, ['projectName', 'name']),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              financeField(
                                  row, ['clientName', 'operatingCompanyName']),
                              style: const TextStyle(
                                  color: AppTheme.muted, fontSize: 13),
                            ),
                            const SizedBox(height: 7),
                            FinanceLabelValue(
                              label: context.tr(
                                  en: 'Total costs', ar: 'إجمالي التكاليف'),
                              value: financeMoney(row['totalCosts']),
                              prominent: true,
                            ),
                            FinanceLabelValue(
                              label: context.tr(
                                  en: 'Team costs', ar: 'تكاليف الفريق'),
                              value: financeMoney(row['teamCosts']),
                            ),
                            FinanceLabelValue(
                              label: context.tr(
                                  en: 'Other costs', ar: 'التكاليف الأخرى'),
                              value: financeMoney(row['otherCosts']),
                            ),
                            FinanceLabelValue(
                              label: context.tr(
                                  en: 'Project start', ar: 'بداية المشروع'),
                              value: financeDate(row['startDate']),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
