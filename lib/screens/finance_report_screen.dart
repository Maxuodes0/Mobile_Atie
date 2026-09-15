import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/finance_report.dart';
import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/localized_values.dart';
import '../widgets/app_card.dart';
import '../widgets/error_banner.dart';

class FinanceReportScreen extends StatefulWidget {
  final String title;
  final String reportType;
  final String? from; // YYYY-MM-DD
  final String? to; // YYYY-MM-DD

  const FinanceReportScreen({
    super.key,
    required this.title,
    required this.reportType,
    this.from,
    this.to,
  });

  @override
  State<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  bool _loading = true;
  String? _error;
  FinanceReport? _report;

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

    FinanceReport? report;
    String? error;
    try {
      report = await AppServices.finance.getReport(
        reportType: widget.reportType,
        from: widget.from,
        to: widget.to,
      );
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;
    setState(() {
      _report = report;
      _error = error;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    String fmtDate(dynamic v) {
      if (v == null) return '—';
      if (v is DateTime) {
        return DateFormat.yMMMd(locale.toString()).format(v.toLocal());
      }
      final s = v.toString().trim();
      final parsed = DateTime.tryParse(s);
      if (parsed != null) {
        return DateFormat.yMMMd(locale.toString()).format(parsed.toLocal());
      }
      return s.isEmpty ? '—' : s;
    }

    final report = _report;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null) ...[
                ErrorBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              _SummaryCard(
                totalAmount: formatSar(report?.totalAmount),
                totalCount: report?.totalCount ?? 0,
                generatedAt: report?.generatedAt,
                from: widget.from,
                to: widget.to,
              ),
              const SizedBox(height: 12),
              if (_loading && report == null)
                const Center(child: CircularProgressIndicator())
              else if ((report?.rows ?? const []).isEmpty)
                Text(
                  context.tr(
                    en: 'No data available for this report',
                    ar: 'لا توجد بيانات لهذا التقرير',
                  ),
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                )
              else
                ...report!.rows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReportRowCard(
                      reportType: widget.reportType,
                      row: row,
                      fmtDate: fmtDate,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String totalAmount;
  final int totalCount;
  final DateTime? generatedAt;
  final String? from;
  final String? to;

  const _SummaryCard({
    required this.totalAmount,
    required this.totalCount,
    required this.generatedAt,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final generated = generatedAt == null
        ? null
        : DateFormat.yMMMd(locale.toString()).format(generatedAt!.toLocal());

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Report summary', ar: 'ملخص التقرير'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _MetaRow(
              label: context.tr(en: 'Total', ar: 'الإجمالي'),
              value: totalAmount),
          _MetaRow(
            label: context.tr(en: 'Record count', ar: 'عدد السجلات'),
            value: totalCount.toString(),
          ),
          if ((from ?? '').trim().isNotEmpty || (to ?? '').trim().isNotEmpty)
            _MetaRow(
              label: context.tr(en: 'Period', ar: 'الفترة'),
              value: '${from ?? '—'}  →  ${to ?? '—'}',
            ),
          if (generated != null)
            _MetaRow(
              label: context.tr(en: 'Generated on', ar: 'تاريخ الإنشاء'),
              value: generated,
            ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ReportRowCard extends StatelessWidget {
  final String reportType;
  final Map<String, dynamic> row;
  final String Function(dynamic v) fmtDate;

  const _ReportRowCard({
    required this.reportType,
    required this.row,
    required this.fmtDate,
  });

  String _paymentStatusLabel(BuildContext context, String raw) {
    switch (raw) {
      case 'PAID':
        return context.tr(en: 'Paid', ar: 'مدفوع');
      case 'PARTIAL':
        return context.tr(en: 'Partial', ar: 'جزئي');
      case 'UNPAID':
        return context.tr(en: 'Unpaid', ar: 'غير مدفوع');
      default:
        return raw;
    }
  }

  Color _paymentStatusColor(String raw) {
    switch (raw) {
      case 'PAID':
        return const Color(0xFF10B981);
      case 'PARTIAL':
        return const Color(0xFFF59E0B);
      case 'UNPAID':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (reportType == 'REVENUE_REPORT') {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row['projectName']?.toString() ?? '—',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            row['clientName']?.toString() ?? '—',
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _MetaRow(
              label: context.tr(en: 'Revenue', ar: 'الإيراد'),
              value: formatSar(row['totalRevenue']?.toString())),
        ],
      );
    } else if (reportType == 'COLLECTIONS_REPORT') {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row['projectName']?.toString() ?? '—',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _MetaRow(
            label: context.tr(en: 'Date', ar: 'التاريخ'),
            value: fmtDate(row['collectedDate']),
          ),
          _MetaRow(
              label: context.tr(en: 'Amount', ar: 'المبلغ'),
              value: formatSar(row['amount']?.toString())),
          _MetaRow(
              label: context.tr(en: 'Payment method', ar: 'طريقة الدفع'),
              value: localizedPaymentMethod(
                row['paymentMethod']?.toString() ?? '—',
                Localizations.localeOf(context).languageCode,
              )),
        ],
      );
    } else if (reportType == 'TEAM_COSTS_REPORT') {
      final statusRaw = row['paymentStatus']?.toString() ?? '';
      final statusLabel = _paymentStatusLabel(context, statusRaw);
      final statusColor = _paymentStatusColor(statusRaw);
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row['userName']?.toString() ?? '—',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacitySafe(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            row['role']?.toString() ?? '—',
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _MetaRow(
              label: context.tr(en: 'Total', ar: 'الإجمالي'),
              value: formatSar(row['totalAmount']?.toString())),
          _MetaRow(
              label: context.tr(en: 'Paid', ar: 'المدفوع'),
              value: formatSar(row['paidAmount']?.toString())),
          _MetaRow(
              label: context.tr(en: 'Remaining', ar: 'المتبقي'),
              value: formatSar(row['remainingAmount']?.toString())),
        ],
      );
    } else {
      final entries = row.entries.take(4).toList();
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Record', ar: 'سجل'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final e in entries)
            _MetaRow(label: e.key, value: e.value?.toString() ?? '—'),
        ],
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}
