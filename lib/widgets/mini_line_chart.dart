import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MiniLineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final Color? highlightColor;
  final List<String>? labels;

  const MiniLineChart({
    super.key,
    required this.values,
    required this.color,
    this.highlightColor,
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

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return CustomPaint(
          painter: _MiniLineChartPainter(
            values: values,
            color: color,
            highlightColor: highlightColor ?? color,
            labels: labels,
            progress: progress,
            textDirection: Directionality.of(context),
            labelStyle: const TextStyle(
              color: AppTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _MiniLineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color highlightColor;
  final List<String>? labels;
  final double progress;
  final TextDirection textDirection;
  final TextStyle labelStyle;

  _MiniLineChartPainter({
    required this.values,
    required this.color,
    required this.highlightColor,
    required this.labels,
    required this.progress,
    required this.textDirection,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..color = const Color(0xFFF5F1EB)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));
    canvas.drawRRect(rrect, bg);

    final labelsCount =
        labels == null ? 0 : math.min(labels!.length, values.length);
    const labelAreaHeight = 26.0;
    final hasLabels = labelsCount >= 2;
    final bottomReserved = hasLabels ? labelAreaHeight : 0.0;

    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final span = (maxV - minV).abs();

    const horizontalInset = 16.0;
    const topInset = 42.0;
    final w = size.width - horizontalInset * 2;
    final h = size.height - bottomReserved - topInset - 12;
    if (w <= 0 || h <= 0) return;

    Offset pt(int i, double v) {
      final x = horizontalInset + (i / math.max(values.length - 1, 1)) * w;
      final t = span < 1e-9 ? 0.5 : (v - minV) / span;
      final y = topInset + (1 - t) * h;
      return Offset(x, y);
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFD9D4CD)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = topInset + (h / 3) * i;
      canvas.drawLine(
        Offset(horizontalInset, y),
        Offset(size.width - horizontalInset, y),
        gridPaint,
      );
    }

    final points = <Offset>[
      for (var i = 0; i < values.length; i++) pt(i, values[i]),
    ];

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          highlightColor.withOpacitySafe(0.18),
          color.withOpacitySafe(0.0),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final controlX = (previous.dx + current.dx) / 2;
      path.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    if (points.length == 1) {
      path.lineTo(points.first.dx + 0.001, points.first.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, topInset + h)
      ..lineTo(points.first.dx, topInset + h)
      ..close();

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawPath(fillPath, fill);

    final metric = path.computeMetrics().first;
    final visibleLength = metric.length * progress.clamp(0.0, 1.0);
    final visiblePath = metric.extractPath(0, visibleLength);
    canvas.drawPath(visiblePath, line);

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
        final x = horizontalInset + (i / math.max(values.length - 1, 1)) * w;
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

    final tangent = metric.getTangentForOffset(visibleLength);
    if (tangent != null) {
      final ring = Paint()..color = Colors.white;
      final dot = Paint()..color = highlightColor;
      canvas.drawCircle(tangent.position, 9, ring);
      canvas.drawCircle(tangent.position, 6, dot);

      if (progress > 0.92) {
        _paintValueBubble(
          canvas,
          size,
          point: points.last,
          value: values.last,
        );
      }
    }
  }

  void _paintValueBubble(
    Canvas canvas,
    Size size, {
    required Offset point,
    required double value,
  }) {
    String compactValue(double raw) {
      if (raw.abs() >= 1000000) {
        return '${(raw / 1000000).toStringAsFixed(1)}M';
      }
      if (raw.abs() >= 1000) {
        return '${(raw / 1000).toStringAsFixed(1)}K';
      }
      return raw.toStringAsFixed(raw == raw.roundToDouble() ? 0 : 1);
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${compactValue(value)} SAR',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    const horizontalPadding = 10.0;
    const verticalPadding = 7.0;
    final bubbleSize = Size(
      textPainter.width + horizontalPadding * 2,
      textPainter.height + verticalPadding * 2,
    );
    var left = point.dx - bubbleSize.width / 2;
    left = left.clamp(8.0, size.width - bubbleSize.width - 8.0);
    var top = point.dy - bubbleSize.height - 15;
    if (top < 6) top = point.dy + 15;
    final bubbleRect = Rect.fromLTWH(
      left,
      top,
      bubbleSize.width,
      bubbleSize.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bubbleRect, const Radius.circular(10)),
      Paint()..color = highlightColor,
    );
    textPainter.paint(
      canvas,
      Offset(left + horizontalPadding, top + verticalPadding),
    );
  }

  @override
  bool shouldRepaint(covariant _MiniLineChartPainter oldDelegate) {
    if (oldDelegate.color != color) return true;
    if (oldDelegate.highlightColor != highlightColor) return true;
    if (oldDelegate.progress != progress) return true;
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
