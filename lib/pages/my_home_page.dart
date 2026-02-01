import 'dart:math';

import 'package:flutter/material.dart';
import '../painter/pie_segment_painter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _animation = Tween<double>(
    // begin: 8 * pi / 180,
    begin: 3 * pi / 2,
    end: 45 * pi / 180,
  ).animate(_controller);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    List<Widget> lists = [];
    for (int i = 0; i < 1; i++) {
      lists.add(Transform.rotate(
        angle: (45 * i) * pi / 180,
        child: SizedBox(
          width: 320,
          height: 320,
          child: PieSegmentWidget(
            startAngle: 0,
            sweepAngle: 45,
            fillColor: Colors.blue,
            borderWidth: 2,
            borderColor: Colors.black,
            clipper: FanRingClipper(
              // Pass the FanRingClipper
              startAngle: 0 * pi / 180,
              sweepAngle: 45 * pi / 180,
              innerRadiusRatio: 0.8,
            ),
            child: const Center(
              child: Text('1°', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ));
    }
    return Container(
        width: 1000,
        height: 1000,
        alignment: Alignment.center,
        color: Colors.red.withOpacity(.1),
        child: Column(
          children: [
            const SizedBox(
              height: 128,
            ),
            Stack(alignment: Alignment.center, children: lists),
          ],
        ));
  }
}

class CircleRingPainter extends CustomPainter {
  final double innerRadius;
  final double outerRadius;
  late final double sweepAngleDegree;
  final String? text;
  List<String>? textList;
  late TextStyle textStyle;
  bool isReverseText = false;
  bool isHorizontalText = false;
  bool isAntiClockwise = false;

  double innerPadding = 12;
  double outerPadding = 12;
  bool withBackgroundColor = true;

  Map<String, Color> fiveElementsColorMap = {
    "金": const Color(0xffFFD700),
    "木": const Color(0xff228B22),
    "水": const Color(0xff1E90FF),
    "火": const Color(0xffFF4500),
    "土": const Color(0xff8B4513),
    "日": const Color(0xffFFD700), // 日光色 hex: #FFD700
    "月": const Color(0xffC0C0C0), // 银白色 hex: #C0C0C0
  };

  CircleRingPainter({
    required this.innerRadius,
    required this.outerRadius,
    double? eachAngleDegree,
    this.text,
    this.textList,
    this.isReverseText = true,
    this.isHorizontalText = true,
    this.isAntiClockwise = false,
    this.withBackgroundColor = true,
    this.innerPadding = 12,
    this.outerPadding = 12,
    this.textStyle =
        const TextStyle(color: Colors.black, fontSize: 18, height: 1.2),
  }) {
    if (textList != null && textList!.isNotEmpty) {
      sweepAngleDegree = 360 / textList!.length;
    } else {
      sweepAngleDegree = eachAngleDegree ?? 360;
    }
  }

  void debugPaint(Canvas canvas, Size size, Offset center) {
    // canvas.translate(center.dx, center.dy);
    // 给canvas绘制灰色透明度为0.1的背景
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width / 2, backgroundPaint);

    final Paint background2Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, background2Paint);

    final Paint background3Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, background3Paint);
    // 绘制圆心点
    final Paint centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    double eachDegreeOfPI = pi / 180;
    final center = Offset(size.width / 2, size.height / 2);
    // canvas.save();

    canvas.translate(size.width / 2, size.height / 2);
    // canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);

    final res = sweepAngleDegree * 0.5 * eachDegreeOfPI;
    // final res = sweepAngleDegree * 0.5;
    final double startAngle = pi / 2 - res;
    final double sweepAngle = sweepAngleDegree * eachDegreeOfPI;
    final fanRingWidth = outerRadius - innerRadius;

    // 固定的颜色
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = fanRingWidth;

    // canvas.translate(center.dx, center.dy);
    // 计算每个扇环的中心角度
    // double angle = startAngle;
    double arcDrawCircleRadius = innerRadius + (fanRingWidth * 0.5);
    double textRotationAngle = startAngle + sweepAngle / 2;
    int total = 360 ~/ sweepAngleDegree;
    if (textList != null && textList!.isNotEmpty) {
      total = textList!.length;
    }
    // 12点方向为起始点
    canvas.rotate(pi - pi / 4);
    // 9点方向为起始点 -- not work
    // canvas.rotate(pi/4);
    // 6点方向为起始点 -- not work
    // canvas.rotate(-pi/4);
    // 3点方向为起始点 -- not work
    // canvas.rotate(pi + pi/ 4);

    final Paint borderPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < total; i++) {
      // 绘制扇环
      Path path = Path()
        ..addArc(
          Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius),
          startAngle,
          sweepAngle,
        );

      // 绘制一条从圆心到圆环的线
      // path.moveTo(0, 0);
      // path.lineTo(0, -arcDrawCircleRadius);
      // path.close();

      // canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius), startAngle, sweepAngle, false, paint);
      textList = textList ?? [text!];
      var textListLength = text != null ? text!.length : textList?[i].length;
      var lastChar = textList![i][textListLength! - 1];
      debugPrint("lastChar: $lastChar");
      if (withBackgroundColor) {
        paint.color = fiveElementsColorMap[lastChar]!;
      }

      canvas.drawPath(path, paint);

      // canvas.drawShadow(path, Colors.blue.withOpacity(0.4), 5, false);

      if (text != null) {
        if (text!.length == 1) {
          // 绘制文字
          paintSingleChar(
              canvas, size, text!, center, textRotationAngle, fanRingWidth);
        } else {
          if (isHorizontalText) {
            // 绘制文字
            paintSingleChar(
                canvas, size, text!, center, textRotationAngle, fanRingWidth);
          } else {
            // 绘制文字
            paintVerticalText(
                canvas, size, text!, center, textRotationAngle, fanRingWidth);
          }
        }
      } else {
        if (textList != null && textList!.isNotEmpty) {
          var text = textList![i];
          if (text.length == 1) {
            // 绘制文字
            paintSingleChar(
                canvas, size, text, center, textRotationAngle, fanRingWidth);
          } else {
            if (isHorizontalText) {
              // 绘制文字
              paintSingleChar(
                  canvas, size, text, center, textRotationAngle, fanRingWidth);
            } else {
              // 绘制文字
              paintVerticalText(
                  canvas, size, text, center, textRotationAngle, fanRingWidth);
            }
          }
        }
      }
      if (isAntiClockwise) {
        canvas.rotate(-(pi * 2) / total);
      } else {
        canvas.rotate((pi * 2) / total);
      }
    }

    for (int i = 0; i < total; i++) {
      if (i == 0) {
        canvas.rotate(-eachDegreeOfPI * 15);
      } else {
        canvas.rotate(-eachDegreeOfPI * 30);
      }
      Path borderPath = Path();
      borderPath.moveTo(0, innerRadius);
      borderPath.lineTo(0, outerRadius);
      borderPath.close();
      canvas.drawPath(borderPath, borderPaint);
      // break;
    }
  }

  void paintSingleChar(Canvas canvas, Size size, String text, Offset center,
      double rotationAngle, double yOffset) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    Offset offset = isReverseText
        ? Offset(
            -textPainter.width * 0.5,
            -innerRadius -
                innerPadding -
                textPainter.height +
                textPainter.height * .1,
          )
        : Offset(
            -textPainter.width * 0.5,
            innerRadius + innerPadding,
          );
    double rotateAngle = isReverseText ? pi : 0.0;
    canvas.rotate(rotateAngle);
    textPainter.paint(canvas, offset);
  }

  void paintVerticalText(Canvas canvas, Size size, String text, Offset center,
      double rotationAngle, double yOffset) {
    // splite text to single char
    List<String> textList = text.split('');
    int totalLength = textList.length;
    for (int i = 0; i < totalLength; i++) {
      final textSpan = TextSpan(
        text: textList[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      double rotateAngle = isReverseText ? pi : 0.0;
      if (i == 0) {
        Offset offset = isReverseText
            ? Offset(
                center.dx - outerRadius - (textPainter.size.width * 0.5),
                -innerRadius -
                    innerPadding -
                    (textPainter.size.height * .9 * totalLength),
              )
            : Offset(
                center.dx - outerRadius - (textPainter.size.width * 0.3),
                innerRadius + innerPadding,
                // innerRadius + innerPadding + textPainter.size.height * 0.1,
              );
        // canvas.translate(offset.dx, offset.dy);
        // canvas.translate(center.dx, center.dy);
        canvas.rotate(rotateAngle);
        textPainter.paint(canvas, offset);
      } else {
        Offset offset = isReverseText
            ? Offset(
                center.dx - outerRadius - (textPainter.size.width * 0.5),
                -innerRadius -
                    innerPadding -
                    (textPainter.size.height * .9 * (totalLength - i)),
              )
            : Offset(
                center.dx - outerRadius - (textPainter.size.width * 0.3),
                innerRadius + innerPadding + textPainter.size.height * i,
                // innerRadius + innerPadding + textPainter.size.height * 0.8 * i,
              );
        // canvas.translate(offset.dx, offset.dy);
        textPainter.paint(canvas, offset);
      }
    }
    canvas.save();
    canvas.restore();
  }

  void paintHorizontalText(Canvas canvas, Size size, String text, Offset center,
      double rotationAngle, double yOffset) {
    // splite text to single char
    List<String> textList = text.split('').reversed.toList();
    int totalLength = textList.length;
    canvas.save();
    // canvas.translate(-size.width,-size.height);
    // canvas.translate(0,0);
    if (totalLength.isEven) {
      for (int i = 0; i < totalLength; i++) {
        final textSpan = TextSpan(
          text: textList[i],
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        Offset offset = isReverseText
            ? Offset(
                -textPainter.width * 0.5,
                -innerRadius - innerPadding - textPainter.height * .5,
              )
            : Offset(
                -textPainter.width * 0.5,
                innerRadius + innerPadding + textPainter.height * .1,
              );
        double rotateAngle = isReverseText ? pi : 0.0;
        if (i == 0) {
          offset = isReverseText
              ? Offset(
                  -textPainter.width * 0.5 * 2,
                  -innerRadius - innerPadding - textPainter.height * .5,
                )
              : Offset(
                  // -textPainter.width * 0.5,
                  // textPainter.width * - .2,
                  // -textPainter.width,
                  -textPainter.width * 0.6,
                  innerRadius + innerPadding + textPainter.height * .04,
                );
          canvas.rotate(rotateAngle - pi * .04);
          // canvas.save();
          // canvas.restore();
        } else {
          offset = isReverseText
              ? Offset(
                  textPainter.width * 0.5 * 2,
                  -innerRadius - innerPadding - textPainter.height * .5,
                )
              : Offset(
                  -textPainter.width * 1.2,
                  // 0,
                  innerRadius + innerPadding + textPainter.height * .04,
                  // innerRadius + innerPadding + textPainter.height * .04,
                );
          // canvas.rotate(rotateAngle + pi * .02);
          canvas.rotate(rotateAngle + pi * .04);
        }
        textPainter.paint(canvas, offset);
      }
    }
    // canvas.save();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
