import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import 'finance_ui.dart';

/// The global costs endpoint contains project aggregates. Individual cost
/// entries live in the project financial summary's paged costs history.
class FinanceProjectCostsScreen extends StatefulWidget {
  final String projectId;

  const FinanceProjectCostsScreen({super.key, required this.projectId});

  @override
  State<FinanceProjectCostsScreen> createState() =>
      _FinanceProjectCostsScreenState();
}

class _FinanceProjectCostsScreenState extends State<FinanceProjectCostsScreen> {
  FinanceProjectDetail? _detail;
  int _page = 1;
  int _requestId = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await AppServices.finance
          .getProjectFinancialDetail(widget.projectId, page: _page);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _detail = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _detail = null;
        _error = error.toString();
        _loading = false;
      });
    }
  }

  String _dateLabel(BuildContext context, Map<String, dynamic> row) =>
      switch (row['dateBasis']) {
        'costDate' => context.tr(en: 'Cost date', ar: 'تاريخ التكلفة'),
        'invoiceDate' => context.tr(en: 'Invoice date', ar: 'تاريخ الفاتورة'),
        _ => context.tr(en: 'Recorded on', ar: 'تاريخ التسجيل'),
      };

  @override
  Widget build(BuildContext context) {
    final costs = _detail?.costs;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
          title: Text(context.tr(
              en: 'Project cost entries', ar: 'بنود تكلفة المشروع'))),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
          children: [
            if (_detail != null) ...[
              Text(financeField(_detail!.project, ['name']),
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 13),
            ],
            if (_loading && costs == null)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator()))
            else if (_error != null)
              FinanceErrorState(message: _error, onRetry: _load)
            else if (costs != null) ...[
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              if (costs.rows.isEmpty)
                FinanceEmptyState(
                    message: context.tr(
                        en: 'No cost entries on this page',
                        ar: 'لا توجد بنود تكلفة في هذه الصفحة'))
              else
                for (final row in costs.rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FinanceSurface(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            row['description']?.toString().trim().isNotEmpty ==
                                    true
                                ? financeField(row, ['description'])
                                : financeCostCategory(context,
                                    row['category'] ?? row['costType']),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        FinanceLabelValue(
                          label: context.tr(en: 'Amount', ar: 'المبلغ'),
                          value: financeMoney(row['amount']),
                          prominent: true,
                        ),
                        FinanceLabelValue(
                          label: context.tr(
                              en: 'Cost group', ar: 'مجموعة التكلفة'),
                          value: row['costCategory'] == 'TEAM'
                              ? context.tr(en: 'Team', ar: 'الفريق')
                              : context.tr(en: 'Other', ar: 'أخرى'),
                        ),
                        FinanceLabelValue(
                          label: _dateLabel(context, row),
                          value: financeDate(row['date']),
                        ),
                        FinanceLabelValue(
                          label: context.tr(
                              en: 'Payment status', ar: 'حالة الدفع'),
                          value: row['isPaid'] == true
                              ? context.tr(en: 'Paid', ar: 'مدفوع')
                              : context.tr(en: 'Unpaid', ar: 'غير مدفوع'),
                        ),
                        if (row['paidAt'] != null)
                          FinanceLabelValue(
                            label: context.tr(en: 'Paid on', ar: 'تاريخ الدفع'),
                            value: financeDate(row['paidAt']),
                          ),
                      ],
                    )),
                  ),
              if (costs.meta.totalPages > 1)
                FinancePageFooter(
                    meta: costs.meta,
                    onPageChanged: (page) {
                      setState(() => _page = page);
                      _load();
                    }),
            ],
          ],
        ),
      )),
    );
  }
}
