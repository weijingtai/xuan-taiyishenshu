import "../theme/taiyi_classic_theme.dart";
import 'dart:math';
import 'package:flutter/material.dart';

import '../../enums/deity_kind.dart';
import '../../enums/gong.dart';
import '../../enums/god.dart';
import '../../taiyi/pan_data_model.dart';

class TaiYiPanGridV2 extends StatelessWidget {
  final PanDataModel panData;
  final double totalWidth;
  final ValueChanged<EnumTaiYiGong>? onGongTap;

  const TaiYiPanGridV2({
    super.key,
    required this.panData,
    this.totalWidth = 660,
    this.onGongTap,
  });

  static const List<String> _ring16Gods = [
    '巽', '巳', '午', '未', // Top
    '坤', '申', '酉', '戌', // Right
    '乾', '亥', '子', '丑', // Bottom
    '艮', '寅', '卯', '辰', // Left
  ];

  static const List<EnumTaiYiGong> _ninePalaceGongs = [
    EnumTaiYiGong.Xun, EnumTaiYiGong.Li, EnumTaiYiGong.Kun,
    EnumTaiYiGong.Zhen, EnumTaiYiGong.Center, EnumTaiYiGong.Dui,
    EnumTaiYiGong.Gen, EnumTaiYiGong.Kan, EnumTaiYiGong.Qian,
  ];

  String _getZhengGod(EnumTaiYiGong gong) {
    return switch (gong) {
      EnumTaiYiGong.Qian => '乾',
      EnumTaiYiGong.Li => '午',
      EnumTaiYiGong.Gen => '艮',
      EnumTaiYiGong.Zhen => '卯',
      EnumTaiYiGong.Dui => '酉',
      EnumTaiYiGong.Kun => '坤',
      EnumTaiYiGong.Kan => '子',
      EnumTaiYiGong.Xun => '巽',
      EnumTaiYiGong.Center => '',
    };
  }

  List<String> _getOuterDeities() {
    List<List<String>> outerTexts = List.generate(16, (_) => <String>[]);
    
    void addByGodName(String? name, String deity) {
      if (name == null || name.isEmpty) return;
      int idx = _ring16Gods.indexOf(name);
      if (idx != -1 && !outerTexts[idx].contains(deity)) {
        outerTexts[idx].add(deity);
      }
    }

    void addByGong(EnumTaiYiGong? gong, String deity) {
      if (gong == null || gong == EnumTaiYiGong.Center) return;
      String zhengName = _getZhengGod(gong);
      addByGodName(zhengName, deity);
    }

    addByGodName(panData.renPan.tianMuName, '文昌');
    addByGodName(panData.renPan.shiJiName, '始击');
    addByGodName(panData.renPan.jiShenName, '计神');
    
    for (final p in panData.tianPan.toPlacements()) {
      if (p.kind == EnumDeityKind.taiYi) {
        addByGong(p.gong, '太乙');
      } else {
        addByGong(p.gong, p.kind.label);
      }
    }
    
    for (final p in panData.shenPan.toPlacements()) {
      addByGong(p.gong, p.kind.label);
    }
    
    return outerTexts.map((l) => l.join(' ')).toList();
  }

  @override
  Widget build(BuildContext context) {
    final outerDeities = _getOuterDeities();
    
    return Container(
      width: totalWidth,
      height: totalWidth,
      color: Colors.white,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(totalWidth, totalWidth),
            painter: _TaiYiPanPainterV2(
              outerDeities: outerDeities,
              ring16Gods: _ring16Gods,
            ),
          ),
          Center(
            child: SizedBox(
              width: totalWidth * 0.45,
              height: totalWidth * 0.45,
              child: GridView.count(
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(9, (index) {
                  return GestureDetector(
                    onTap: () {
                      if (onGongTap != null) {
                        onGongTap!(_ninePalaceGongs[index]);
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaiYiPanPainterV2 extends CustomPainter {
  final List<String> outerDeities;
  final List<String> ring16Gods;

  _TaiYiPanPainterV2({
    required this.outerDeities,
    required this.ring16Gods,
  });

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    var dx = p2.dx - p1.dx;
    var dy = p2.dy - p1.dy;
    var distance = sqrt(dx * dx + dy * dy);
    var dashes = distance / 8;
    for (int i = 0; i < dashes; i++) {
      var start = i * 8.0;
      var end = start + 4.0;
      if (end > distance) end = distance;
      canvas.drawLine(
        Offset(p1.dx + dx * start / distance, p1.dy + dy * start / distance),
        Offset(p1.dx + dx * end / distance, p1.dy + dy * end / distance),
        paint
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double W = size.width;
    final Offset center = Offset(W / 2, W / 2);
    
    final double R4 = W * 0.12;
    final double R3 = W * 0.22;
    final double R2 = W * 0.35;
    final double R1 = W * 0.42;

    // Outer rect
    canvas.drawRect(Rect.fromLTWH(0, 0, W, W), paint);

    // Rounded rects
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: R1*2, height: R1*2), Radius.circular(W * 0.08)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: R2*2, height: R2*2), Radius.circular(W * 0.06)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: R3*2, height: R3*2), Radius.circular(W * 0.04)), paint);
    
    // Center circle
    canvas.drawCircle(center, R4, paint);

    // Diagonals (solid)
    double diagStart = R4 * 0.7071;
    canvas.drawLine(Offset(center.dx - diagStart, center.dy - diagStart), Offset(0, 0), paint);
    canvas.drawLine(Offset(center.dx + diagStart, center.dy - diagStart), Offset(W, 0), paint);
    canvas.drawLine(Offset(center.dx - diagStart, center.dy + diagStart), Offset(0, W), paint);
    canvas.drawLine(Offset(center.dx + diagStart, center.dy + diagStart), Offset(W, W), paint);

    // Midlines (dashed)
    _drawDashedLine(canvas, Offset(center.dx, center.dy - R4), Offset(center.dx, 0), paint);
    _drawDashedLine(canvas, Offset(center.dx, center.dy + R4), Offset(center.dx, W), paint);
    _drawDashedLine(canvas, Offset(center.dx - R4, center.dy), Offset(0, center.dy), paint);
    _drawDashedLine(canvas, Offset(center.dx + R4, center.dy), Offset(W, center.dy), paint);

    // Intermediate lines from W3 to W0
    for (int i = 1; i <= 3; i+=2) {
      // Top
      canvas.drawLine(Offset(W/2 - R3 + i*R3, center.dy - R3), Offset(i*W/4, 0), paint);
      // Bottom
      canvas.drawLine(Offset(W/2 - R3 + i*R3, center.dy + R3), Offset(i*W/4, W), paint);
      // Left
      canvas.drawLine(Offset(center.dx - R3, W/2 - R3 + i*R3), Offset(0, i*W/4), paint);
      // Right
      canvas.drawLine(Offset(center.dx + R3, W/2 - R3 + i*R3), Offset(W, i*W/4), paint);
    }

    _drawTexts(canvas, W, center, R1, R2, R3, R4);
  }

  void _drawTexts(Canvas canvas, double W, Offset center, double R1, double R2, double R3, double R4) {
    final outerStyle = TaiYiClassicTheme.getSerifStyle(fontSize: W * 0.02, color: Colors.black87);
    final godSingleStyle = TaiYiClassicTheme.getSerifStyle(fontSize: W * 0.035, color: Colors.black87);
    final gateStyle = TaiYiClassicTheme.getSerifStyle(fontSize: W * 0.025, color: Colors.red[800]);
    final luoshuStyle = TaiYiClassicTheme.getSerifStyle(fontSize: W * 0.035, color: Colors.black87);
    final centerStyle = TaiYiClassicTheme.getSerifStyle(fontSize: W * 0.030, color: Colors.purple[800]);

    void drawCenterText(String text, TextStyle style, double cx, double cy) {
      final tp = TextPainter(text: TextSpan(text: text, style: style), textAlign: TextAlign.center, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(cx - tp.width/2, cy - tp.height/2));
    }

    // W4 Center
    drawCenterText("五福 三风\n天符 天禽\n中宫", centerStyle, center.dx, center.dy);

    // W3-W4 (9 palaces numbers)
    final luoShu = ['四', '九', '二', '三', '五', '七', '八', '一', '六'];
    final stars = ['天辅', '天英', '天芮', '天冲', '', '天柱', '天任', '天蓬', '天心'];
    final posMap = [
      Offset(-1, -1), Offset(0, -1), Offset(1, -1),
      Offset(-1, 0),  Offset(0, 0),  Offset(1, 0),
      Offset(-1, 1),  Offset(0, 1),  Offset(1, 1),
    ];
    for (int i=0; i<9; i++) {
      if (i == 4) continue;
      double radius = (R3 + R4) / 2;
      double dx = posMap[i].dx;
      double dy = posMap[i].dy;
      double cx = center.dx + dx * radius * (dx != 0 && dy != 0 ? 0.707 : 1.0);
      double cy = center.dy + dy * radius * (dx != 0 && dy != 0 ? 0.707 : 1.0);
      drawCenterText("${luoShu[i]}\n${stars[i]}", luoshuStyle, cx, cy);
    }

    // W2-W3 (16 gods)
    for (int i = 0; i < 16; i++) {
      int side = i ~/ 4;
      int idx = i % 4;
      
      double offM = W/2 - R2;
      double offI = W/2 - R3;
      double Wm = R2 * 2;
      double Wi = R3 * 2;
      
      double xCenter = (offM + (idx + 0.5) * Wm / 4 + offI + (idx + 0.5) * Wi / 4) / 2;
      double cx = 0, cy = 0;
      if (side == 0) { cx = xCenter; cy = (offM + offI) / 2; }
      else if (side == 1) { cx = W - (offM + offI) / 2; cy = xCenter; }
      else if (side == 2) { cx = W - xCenter; cy = W - (offM + offI) / 2; }
      else { cx = (offM + offI) / 2; cy = W - xCenter; }

      final singleName = ring16Gods[i];
      String godName = "";
      try { godName = EnumTaiYiSixteenGods.values.firstWhere((e) => e.singleName == singleName).name; } catch (e) {}

      drawCenterText("$godName\n$singleName", godSingleStyle, cx, cy);
    }

    // W1-W2 八门(目前在中线/对角线方位绘制,详细落宫规则归 Task 14/15)
    final gates = ['休门', '生门', '伤门', '杜门', '景门', '死门', '惊门', '开门'];
    final gateDirs = [
      Offset(0, -1), Offset(1, -1), Offset(1, 0), Offset(1, 1),
      Offset(0, 1), Offset(-1, 1), Offset(-1, 0), Offset(-1, -1),
    ];
    for (int i = 0; i < 8; i++) {
      double r = (R1 + R2) / 2;
      double dx = gateDirs[i].dx;
      double dy = gateDirs[i].dy;
      double cx = center.dx + dx * r * (dx != 0 && dy != 0 ? 0.707 : 1.0);
      double cy = center.dy + dy * r * (dx != 0 && dy != 0 ? 0.707 : 1.0);
      drawCenterText(gates[i], gateStyle, cx, cy);
    }

    // W0-W1 (Outer Deities)
    for (int i = 0; i < 16; i++) {
      if (outerDeities[i].isEmpty) continue;
      int side = i ~/ 4;
      int idx = i % 4;
      
      double offM = W/2 - R1;
      double offO = 0;
      double Wm = R1 * 2;
      
      double xCenter = ((idx + 0.5) * W / 4 + offM + (idx + 0.5) * Wm / 4) / 2;
      double cx = 0, cy = 0;
      if (side == 0) { cx = xCenter; cy = (offO + offM) / 2; }
      else if (side == 1) { cx = W - (offO + offM) / 2; cy = xCenter; }
      else if (side == 2) { cx = W - xCenter; cy = W - (offO + offM) / 2; }
      else { cx = (offO + offM) / 2; cy = W - xCenter; }

      final words = outerDeities[i].split(' ');
      drawCenterText(words.join('\n'), outerStyle, cx, cy);
    }
  }

  @override
  bool shouldRepaint(covariant _TaiYiPanPainterV2 oldDelegate) {
    return true;
  }
}
