import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MiniLineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final List<String>? labels;

  const MiniLineChart({
    super.key,
    required this.values,
    required this.color,
    this.labels,
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
      painter: _MiniLineChartPainter(
        values: values,
        color: color,
        labels: labels,
        textDirection: Directionality.of(context),
        labelStyle: const TextStyle(
          color: AppTheme.muted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _MiniLineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final List<String>? labels;
  final TextDirection textDirection;
  final TextStyle labelStyle;

  _MiniLineChartPainter({
    required this.values,
    required this.color,
    required this.labels,
    required this.textDirection,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..color = const Color(0xFFF2F3F5)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));
    canvas.drawRRect(rrect, bg);

    final labelsCount =
        labels == null ? 0 : math.min(labels!.length, values.length);
    const labelAreaHeight = 18.0;
    final hasLabels = labelsCount >= 2;
    final bottomReserved = hasLabels ? labelAreaHeight : 0.0;

    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final span = (maxV - minV).abs();

    const inset = 10.0;
    final w = size.width - inset * 2;
    final h = size.height - bottomReserved - inset * 2;
    if (w <= 0 || h <= 0) return;

    Offset pt(int i, double v) {
      final x = inset + (i / math.max(values.length - 1, 1)) * w;
      final t = span < 1e-9 ? 0.5 : (v - minV) / span;
      final y = inset + (1 - t) * h;
      return Offset(x, y);
    }

    final points = <Offset>[
      for (var i = 0; i < values.length; i++) pt(i, values[i]),
    ];

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacitySafe(0.22),
          color.withOpacitySafe(0.0),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, inset + h)
      ..lineTo(points.first.dx, inset + h)
      ..close();

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, line);

    if (hasLabels) {
      final sampleIndices = <int>{
        0,
        (labelsCount / 2).floor(),
        labelsCount - 1,
      }.toList();
      double maxLabelWidth = 0;
      for (final i in sampleIndices) {
        final tp = TextPainter(
          text: TextSpan(text: labels![i], style: labelStyle),
          textDirection: textDirection,
          maxLines: 1,
        )..layout();
        if (tp.width > maxLabelWidth) maxLabelWidth = tp.width;
      }

      final perStep = w / math.max(values.length - 1, 1);
      final needed = maxLabelWidth + 6; // centered label padding
      final step = math.max(1, (needed / math.max(perStep, 1)).ceil());

      void paintLabel(int i) {
        if (i < 0 || i >= labelsCount) return;
        final label = labels![i];
        final tp = TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          textDirection: textDirection,
          maxLines: 1,
        )..layout();
        final x = inset + (i / math.max(values.length - 1, 1)) * w;
        final y =
            size.height - labelAreaHeight + (labelAreaHeight - tp.height) / 2;
        var dx = x - tp.width / 2;
        dx = dx.clamp(4.0, size.width - tp.width - 4.0);
        tp.paint(canvas, Offset(dx, y));
      }

      for (var i = 0; i < labelsCount; i += step) {
        paintLabel(i);
      }
      paintLabel(labelsCount - 1);
    }

    canvas.restore();

    final dot = Paint()..color = color;
    canvas.drawCircle(points.last, 3, dot);
  }

  @override
  bool shouldRepaint(covariant _MiniLineChartPainter oldDelegate) {
    if (oldDelegate.color != color) return true;
    if (oldDelegate.textDirection != textDirection) return true;
    if (oldDelegate.values.length != values.length) return true;
    if ((oldDelegate.labels?.length ?? 0) != (labels?.length ?? 0)) return true;
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }

    // If labels exist and their content changed, repaint even if the length is the same.
    final oldLabels = oldDelegate.labels;
    final newLabels = labels;
    if (oldLabels != null && newLabels != null) {
      final n = math.min(oldLabels.length, newLabels.length);
      for (var i = 0; i < n; i++) {
        if (oldLabels[i] != newLabels[i]) return true;
      }
    }
    return false;
  }
}
