import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MiniBarChart extends StatelessWidget {
  final List<double> values;
  final Color color;

  const MiniBarChart({
    super.key,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            'لا توجد بيانات',
            style: TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ),
      );
    }

    return CustomPaint(
      painter: _MiniBarChartPainter(values: values, color: color),
      child: const SizedBox.expand(),
    );
  }
}

class _MiniBarChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _MiniBarChartPainter({
    required this.values,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..color = const Color(0xFFF2F3F5)
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));
    canvas.drawRRect(rrect, bg);

    final maxV = values.reduce(math.max);
    const inset = 10.0;
    final w = size.width - inset * 2;
    final h = size.height - inset * 2;
    if (w <= 0 || h <= 0) return;

    final n = values.length;
    const gap = 4.0;
    final barW = math.max((w - gap * (n - 1)) / n, 2.0);

    final paint = Paint()..color = color.withOpacitySafe(0.9);

    canvas.save();
    canvas.clipRRect(rrect);

    for (var i = 0; i < n; i++) {
      final v = values[i];
      final t = maxV <= 0 ? 0.0 : (v / maxV).clamp(0.0, 1.0);
      final barH = t * h;
      final x = inset + i * (barW + gap);
      final y = inset + (h - barH);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, barH),
        const Radius.circular(6),
      );
      canvas.drawRRect(r, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiniBarChartPainter oldDelegate) {
    if (oldDelegate.color != color) return true;
    if (oldDelegate.values.length != values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}
