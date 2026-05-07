import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../enums/deity_kind.dart';
import '../../enums/gong.dart';
import '../../enums/god.dart';
import '../../taiyi/pan_data_model.dart';

/// 太乙排盘放射状布局（仿古式）
class TaiYiPanGrid extends StatelessWidget {
  final PanDataModel panData;
  final double totalWidth;
  final ValueChanged<EnumTaiYiGong>? onGongTap;

  const TaiYiPanGrid({
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

    // 特殊神煞按准确名字入局
    addByGodName(panData.renPan.tianMuName, '文昌');
    addByGodName(panData.renPan.shiJiName, '始击');
    addByGodName(panData.renPan.jiShenName, '计神');
    
    // 天盘星神
    for (final p in panData.tianPan.toPlacements()) {
      if (p.kind == EnumDeityKind.taiYi) {
        addByGong(p.gong, '太乙');
      } else {
        addByGong(p.gong, p.kind.label);
      }
    }
    
    // 神盘星神
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
            painter: _TaiYiPanPainter(
              outerDeities: outerDeities,
              ring16Gods: _ring16Gods,
            ),
          ),
          // 交互层：内圈3x3九宫格
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

class _TaiYiPanPainter extends CustomPainter {
  final List<String> outerDeities;
  final List<String> ring16Gods;

  _TaiYiPanPainter({
    required this.outerDeities,
    required this.ring16Gods,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double W = size.width;
    final double Wm = W * 0.75;
    final double Wi = W * 0.45;

    final double offM = (W - Wm) / 2;
    final double offI = (W - Wi) / 2;

    // 1. 画最外层方形
    canvas.drawRect(Rect.fromLTWH(0, 0, W, W), paint);
    
    // 2. 画十六神所在的中间层方形
    canvas.drawRect(Rect.fromLTWH(offM, offM, Wm, Wm), paint);
    
    // 3. 画洛书九宫所在的内层方形
    canvas.drawRect(Rect.fromLTWH(offI, offI, Wi, Wi), paint);

    // 4. 画内层 3x3 内部的井字线
    double cellI = Wi / 3;
    for (int i = 1; i < 3; i++) {
      // 竖线
      canvas.drawLine(Offset(offI + i * cellI, offI), Offset(offI + i * cellI, offI + Wi), paint);
      // 横线
      canvas.drawLine(Offset(offI, offI + i * cellI), Offset(offI + Wi, offI + i * cellI), paint);
    }

    // 5. 画中心向外辐射的线段
    // (a) 对角线：连接内外方角
    canvas.drawLine(Offset(0, 0), Offset(offI, offI), paint); // 左上
    canvas.drawLine(Offset(W, 0), Offset(offI + Wi, offI), paint); // 右上
    canvas.drawLine(Offset(0, W), Offset(offI, offI + Wi), paint); // 左下
    canvas.drawLine(Offset(W, W), Offset(offI + Wi, offI + Wi), paint); // 右下

    // (b) 边缘等分放射线：在每条边上打3个点，均分四等份，然后向中心连接，直到碰到内层正方形
    for (int i = 1; i < 4; i++) {
      double xOuter = i * W / 4;
      double xInner = offI + i * Wi / 4;
      // 顶部放射线
      canvas.drawLine(Offset(xOuter, 0), Offset(xInner, offI), paint);
      // 底部放射线
      canvas.drawLine(Offset(xOuter, W), Offset(xInner, offI + Wi), paint);
      
      double yOuter = i * W / 4;
      double yInner = offI + i * Wi / 4;
      // 左侧放射线
      canvas.drawLine(Offset(0, yOuter), Offset(offI, yInner), paint);
      // 右侧放射线
      canvas.drawLine(Offset(W, yOuter), Offset(offI + Wi, yInner), paint);
    }

    // 6. 绘制文本
    _drawInnerGridText(canvas, size, offI, cellI);
    _drawMiddleRingText(canvas, size, offM, offI, Wm, Wi);
    _drawOuterRingText(canvas, size, 0, offM, W, Wm);
  }

  void _drawInnerGridText(Canvas canvas, Size size, double offI, double cellI) {
    const numbers = ['九', '二', '七', '四', '五', '六', '三', '八', '一'];
    final textStyle = GoogleFonts.notoSerif(
      fontSize: cellI * 0.35,
      color: Colors.black87,
    );

    for (int i = 0; i < 9; i++) {
      int row = i ~/ 3;
      int col = i % 3;
      
      final textPainter = TextPainter(
        text: TextSpan(text: numbers[i], style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      // 除中心外，其他数字放置在单元格右下角附近
      double x = offI + (col + 1) * cellI - textPainter.width - cellI * 0.15;
      double y = offI + (row + 1) * cellI - textPainter.height - cellI * 0.15;
      
      // 中心'五'居中放置
      if (i == 4) {
        x = offI + col * cellI + (cellI - textPainter.width) / 2;
        y = offI + row * cellI + (cellI - textPainter.height) / 2;
      }
      
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  void _drawMiddleRingText(Canvas canvas, Size size, double offM, double offI, double Wm, double Wi) {
    final singleNameStyle = GoogleFonts.notoSerif(
      fontSize: (offI - offM) * 0.35,
      color: Colors.black87,
    );
    final godNameStyle = GoogleFonts.notoSerif(
      fontSize: (offI - offM) * 0.22,
      color: Colors.black87,
    );

    for (int i = 0; i < 16; i++) {
      int side = i ~/ 4;
      int idx = i % 4;
      
      double cx = 0;
      double cy = 0;
      
      double xCenter = (offM + (idx + 0.5) * Wm / 4 + offI + (idx + 0.5) * Wi / 4) / 2;
      
      if (side == 0) { // Top
        cx = xCenter;
        cy = (offM + offI) / 2;
      } else if (side == 1) { // Right
        cx = size.width - (offM + offI) / 2;
        cy = xCenter;
      } else if (side == 2) { // Bottom
        cx = size.width - xCenter;
        cy = size.width - (offM + offI) / 2;
      } else { // Left
        cx = (offM + offI) / 2;
        cy = size.width - xCenter;
      }

      final singleName = ring16Gods[i];
      String godName = "";
      try {
        godName = EnumTaiYiSixteenGods.values.firstWhere((e) => e.singleName == singleName).name;
      } catch (e) {
        // Fallback or ignore if not found
      }

      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(text: singleName, style: singleNameStyle),
            if (godName.isNotEmpty) TextSpan(text: '\n$godName', style: godNameStyle),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - textPainter.height / 2));
    }
  }

  void _drawOuterRingText(Canvas canvas, Size size, double offO, double offM, double W, double Wm) {
    final textStyle = GoogleFonts.notoSerif(
      fontSize: (offM - offO) * 0.18,
      color: Colors.black87,
    );

    for (int i = 0; i < 16; i++) {
      if (outerDeities[i].isEmpty) continue;

      int side = i ~/ 4;
      int idx = i % 4;
      
      double cx = 0;
      double cy = 0;
      
      double xCenter = ((idx + 0.5) * W / 4 + offM + (idx + 0.5) * Wm / 4) / 2;

      if (side == 0) { // Top
        cx = xCenter;
        cy = offM / 2;
      } else if (side == 1) { // Right
        cx = W - offM / 2;
        cy = xCenter;
      } else if (side == 2) { // Bottom
        cx = W - xCenter;
        cy = W - offM / 2;
      } else { // Left
        cx = offM / 2;
        cy = W - xCenter;
      }

      // 如果有多个神煞，按空格拆分为多行显示
      final words = outerDeities[i].split(' ');
      
      double totalHeight = 0;
      List<TextPainter> painters = [];
      for (String word in words) {
        if (word.isEmpty) continue;
        final tp = TextPainter(
          text: TextSpan(text: word, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: (offM - offO) * 0.9);
        painters.add(tp);
        totalHeight += tp.height;
      }

      double startY = cy - totalHeight / 2;
      for (var tp in painters) {
        tp.paint(canvas, Offset(cx - tp.width / 2, startY));
        startY += tp.height;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TaiYiPanPainter oldDelegate) {
    return true;
  }
}
