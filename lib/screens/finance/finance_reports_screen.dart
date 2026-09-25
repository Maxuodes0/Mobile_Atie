import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'finance_report_detail_screen.dart';
import 'finance_ui.dart';

const financeReportTypes = <String>[
  'revenue',
  'collection-status',
  'aging',
  'costs',
  'profitability',
  'vat',
  'cash-flow',
  'entities',
  'comparison',
];

class FinanceReportsScreen extends StatelessWidget {
  final FinanceQuery query;

  const FinanceReportsScreen({super.key, required this.query});

  String _subtitle(BuildContext context, String type) => switch (type) {
        'revenue' => context.tr(
            en: 'By period, client, operator or project',
            ar: 'حسب الفترة أو العميل أو الشركة المشغلة أو المشروع'),
        'collection-status' => context.tr(
            en: 'Received, outstanding and collection rate',
            ar: 'المحصّل وغير المحصّل ونسبة التحصيل'),
        'aging' => context.tr(
            en: 'Requires an authoritative receivable due date',
            ar: 'يتطلب تاريخ استحقاق مالي معتمد'),
        'costs' => context.tr(
            en: 'Team and other costs', ar: 'تكاليف الفريق والتكاليف الأخرى'),
        'profitability' => context.tr(
            en: 'Project profit and margin', ar: 'ربحية المشروع وهامشها'),
        'vat' => context.tr(
            en: 'Before VAT, VAT amount and with VAT',
            ar: 'قبل الضريبة والضريبة والإجمالي'),
        'cash-flow' => context.tr(
            en: 'Collections by month or quarter',
            ar: 'التحصيلات شهريًا أو ربع سنويًا'),
        'entities' => context.tr(
            en: 'Client or operating company', ar: 'العميل أو الشركة المشغلة'),
        'comparison' => context.tr(
            en: 'Compare with a previous period', ar: 'مقارنة بالفترة السابقة'),
        _ => '',
      };

  IconData _icon(String type) => switch (type) {
        'revenue' => Icons.trending_up_rounded,
        'collection-status' => Icons.payments_outlined,
        'aging' => Icons.schedule_outlined,
        'costs' => Icons.receipt_long_outlined,
        'profitability' => Icons.auto_graph_rounded,
        'vat' => Icons.percent_rounded,
        'cash-flow' => Icons.show_chart_rounded,
        'entities' => Icons.domain_outlined,
        'comparison' => Icons.compare_arrows_rounded,
        _ => Icons.insert_chart_outlined_rounded,
      };

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.pageBg,
        appBar: AppBar(
            title: Text(
                context.tr(en: 'Financial reports', ar: 'التقارير المالية'))),
        body: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
            itemCount: financeReportTypes.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text(
                      context.tr(
                        en: 'Select a report. Totals and exports use the same server filters.',
                        ar: 'اختر تقريرًا. الإجماليات والتصدير يستخدمان فلاتر الخادم نفسها.',
                      ),
                      style:
                          const TextStyle(color: AppTheme.muted, fontSize: 13)),
                );
              }
              final type = financeReportTypes[index - 1];
              return FinanceActionTile(
                key: ValueKey('finance-report-$type'),
                title: financeReportTitle(context, type),
                subtitle: _subtitle(context, type),
                icon: _icon(type),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) =>
                      FinanceReportDetailScreen(type: type, query: query),
                )),
              );
            },
          ),
        ),
      );
}
