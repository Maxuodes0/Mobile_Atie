import 'package:flutter/material.dart';

import '../../../data/models/finance_dashboard.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';

class DashboardKpiGrid extends StatefulWidget {
  final FinanceKpis? kpis;

  const DashboardKpiGrid({
    super.key,
    required this.kpis,
  });

  @override
  State<DashboardKpiGrid> createState() => _DashboardKpiGridState();
}

class _DashboardKpiGridState extends State<DashboardKpiGrid> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.84);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _DashboardMetricCard(
        title: 'إيرادات بدون ضريبة',
        value: formatSar(widget.kpis?.totalProjectValueWithoutVat ?? '0'),
        icon: Icons.trending_up,
        accent: const Color(0xFF4F9E8D),
      ),
      _DashboardMetricCard(
        title: 'المحصّل',
        value: formatSar(widget.kpis?.totalCollectedAmount ?? '0'),
        icon: Icons.account_balance_wallet_outlined,
        accent: const Color(0xFF3B82F6),
      ),
      _DashboardMetricCard(
        title: 'غير محصّل',
        value: formatSar(widget.kpis?.outstandingAmount ?? '0'),
        icon: Icons.pending_actions,
        accent: const Color(0xFFEF4444),
      ),
      _DashboardMetricCard(
        title: 'إجمالي التكاليف',
        value: formatSar(widget.kpis?.totalCosts ?? '0'),
        icon: Icons.payments_outlined,
        accent: const Color(0xFFF59E0B),
      ),
    ];

    return SizedBox(
      height: 158,
      child: PageView.builder(
        controller: _pageController,
        padEnds: false,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: cards[index],
          );
        },
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _DashboardMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F1115),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 31,
                      child: FittedBox(
                        alignment: AlignmentDirectional.centerStart,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: accent.withOpacitySafe(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 3,
            width: 58,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
