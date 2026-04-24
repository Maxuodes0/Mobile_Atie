import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DonutSegment {
  final String label;
  final double value;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class MiniDonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final Widget? center;
  final double strokeWidth;

  const MiniDonutChart({
    super.key,
    required this.segments,
    this.center,
    this.strokeWidth = 14,
  });

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (a, s) => a + (s.value.isFinite ? s.value : 0));

    if (total <= 0) {
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

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: _DonutPainter(segments: segments, strokeWidth: strokeWidth),
          child: const SizedBox.expand(),
        ),
        if (center != null) center!,
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double strokeWidth;

  _DonutPainter({
    required this.segments,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (a, s) => a + (s.value.isFinite ? s.value : 0));
    if (total <= 0) return;

    final rect = Offset.zero & size;
    final bg = Paint()
      ..color = const Color(0xFFF2F3F5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(14)), bg);

    final shortest = math.min(size.width, size.height);
    final pad = math.max(10.0, strokeWidth);
    final radius = (shortest / 2) - pad;
    if (radius <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);

    var start = -math.pi / 2;
    for (final s in segments) {
      final v = s.value.isFinite ? s.value : 0;
      if (v <= 0) continue;
      final sweep = (v / total) * math.pi * 2;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arcRect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    if (oldDelegate.strokeWidth != strokeWidth) return true;
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      final a = segments[i];
      final b = oldDelegate.segments[i];
      if (a.label != b.label) return true;
      if (a.value != b.value) return true;
      if (a.color != b.color) return true;
    }
    return false;
  }
}

