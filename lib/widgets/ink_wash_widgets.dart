import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../theme/taiyi_classic_theme.dart';

/// 一个带有水墨风格边框的容器装饰器
class InkyBorder extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double padding;

  const InkyBorder({
    super.key,
    required this.child,
    this.color,
    this.padding = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InkyPainter(color: color ?? TaiYiClassicTheme.inkBlack),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}

class _InkyPainter extends CustomPainter {
  final Color color;
  _InkyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Top line
    path.moveTo(2, 2);
    path.quadraticBezierTo(size.width / 2, -2, size.width - 2, 2);
    
    // Right line
    path.quadraticBezierTo(size.width + 2, size.height / 2, size.width - 2, size.height - 2);
    
    // Bottom line
    path.quadraticBezierTo(size.width / 2, size.height + 2, 2, size.height - 2);
    
    // Left line
    path.quadraticBezierTo(-2, size.height / 2, 2, 2);

    canvas.drawPath(path, paint);
    
    // Add some "ink dots" at corners
    canvas.drawCircle(const Offset(2, 2), 1.2, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(size.width - 2, size.height - 2), 1.0, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 一个带有传统风格标题的 Section 组件
class ChineseSectionHeader extends StatelessWidget {
  final String title;
  const ChineseSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [TaiYiClassicTheme.cinnabar, TaiYiClassicTheme.inkWash],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.maShanZheng(
              fontSize: 18,
              color: TaiYiClassicTheme.darkWood,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 一个模拟宣纸纹理的组件
class PaperBackground extends StatelessWidget {
  final Widget child;
  const PaperBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PaperPainter(),
      child: child,
    );
  }
}

class _PaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill basic rice paper color
    final paint = Paint()
      ..color = TaiYiClassicTheme.ricePaper
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw subtle fibers/spots
    final random = math.Random(42); 
    final spotPaint = Paint()
      ..color = TaiYiClassicTheme.inkWash.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.2;
      canvas.drawCircle(Offset(x, y), radius, spotPaint);
    }
    
    // Draw some long "fibers"
    final fiberPaint = Paint()
      ..color = TaiYiClassicTheme.goldLeaf.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + random.nextDouble() * 20 - 10, y + random.nextDouble() * 20 - 10),
        fiberPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
