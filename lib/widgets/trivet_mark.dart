import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class TrivetMark extends StatelessWidget {
  const TrivetMark({
    super.key,
    required this.work,
    required this.health,
    required this.leisure,
    this.size = 180,
  });

  final double work;
  final double health;
  final double leisure;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TrivetMarkPainter(
          work: work,
          health: health,
          leisure: leisure,
          ink: theme.colorScheme.onSurface,
          line: theme.colorScheme.outlineVariant,
          workColor: context.pillars.work,
          healthColor: context.pillars.health,
          leisureColor: context.pillars.leisure,
        ),
      ),
    );
  }
}

class _TrivetMarkPainter extends CustomPainter {
  _TrivetMarkPainter({
    required this.work,
    required this.health,
    required this.leisure,
    required this.ink,
    required this.line,
    required this.workColor,
    required this.healthColor,
    required this.leisureColor,
  });

  final double work;
  final double health;
  final double leisure;
  final Color ink;
  final Color line;
  final Color workColor;
  final Color healthColor;
  final Color leisureColor;

  static const _workAngle = -math.pi / 2;
  static const _healthAngle = _workAngle + 2 * math.pi / 3;
  static const _leisureAngle = _workAngle - 2 * math.pi / 3;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 * 0.8;

    Offset vertex(double angle, double fraction) => Offset(
          center.dx + radius * fraction * math.cos(angle),
          center.dy + radius * fraction * math.sin(angle),
        );

    final referenceTriangle = Path()
      ..addPolygon(
        [
          vertex(_workAngle, 1),
          vertex(_healthAngle, 1),
          vertex(_leisureAngle, 1)
        ],
        true,
      );
    canvas.drawPath(
      referenceTriangle,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final axisPaint = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (final angle in [_workAngle, _healthAngle, _leisureAngle]) {
      canvas.drawLine(center, vertex(angle, 1), axisPaint);
    }

    final maxValue = [work, health, leisure].reduce((a, b) => a > b ? a : b);
    double fractionOf(double v) =>
        maxValue <= 0 ? 0 : (v / maxValue).clamp(0.0, 1.0);

    final workPoint = vertex(_workAngle, fractionOf(work));
    final healthPoint = vertex(_healthAngle, fractionOf(health));
    final leisurePoint = vertex(_leisureAngle, fractionOf(leisure));

    final dataTriangle = Path()
      ..addPolygon([workPoint, healthPoint, leisurePoint], true);
    canvas.drawPath(dataTriangle, Paint()..color = ink.withValues(alpha: 0.08));
    canvas.drawPath(
      dataTriangle,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    void dot(Offset point, Color color) =>
        canvas.drawCircle(point, 4, Paint()..color = color);
    dot(workPoint, workColor);
    dot(healthPoint, healthColor);
    dot(leisurePoint, leisureColor);
  }

  @override
  bool shouldRepaint(covariant _TrivetMarkPainter oldDelegate) {
    return work != oldDelegate.work ||
        health != oldDelegate.health ||
        leisure != oldDelegate.leisure;
  }
}
