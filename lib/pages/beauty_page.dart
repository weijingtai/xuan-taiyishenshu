import 'dart:math';
import 'package:xuan_four_zhu_card/painter/text_circle_ring_painter.dart';
import 'package:xuan_four_zhu_card/painter/circle_ring_printer.dart';
import 'package:flutter/material.dart';
import '../theme/taiyi_classic_theme.dart';
import 'package:tuple/tuple.dart';

import '../models/ConstantNineGongDataClass.dart';
import '../widgets/tai_yi_gong_content_background.dart';

class BeautyPage extends StatefulWidget {
  const BeautyPage({super.key});

  @override
  State<BeautyPage> createState() => _BeautyPageState();
}

class _BeautyPageState extends State<BeautyPage> with TickerProviderStateMixin {
  // 黄道十二宫 从白羊开始
  List<String> zodiacList = <String>[
    "坎",
    "艮",
    "震",
    "巽",
    "离",
    "坤",
    "兑",
    "乾",
  ].reversed.toList();
  TextStyle zodiacTextStyle =
      TaiYiClassicTheme.getSerifStyle(fontSize: 48, color: Colors.black, height: 1);

  // 十二星次 从大梁开始
  TextStyle starTextStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 12,
      fontFamily: 'KaiTi',
      fontWeight: FontWeight.w300,
      height: 1.2);
  // sixteen gong name
  List<String> sixteenGongNameList = <String>[
    "亥神",
    "子神",
    "丑神",
    "艮神",
    "寅神",
    "卯神",
    "辰神",
    "巽神",
    "巳申",
    "午神",
    "未神",
    "坤神",
    "申神",
    "酉神",
    "戌神",
    "乾神",
  ].reversed.toList();

  // sixteen God
  List<String> sixteenGodsNameList = <String>[
    "大义",
    "地主",
    "阳德",
    "和德",
    "吕申",
    "高丛",
    "太阳",
    "大炅",
    "大神",
    "大威",
    "天道",
    "大武",
    "武德",
    "大簇",
    "阴主",
    "阴德",
  ].reversed.toList();

  late List<Text> zodiacTextList;
  late List<Text> sixteenGongNameSeq;
  late List<Text> sixteenGodsNameSeq;

  @override
  void initState() {
    super.initState();
    // zodiacTextList = zodiacList.map((e) => Text(e,style: zodiacTextStyle,)).toList();
    zodiacTextList = zodiacList.map((e) => const Text("")).toList();
    sixteenGongNameSeq = sixteenGongNameList
        .map((e) =>
            Text(e, style: TaiYiClassicTheme.getTitleStyle(fontSize: 16, height: 1)))
        .toList();
    sixteenGodsNameSeq = sixteenGodsNameList
        .map((e) =>
            Text(e, style: TaiYiClassicTheme.getTitleStyle(fontSize: 16, height: 1)))
        .toList();
  }

  TextStyle eightSkyDoorTextStyle = TaiYiClassicTheme.getTitleStyle(
    fontSize: 14,
    color: Colors.grey,
    fontWeight: FontWeight.w600,
  );

  TextStyle eightSeasonTextStyle = TaiYiClassicTheme.getTitleStyle(
    color: Colors.grey,
    fontSize: 14,
    height: 1,
  );
  TextStyle nineGongNameTextStyle = const TextStyle(
    // color: Colors.grey.withOpacity(.3),
    color: Colors.grey,
    fontSize: 70,
    height: 1,
  );
  TextStyle nineGongNumberTextStyle = TaiYiClassicTheme.getSerifStyle(
    color: Colors.grey,
    fontSize: 20,
    height: 1,
  );
  // TextStyle nineAreaNameTextStyle = TextStyle(
  TextStyle nineAreaNameTextStyle = TaiYiClassicTheme.getTitleStyle(
    color: Colors.grey,
    fontSize: 14,
    height: 1,
  );

  Map<String, String> eightGuaMapper = {
    "乾": "☰",
    "兑": "☱",
    "离": "☲",
    "震": "☳",
    "巽": "☴",
    "坎": "☵",
    "艮": "☶",
    "坤": "☷"
  };
  Map<String, Color> zodiacColors = {
    '亥': const Color.fromRGBO(61, 89, 171, 1), // 子水（鼠）- 天青色
    '丑': const Color.fromRGBO(210, 180, 140, 1), // 丑土（牛）- 茶色
    '寅': const Color.fromRGBO(89, 195, 194, 1), // 寅木（虎）- 竹青
    '卯': const Color.fromRGBO(120, 146, 98, 1), // 卯木（兔）- 豆绿
    '辰': const Color.fromRGBO(225, 169, 95, 1), // 辰土（龙）- 麦秸黄
    '巳': const Color.fromRGBO(255, 69, 0, 1), // 巳火（蛇）- 朱红
    '午': const Color.fromRGBO(205, 92, 92, 1), // 午火（马）- 丹橙
    '未': const Color.fromRGBO(244, 164, 96, 1), // 未土（羊）- 沙棕
    '申': const Color.fromRGBO(228, 158, 0, 1), // 申金（猴）- 银白色
    '酉': const Color.fromRGBO(237, 145, 33, 1), // 酉金（鸡）- 金色
    '戌': const Color.fromRGBO(160, 82, 45, 1), // 戌土（狗）- 赭色
    '子': const Color.fromRGBO(75, 0, 130, 1), // 亥水（猪）- 靛青
  };
  Map<String, Color> Seasons24ColorMapper = {
    "立春": const Color.fromRGBO(89, 195, 194, 1),
    "雨水": const Color.fromRGBO(138, 154, 91, 1),
    "惊蛰": const Color.fromRGBO(128, 128, 0, 1),
    "春分": const Color.fromRGBO(120, 146, 98, 1),
    "清明": const Color.fromRGBO(141, 182, 0, 1),
    "谷雨": const Color.fromRGBO(164, 198, 57, 1),
    "立夏": const Color.fromRGBO(255, 69, 0, 1),
    "小满": const Color.fromRGBO(255, 105, 97, 1),
    "芒种": const Color.fromRGBO(255, 182, 193, 1),
    "夏至": const Color.fromRGBO(205, 92, 92, 1),
    "小暑": const Color.fromRGBO(178, 34, 34, 1),
    "大暑": const Color.fromRGBO(139, 0, 0, 1),
    "立秋": const Color.fromRGBO(228, 158, 0, 1),
    "处暑": const Color.fromRGBO(255, 215, 0, 1),
    "白露": const Color.fromRGBO(252, 211, 77, 1),
    "秋分": const Color.fromRGBO(237, 145, 33, 1),
    "寒露": const Color.fromRGBO(255, 193, 37, 1),
    "霜降": const Color.fromRGBO(248, 197, 143, 1),
    "立冬": const Color.fromRGBO(143, 178, 201, 1),
    "小雪": const Color.fromRGBO(173, 216, 230, 1),
    "大雪": const Color.fromRGBO(0, 191, 255, 1),
    "冬至": const Color.fromRGBO(75, 0, 130, 1),
    "小寒": const Color.fromRGBO(0, 0, 139, 1),
    "大寒": const Color.fromRGBO(61, 89, 171, 1)
  };

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minSize = height > width ? width : height;

    // offset rotatedDegree
    // 使用 dart:math 库中的函数进行转换
    return Scaffold(
      body: build_body(),
    );
  }

  Widget build_body() {
    return Container(
        width: 1200,
        height: 1200,
        alignment: Alignment.center,
        // color: Colors.red.withOpacity(.1),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // 后天八卦
                  eight_gong_ring(),
                  sixteen_gong_and_gods(),
                  gong_slot(),
                  Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(.1),
                        borderRadius: BorderRadius.circular(320),
                        border: Border.all(color: Colors.black, width: 1)),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  Widget gong_slot() {
    // double rotatedDegree = (135 + 11.25) * pi / 180;
    double rotatedDegree = 11.25 * pi / 180;
    // double rotatedDegree = 0;
    return Transform.rotate(
      angle: rotatedDegree,
      origin: Offset.zero,
      child: Container(
        width: 940,
        height: 940,
        // width: 906,
        // height: 906,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(966))),
        child: Stack(
          alignment: Alignment.center,
          children: [
            drawRingWithTextList(
                940, 138, List.generate(16, (index) => const Text("")).toList(),
                innerPadding: 6),
            Transform.rotate(
              angle: (22.5 * 0 * pi) / 180,
              child: star_gods_slot_for_four(),
            ),
            Transform.rotate(
              angle: (22.5 * 1 * pi) / 180,
              child: star_gods_slot_for_five(),
            ),
            Transform.rotate(
              angle: (22.5 * 2 * pi) / 180,
              child: star_gods_slot_for_six(),
            ),
            Transform.rotate(
              angle: (22.5 * 3 * pi) / 180,
              child: star_gods_slot_for_three(),
            ),
            Transform.rotate(
              angle: (22.5 * 4 * pi) / 180,
              child: star_gods_slot_for_two(),
            ),
            Transform.rotate(
              angle: (22.5 * 5 * pi) / 180,
              child: star_gods_slot_for_one(),
            ),
            Transform.rotate(
              angle: (22.5 * 15 * pi) / 180,
              child: star_gods_slot_for_seven(),
            )
          ],
        ),
      ),
    );
  }

  Widget star_gods_tag(String starGod) {
    var letter = starGod.split("");
    var first = letter.first;
    var second = letter.last;
    return SizedBox(
      // color: Colors.black.withOpacity(.1),
      height: 56,
      width: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            first,
            style: TaiYiClassicTheme.getChineseStyle(
                height: 1.0, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          Text(second,
              style: TaiYiClassicTheme.getChineseStyle(
                  height: 1.0, fontSize: 24, fontWeight: FontWeight.w700))
        ],
      ),
    );
  }

  Widget star_gods_slot_for_one() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            // angle: (0 * pi) / 180,
            angle: 0,
            origin: Offset.zero,
            child: Container(
                margin: const EdgeInsets.only(top: 760),
                child: star_gods_tag("太乙")),
          ),
        ],
      ),
    );
  }

  Widget star_gods_slot_for_two() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: (-5 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 780),
              child: star_gods_tag("民基"),
            ),
          ),
          Transform.rotate(
            angle: (5 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 780),
              child: star_gods_tag("臣基"),
            ),
          ),
        ],
      ),
    );
  }

  Widget star_gods_slot_for_three() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: (22.5 * 0 * pi) / 180,
            origin: Offset.zero,
            child: Container(
                margin: const EdgeInsets.only(top: 730),
                child: star_gods_tag("太乙")),
          ),
          Transform.rotate(
            angle: (6 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 820),
              child: star_gods_tag("客大"),
            ),
          ),
          Transform.rotate(
            angle: (-6 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 820),
              child: star_gods_tag("飞鸟"),
            ),
          )
        ],
      ),
    );
  }

  Widget star_gods_slot_for_four() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: (22.5 * 0 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 730),
              child: star_gods_tag("太乙"),
            ),
          ),
          Transform.rotate(
            angle: (6 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 790),
              child: star_gods_tag("客大"),
            ),
          ),
          Transform.rotate(
            angle: (22.5 * 0 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 860),
              child: star_gods_tag("始击"),
            ),
          ),
          Transform.rotate(
            angle: (-6 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 790),
              child: star_gods_tag("飞符"),
            ),
          )
        ],
      ),
    );
  }

  Widget star_gods_slot_for_five() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: (-3.5 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 730),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (3.5 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 730),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (22.5 * 0 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 860),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (7 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 860),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (-7 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 860),
              child: star_gods_tag("飞符"),
            ),
          )
        ],
      ),
    );
  }

  Widget star_gods_slot_for_six() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: (-7 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 730),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (22.5 * 0 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 730),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (7 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 730),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (22.5 * 0 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 860),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (7 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 860),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (-7 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 860),
              child: star_gods_tag("飞符"),
            ),
          )
        ],
      ),
    );
  }

  Widget star_gods_slot_for_seven() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: (6 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 750),
              child: star_gods_tag("客大"),
            ),
          ),
          Transform.rotate(
            angle: (22.5 * 0 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 730),
              child: star_gods_tag("太乙"),
            ),
          ),
          Transform.rotate(
            angle: (-6 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 750),
              child: star_gods_tag("定大"),
            ),
          ),
          Transform.rotate(
            angle: (2.5 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 850),
              child: star_gods_tag("主参"),
            ),
          ),
          Transform.rotate(
            angle: (-2.5 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 850),
              child: star_gods_tag("客参"),
            ),
          ),
          Transform.rotate(
            angle: (7.5 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 860),
              child: star_gods_tag("飞符"),
            ),
          ),
          Transform.rotate(
            angle: (-7.5 * pi) / 180,
            origin: Offset.zero,
            child: Container(
              margin: const EdgeInsets.only(top: 860),
              child: star_gods_tag("飞符"),
            ),
          )
        ],
      ),
    );
  }

  Widget sixteen_gong_and_gods() {
    // double rotatedDegree = 135 + 22.5;
    double rotatedDegree = (135 + 11.25) * pi / 180;
    return Transform.rotate(
      angle: rotatedDegree,
      origin: Offset.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 594,
            height: 594,
            decoration: BoxDecoration(
              // color: Colors.red.withOpacity(.1),
              borderRadius: BorderRadius.circular(594),
              border: Border.all(color: Colors.grey.withOpacity(.2), width: 1),
            ),
            child: drawRingWithTextList(590, 34, sixteenGongNameSeq,
                innerPadding: 6),
          ),
          Container(
            width: 664,
            height: 664,
            decoration: BoxDecoration(
              // color: Colors.red.withOpacity(.1),
              borderRadius: BorderRadius.circular(664),
              border: Border.all(color: Colors.grey.withOpacity(.4), width: 1),
            ),
            child: drawRingWithTextList(660, 32, sixteenGodsNameSeq,
                innerPadding: 6),
          ),
        ],
      ),
    );
  }

  Widget eight_gong_ring() {
    double rotatedDegree = 135 + 11.25;
    var gongList = [
      ConstantTaiYiNineGongDataClass(
          "易气", "冬至", "叶蛰", "坎", "捌", const Tuple2("子", null)),
      ConstantTaiYiNineGongDataClass(
          "和气", "立春", "天留", "艮", "叁", const Tuple2("丑", "寅"),
          tianMenDiHu: "鬼方"),
      ConstantTaiYiNineGongDataClass(
          "绝气", "春分", "仓门", "震", "肆", const Tuple2("卯", null)),
      ConstantTaiYiNineGongDataClass(
          "绝阴", "立夏", "阴洛", "巽", "玖", const Tuple2("辰", "巳"),
          tianMenDiHu: "地户"),
      ConstantTaiYiNineGongDataClass(
          "易气", "夏至", "上天", "离", "贰", const Tuple2("午", null)),
      ConstantTaiYiNineGongDataClass(
          "和气", "立秋", "玄委", "坤", "柒", const Tuple2("未", "申"),
          tianMenDiHu: "人路"),
      ConstantTaiYiNineGongDataClass(
          "绝气", "秋分", "苍果", "兑", "陆", const Tuple2("酉", null)),
      ConstantTaiYiNineGongDataClass(
          "绝阳", "立冬", "新洛", "乾", "壹", const Tuple2("戌", "亥"),
          tianMenDiHu: "天门"),
    ];
    var listWidget = <Widget>[];
    for (var i = 0; i < gongList.length; i++) {
      listWidget.add(Transform.rotate(
        angle: (11.25 + 45 * i + 180) * pi / 180,
        child: Container(
          margin: const EdgeInsets.only(top: 400),
          height: 120,
          width: 120,
          // color: Colors.grey,
          child: Opacity(
            opacity: .6,
            child: Transform.scale(
                scale: 1,
                // child: centerContent(taiYi)
                child: TaiYiGongContentBackground(
                  taiYi: gongList[i],
                  nineAreaNameTextStyle: nineAreaNameTextStyle,
                  nineGongNameTextStyle: nineGongNameTextStyle,
                  nineGongNumberTextStyle: nineGongNumberTextStyle,
                  eightSeasonTextStyle: eightSeasonTextStyle,
                  eightGuaMapper: eightGuaMapper,
                  zodiacColors: zodiacColors,
                  seasons24ColorMapper: Seasons24ColorMapper,
                  eightSkyDoorTextStyle: eightSkyDoorTextStyle,
                )),
          ),
        ),
      ));
    }
    return Transform.rotate(
      // angle: 135-22.5 * pi / 180,
      angle: rotatedDegree * pi / 180,
      origin: Offset.zero,
      child: SizedBox(
        width: 720,
        height: 720,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: 22.5 * pi / 180,
              child: Container(
                  width: 520,
                  height: 520,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(520),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      drawRingWithTextList(519, 120, zodiacTextList,
                          innerPadding: 10, rotatedAngle: 22.5 * pi / 360),
                      ...listWidget,
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  @deprecated
  Widget build_body_bak() {
    double rotatedDegree = 135 + 11.25;
    return Container(
        width: 1000,
        height: 1000,
        alignment: Alignment.center,
        color: Colors.red.withOpacity(.1),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  // angle: 135-22.5 * pi / 180,
                  angle: rotatedDegree * pi / 180,
                  origin: Offset.zero,
                  child: SizedBox(
                    width: 720,
                    height: 720,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: 22.5 * pi / 180,
                          child: Container(
                              width: 302,
                              height: 302,
                              decoration: BoxDecoration(
                                // color: Colors.red.withOpacity(.1),
                                borderRadius: BorderRadius.circular(302),
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              child: drawRingWithTextList(
                                  302, 64, zodiacTextList,
                                  innerPadding: 10,
                                  rotatedAngle: 22.5 * pi / 360)),
                        ),
                        Transform.rotate(
                          angle: 22.5 * pi / 180,
                          child: Container(
                              width: 302,
                              height: 302,
                              decoration: BoxDecoration(
                                // color: Colors.red.withOpacity(.1),
                                borderRadius: BorderRadius.circular(302),
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              child: drawRingWithTextList(
                                  302, 64, zodiacTextList,
                                  innerPadding: 10,
                                  rotatedAngle: 22.5 * pi / 360)),
                        ),
                        // 16宫
                        Container(
                          width: 372,
                          height: 372,
                          decoration: BoxDecoration(
                            // color: Colors.red.withOpacity(.1),
                            borderRadius: BorderRadius.circular(372),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: drawRingWithTextList(
                              372, 32, sixteenGongNameSeq,
                              innerPadding: 6),
                        ),
                        Container(
                          width: 435,
                          height: 435,
                          decoration: BoxDecoration(
                            // color: Colors.red.withOpacity(.1),
                            borderRadius: BorderRadius.circular(435),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: drawRingWithTextList(
                              435, 32, sixteenGodsNameSeq,
                              innerPadding: 6),
                        ),
                        Container(
                          width: 720,
                          height: 720,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(350))),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              drawRingWithTextList(
                                  720,
                                  142,
                                  List.generate(16, (index) => const Text(""))
                                      .toList(),
                                  innerPadding: 6),
                              Transform.rotate(
                                angle: (22.5 * 0 * pi) / 180,
                                origin: Offset.zero,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 516),
                                  color: Colors.black.withOpacity(.1),
                                  height: 56,
                                  width: 24,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "太",
                                        style: TaiYiClassicTheme.getChineseStyle(
                                            height: 1.0,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text("乙",
                                          style: TaiYiClassicTheme.getChineseStyle(
                                              height: 1.0,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700))
                                    ],
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: (22.5 * 0 * pi) / 180,
                                origin: Offset.zero,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 520 + 56 + 56 + 8),
                                  color: Colors.black.withOpacity(.1),
                                  height: 56,
                                  width: 24,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "始",
                                        style: TaiYiClassicTheme.getChineseStyle(
                                            height: 1.0,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text("击",
                                          style: TaiYiClassicTheme.getChineseStyle(
                                              height: 1.0,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700))
                                    ],
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: (7 * pi) / 180,
                                origin: Offset.zero,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 520 + 56 + 56 + 8),
                                  color: Colors.black.withOpacity(.1),
                                  height: 56,
                                  width: 24,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "客",
                                        style: TaiYiClassicTheme.getChineseStyle(
                                            height: 1.0,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text("大",
                                          style: TaiYiClassicTheme.getChineseStyle(
                                              height: 1.0,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700))
                                    ],
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: (-7 * pi) / 180,
                                origin: Offset.zero,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 520 + 56 + 56 + 8),
                                  color: Colors.black.withOpacity(.1),
                                  height: 56,
                                  width: 24,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "飞",
                                        style: TaiYiClassicTheme.getChineseStyle(
                                            height: 1.0,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text("符 ",
                                          style: TaiYiClassicTheme.getChineseStyle(
                                              height: 1.0,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700))
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 后天八卦

                // 16神
                //
                // Transform.rotate(
                //   // angle: 135-22.5 * pi / 180,
                //   angle: rotatedDegree *pi/180,
                //   origin: Offset.zero,
                //   child:
                // ),
                Container(
                    width: 172,
                    height: 172,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.1),
                      borderRadius: BorderRadius.circular(172),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "立命",
                                  style: TextStyle(fontSize: 12, height: 1.2),
                                ),
                                // SizedBox(width: 4,),
                                Text(
                                  "昴日鸡",
                                  style: TextStyle(fontSize: 14, height: 1.2),
                                ),
                                Text(
                                  "六度",
                                  style: TextStyle(fontSize: 12, height: 1.2),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "运",
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text("癸", style: TextStyle(fontSize: 16)),
                                Text("卯", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("流", style: TextStyle(fontSize: 10)),
                                Text("辛", style: TextStyle(fontSize: 16)),
                                Text("丑", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "年",
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text("癸", style: TextStyle(fontSize: 16)),
                                Text("卯", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("月", style: TextStyle(fontSize: 10)),
                                Text("辛", style: TextStyle(fontSize: 16)),
                                Text("丑", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "日",
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text("癸", style: TextStyle(fontSize: 16)),
                                Text("卯", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("时", style: TextStyle(fontSize: 10)),
                                Text("辛", style: TextStyle(fontSize: 16)),
                                Text("丑", style: TextStyle(fontSize: 16)),
                              ],
                            )
                          ],
                        ),
                        Column(
                          children: [Text("ok3"), Text("ok3")],
                        ),
                      ],
                    ))
              ],
            ),
          ],
        ));
  }

  Widget drawRing(double size, double ringWidth, List<String> contentList,
      TextStyle textStyle,
      {double innerPadding = 2}) {
    double outerRadius = size / 2;
    double innerRadius = outerRadius - ringWidth;
    return Container(
        alignment: Alignment.center,
        height: size,
        width: size,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(size),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          angle: 105 * pi / 180,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(size, size),
            painter: CircleRingPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
              textList: contentList,
              isAntiClockwise: true,
              innerPadding: innerPadding,
              isReverseText: false,
              isHorizontalText: true,
              textStyle: textStyle.copyWith(height: 1.2),
            ),
          ),
        ));
  }

  Widget drawRingWithTextList(
      double size, double ringWidth, List<Text> contentList,
      {double innerPadding = 2, double rotatedAngle = 0}) {
    double outerRadius = size / 2;
    double innerRadius = outerRadius - ringWidth;
    return Container(
        alignment: Alignment.center,
        height: size,
        width: size,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(size),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          // angle: 105 * pi / 180,
          angle: rotatedAngle,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(size, size),
            painter: TextCircleRingPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
              textList: contentList,
              isAntiClockwise: true,
              innerPadding: innerPadding,
              isReverseText: false,
              isHorizontalText: true,
            ),
          ),
        ));
  }
}

// 当前为赤道
class TwentyEightStarsCircle extends CustomPainter {
  static const int TOTAL = 28;
  final double innerRadius;
  final double outerRadius;
  // tuple5: 东南西北, 星宿名,星宿全称, 颜色, 角度
  List<Tuple5<int, String, String, Color, num>> twentyEightStarsList;
  late TextStyle textStyle;
  bool isReverseText = false;
  bool isReverseOrderSequence = false;

  double innerPadding = 12;
  double outerPadding = 12;

  TwentyEightStarsCircle({
    required this.innerRadius,
    required this.outerRadius,
    required this.twentyEightStarsList,
    this.isReverseText = true,
    this.isReverseOrderSequence = false,
    this.innerPadding = 12,
    this.outerPadding = 12,
    this.textStyle =
        const TextStyle(color: Colors.black, fontSize: 18, height: 1.2),
  });

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
    final center = Offset(size.width / 2, size.height / 2);
    // canvas.save();

    canvas.translate(size.width / 2, size.height / 2);
    // canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);

    // final res = sweepAngleDegree *0.5 * math.pi / 180;
    // final double startAngle = math.pi / 2 - res;
    // final double sweepAngle = sweepAngleDegree * math.pi / 180;
    const double startAngle = 0;
    final fanRingWidth = outerRadius - innerRadius;

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = fanRingWidth;

    // canvas.translate(center.dx, center.dy);
    // 计算每个扇环的中心角度
    // double angle = startAngle;
    double arcDrawCircleRadius = innerRadius + (fanRingWidth * 0.5);
    // double textRotationAngle =startAngle + sweepAngle / 2;
    double textRotationAngle = startAngle;

    // 12点方向为起始点
    canvas.rotate(pi - pi / 4);
    // 9点方向为起始点 -- not work
    // canvas.rotate(pi/4);
    // 6点方向为起始点 -- not work
    // canvas.rotate(-pi/4);
    // 3点方向为起始点 -- not work
    // canvas.rotate(pi + pi/4);

    double angleCounter = startAngle;
    for (int i = 0; i < TOTAL; i++) {
      double sweepAngle = -twentyEightStarsList[i].item5 * pi / 180;
      // double sweepAngle = 0.18954444444444445;
      // 绘制扇环
      Path path = Path()
        ..addArc(
          Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius),
          angleCounter,
          sweepAngle,
        );
      // canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius), startAngle, sweepAngle, false, paint);
      paint.color = twentyEightStarsList[i].item4;
      canvas.drawPath(path, paint);
      angleCounter += sweepAngle;
    }
    double prevAngle = 0;
    canvas.rotate(pi + pi / 2);

    double radi = pi / 360;
    double offsetRadi = 5 * radi;

    for (int i = 0; i < TOTAL; i++) {
      String text = twentyEightStarsList[i].item2;
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
      // angle to radian
      num currentAngle = twentyEightStarsList[i].item5;
      double angle = prevAngle - currentAngle * radi + offsetRadi;
      canvas.rotate(angle);
      prevAngle = -(currentAngle * radi + offsetRadi);
      textPainter.paint(canvas, Offset(0, innerRadius + innerPadding));
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

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}

class IndicatorScalePainter extends CustomPainter {
  final double ringWidth;
  final double tickLength;
  final double indicatorAngle;

  IndicatorScalePainter({
    required this.indicatorAngle,
    required this.ringWidth,
    required this.tickLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius - ringWidth;
    // final Paint ringPaint = Paint()
    //   ..color = Colors.black
    //   ..strokeWidth = .5
    //   ..style = PaintingStyle.stroke;

    // Draw outer ring
    // canvas.drawCircle(Offset(centerX, centerY), outerRadius, ringPaint);

    // Draw inner ring
    // canvas.drawCircle(Offset(centerX, centerY), innerRadius, ringPaint);

    final Paint scalePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw regular tick marks
    final double angle = indicatorAngle * pi / 180;
    double length = tickLength;
    // if (i != 0){
    //   if (i % 10 == 0){
    //     length = tickLength *2;
    //   }else if (i % 5 == 0){
    //     length = tickLength + tickLength *0.5;
    //   }
    // }
    final double outerX = centerX + outerRadius * cos(angle);
    final double outerY = centerY + outerRadius * sin(angle);
    final double innerX = centerX + (outerRadius - length) * cos(angle);
    final double innerY = centerY + (outerRadius - length) * sin(angle);
    // Draw scale line near the outer ring
    canvas.drawLine(
      Offset(outerX, outerY),
      Offset(innerX, innerY),
      scalePaint,
    );

    final double innerTickStartX = centerX + innerRadius * cos(angle);
    final double innerTickStartY = centerY + innerRadius * sin(angle);
    final double innerTickEndX = centerX + (innerRadius + length) * cos(angle);
    final double innerTickEndY = centerY + (innerRadius + length) * sin(angle);

    // Draw scale line near the inner ring
    canvas.drawLine(
      Offset(innerTickStartX, innerTickStartY),
      Offset(innerTickEndX, innerTickEndY),
      scalePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
