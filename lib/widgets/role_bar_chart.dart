import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class RoleBarDatum {
  final String label;
  final int value;
  final Color color;

  const RoleBarDatum({
    required this.label,
    required this.value,
    required this.color,
  });
}

class RoleBarChart extends StatelessWidget {
  final List<RoleBarDatum> items;

  const RoleBarChart({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final maxV = items.fold<int>(0, (m, x) => x.value > m ? x.value : m);
    if (items.isEmpty || maxV <= 0) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.softSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            context.tr(en: 'No data', ar: 'لا توجد بيانات'),
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final it in items) ...[
            Expanded(child: _BarColumn(item: it, maxV: maxV)),
            if (it != items.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final RoleBarDatum item;
  final int maxV;

  const _BarColumn({
    required this.item,
    required this.maxV,
  });

  @override
  Widget build(BuildContext context) {
    final t = maxV <= 0 ? 0.0 : (item.value / maxV).clamp(0.0, 1.0);
    return Column(
      children: [
        Text(
          item.value.toString(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: t,
              widthFactor: 0.55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
