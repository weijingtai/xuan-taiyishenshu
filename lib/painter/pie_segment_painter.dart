import 'dart:math';

import 'package:flutter/material.dart';

class PieSegmentPainter extends CustomPainter {
  final double startAngle; // In radians
  final double sweepAngle; // In radians
  final Color fillColor;
  final double borderWidth;
  final Color borderColor;

  PieSegmentPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.fillColor,
    this.borderWidth = 0.0,
    this.borderColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Draw the filled segment
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      fillPaint,
    );

    // Draw the border (if borderWidth > 0)
    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint if any of the properties change
    return oldDelegate is PieSegmentPainter &&
        (oldDelegate.startAngle != startAngle ||
            oldDelegate.sweepAngle != sweepAngle ||
            oldDelegate.fillColor != fillColor ||
            oldDelegate.borderWidth != borderWidth ||
            oldDelegate.borderColor != borderColor);
  }
}

class PieSegmentWidget extends StatelessWidget {
  final double startAngle; // In degrees
  final double sweepAngle; // In degrees
  final Color fillColor;
  final double borderWidth;
  final Color borderColor;
  final Widget child;
  final CustomClipper<Path>? clipper;

  const PieSegmentWidget({
    super.key,
    required this.startAngle,
    required this.sweepAngle,
    required this.fillColor,
    this.borderWidth = 0.0,
    this.borderColor = Colors.black,
    required this.child,
    this.clipper,
  });

  @override
  Widget build(BuildContext context) {
    const outerRadius = 60;
    const innerRadius = 60;
    return ClipPath(
      clipper: clipper ??
          _PieSegmentClipper(
            startAngle: startAngle * pi / 180, // Convert to radians
            sweepAngle: sweepAngle * pi / 180, // Convert to radians
          ),
      child: CustomPaint(
        painter: PieSegmentPainter(
          startAngle: startAngle * pi / 180,
          sweepAngle: sweepAngle * pi / 180,
          fillColor: fillColor,
          borderWidth: borderWidth,
          borderColor: borderColor,
        ),
        child: Transform.translate(
          offset: calculateTextPosition(
            startAngle * pi / 180,
            sweepAngle * pi / 180,
            (outerRadius + innerRadius) / 2,
          ),
          // child: child,
          child: Center(
            child: Text('$sweepAngle°'), // Display sweepAngle as text
          ),
        ),
      ),
    );
  }

  Offset calculateTextPosition(
    double startAngle,
    double sweepAngle,
    double radius,
  ) {
    final halfSweepAngle = startAngle + sweepAngle / 2;
    const distanceFactor = 1;
    final x = radius * distanceFactor * cos(halfSweepAngle);
    final y = radius * distanceFactor * sin(halfSweepAngle);
    return Offset(x, y);
  }
}

// Helper clipper to define the pie shape
class _PieSegmentClipper extends CustomClipper<Path> {
  final double startAngle;
  final double sweepAngle;

  _PieSegmentClipper({
    required this.startAngle,
    required this.sweepAngle,
    // required double innerRadiusRatio,
  });

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      )
      ..lineTo(center.dx, center.dy)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_PieSegmentClipper oldClipper) =>
      oldClipper.startAngle != startAngle ||
      oldClipper.sweepAngle != sweepAngle;
}

class FanRingClipper extends CustomClipper<Path> {
  final double startAngle;
  final double sweepAngle;
  final double
      innerRadiusRatio; // Ratio of inner radius to outer radius (0.0 to 1.0)

  FanRingClipper({
    required this.startAngle,
    required this.sweepAngle,
    this.innerRadiusRatio = 0.5,
  });

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) / 2;
    final innerRadius = outerRadius * innerRadiusRatio;

    final path = Path()
      ..moveTo(
        center.dx + innerRadius * cos(startAngle),
        center.dy + innerRadius * sin(startAngle),
      )
      ..lineTo(
        center.dx + outerRadius * cos(startAngle),
        center.dy + outerRadius * sin(startAngle),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
      )
      ..lineTo(
        center.dx + innerRadius * cos(startAngle + sweepAngle),
        center.dy + innerRadius * sin(startAngle + sweepAngle),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle + sweepAngle,
        -sweepAngle, // Draw the inner arc in reverse
        false,
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(FanRingClipper oldClipper) =>
      oldClipper.startAngle != startAngle ||
      oldClipper.sweepAngle != sweepAngle ||
      oldClipper.innerRadiusRatio != innerRadiusRatio;
}
