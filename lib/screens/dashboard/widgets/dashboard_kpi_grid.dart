import 'package:flutter/material.dart';

import '../../../data/models/finance_dashboard.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/summary_card.dart';

class DashboardKpiGrid extends StatelessWidget {
  final FinanceKpis? kpis;

  const DashboardKpiGrid({
    super.key,
    required this.kpis,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
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
          icon: Icons.trending_up,
          accent: const Color(0xFF4F9E8D),
        ),
        SummaryCard(
          title: 'المحصّل',
          value: formatSar(kpis?.totalCollectedAmount ?? '0'),
          icon: Icons.account_balance_wallet_outlined,
          accent: const Color(0xFF3B82F6),
        ),
        SummaryCard(
          title: 'غير محصّل',
          value: formatSar(kpis?.outstandingAmount ?? '0'),
          icon: Icons.pending_actions,
          accent: const Color(0xFFEF4444),
        ),
        SummaryCard(
          title: 'إجمالي التكاليف',
          value: formatSar(kpis?.totalCosts ?? '0'),
          icon: Icons.payments_outlined,
          accent: const Color(0xFFF59E0B),
        ),
      ],
    );
  }
}
