import 'package:flutter/material.dart';
import '../theme/taiyi_classic_theme.dart';
import 'package:xuan_four_zhu_card/widgets/season_24_tag.dart';
import 'package:tuple/tuple.dart';

import '../models/ConstantNineGongDataClass.dart';
import '../widgets/tai_yi_gong_content_background.dart';

class RectanglePanel extends StatefulWidget {
  const RectanglePanel({super.key});

  @override
  State<RectanglePanel> createState() => _RectanglePanelState();
}

class _RectanglePanelState extends State<RectanglePanel> {
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            width: 1200,
            height: 1200,
            alignment: Alignment.center,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 24,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    panel(),
                  ],
                ),
                Container(
                  width: 1200,
                  height: 256,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      testBuild24Seasons()
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget testBuild24Seasons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            tag24Seasons("立春",
                fontColor: const Color.fromRGBO(164, 211, 178, 1),
                borderColor: const Color.fromRGBO(164, 211, 178, 1),
                backgroundColor: const Color.fromRGBO(164, 211, 178, .2),
                isBold: true),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("雨水",
                fontColor: const Color.fromRGBO(138, 154, 91, 1),
                borderColor: const Color.fromRGBO(138, 154, 91, 1),
                backgroundColor: const Color.fromRGBO(138, 154, 91, .2)),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("惊蛰",
                fontColor: const Color.fromRGBO(128, 128, 0, 1),
                borderColor: const Color.fromRGBO(128, 128, 0, 1),
                backgroundColor: const Color.fromRGBO(128, 128, 0, .2)),
            const SizedBox(
              width: 32,
            ),
            // tag24Seasons("春分",fontColor: Colors.green.shade400,borderColor: Colors.green.shade400,backgroundColor: Colors.green.withOpacity(.2)),
            tag24Seasons("春分",
                fontColor: const Color.fromRGBO(120, 146, 98, 1),
                borderColor: const Color.fromRGBO(120, 146, 98, 1),
                backgroundColor: const Color.fromRGBO(120, 146, 98, .2),
                isBold: true),
            const SizedBox(
              width: 12,
            ),
            // 苹果绿
            tag24Seasons("清明",
                fontColor: const Color.fromRGBO(141, 182, 0, 1),
                borderColor: const Color.fromRGBO(141, 182, 0, 1),
                backgroundColor: const Color.fromRGBO(141, 182, 0, .2)),
            const SizedBox(
              width: 12,
            ),
            // 柳绿
            tag24Seasons("谷雨",
                fontColor: const Color.fromRGBO(164, 198, 57, 1),
                borderColor: const Color.fromRGBO(164, 198, 57, 1),
                backgroundColor: const Color.fromRGBO(164, 198, 57, .2)),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // tag24Seasons("立夏",fontColor: Color.fromRGBO(255, 77, 0, 1),borderColor: Color.fromRGBO(255, 77, 0, 1),backgroundColor:Color.fromRGBO(255, 77, 0, .2)),
            // 夏季节气颜色 - 红色系
            tag24Seasons("立夏",
                fontColor: const Color.fromRGBO(255, 69, 0, 1),
                borderColor: const Color.fromRGBO(255, 69, 0, 1),
                backgroundColor: const Color.fromRGBO(255, 69, 0, .2),
                isBold: true),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("小满",
                fontColor: const Color.fromRGBO(255, 105, 97, 1),
                borderColor: const Color.fromRGBO(255, 105, 97, 1),
                backgroundColor: const Color.fromRGBO(255, 105, 97, .2)),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("芒种",
                fontColor: const Color.fromRGBO(255, 182, 193, 1),
                borderColor: const Color.fromRGBO(255, 182, 193, 1),
                backgroundColor: const Color.fromRGBO(255, 182, 193, .2)),
            const SizedBox(
              width: 32,
            ),
            tag24Seasons("夏至",
                fontColor: const Color.fromRGBO(205, 92, 92, 1),
                borderColor: const Color.fromRGBO(205, 92, 92, 1),
                backgroundColor: const Color.fromRGBO(205, 92, 92, .2),
                isBold: true),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("小暑",
                fontColor: const Color.fromRGBO(178, 34, 34, 1),
                borderColor: const Color.fromRGBO(178, 34, 34, 1),
                backgroundColor: const Color.fromRGBO(178, 34, 34, .2)),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("大暑",
                fontColor: const Color.fromRGBO(139, 0, 0, 1),
                borderColor: const Color.fromRGBO(139, 0, 0, 1),
                backgroundColor: const Color.fromRGBO(139, 0, 0, .2)),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            tag24Seasons("立秋",
                fontColor: const Color.fromRGBO(228, 158, 0, 1),
                borderColor: const Color.fromRGBO(228, 158, 0, 1),
                backgroundColor: const Color.fromRGBO(228, 158, 0, .2),
                isBold: true),
            // tag24Seasons("立秋", fontColor: Color.fromRGBO(245, 222, 179, 1), borderColor: Color.fromRGBO(245, 222, 179, 1), backgroundColor: Color.fromRGBO(245, 222, 179, .2)),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("处暑",
                fontColor: const Color.fromRGBO(255, 215, 0, 1),
                borderColor: const Color.fromRGBO(255, 215, 0, 1),
                backgroundColor: const Color.fromRGBO(255, 215, 0, .2)),
            const SizedBox(
              width: 12,
            ),
            // tag24Seasons("白露", fontColor: Color.fromRGBO(255, 239, 213, 1), borderColor: Color.fromRGBO(255, 239, 213, 1), backgroundColor: Color.fromRGBO(255, 239, 213, .2)),
            tag24Seasons("白露",
                fontColor: const Color.fromRGBO(252, 211, 77, 1),
                borderColor: const Color.fromRGBO(252, 211, 77, 1),
                backgroundColor: const Color.fromRGBO(252, 211, 77, .2)),
            const SizedBox(
              width: 32,
            ),
            tag24Seasons("秋分",
                fontColor: const Color.fromRGBO(237, 145, 33, 1),
                borderColor: const Color.fromRGBO(237, 145, 33, 1),
                backgroundColor: const Color.fromRGBO(237, 145, 33, .2),
                isBold: true),
            const SizedBox(
              width: 12,
            ),
            // tag24Seasons("霜降", fontColor: Color.fromRGBO(165, 42, 42, 1), borderColor: Color.fromRGBO(165, 42, 42, 1), backgroundColor: Color.fromRGBO(165, 42, 42, .2)),
            // 秋季节气颜色 - 金黄色系
            tag24Seasons("寒露",
                fontColor: const Color.fromRGBO(255, 193, 37, 1),
                borderColor: const Color.fromRGBO(255, 193, 37, 1),
                backgroundColor: const Color.fromRGBO(255, 193, 37, .2)),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("霜降",
                fontColor: const Color.fromRGBO(248, 197, 143, 1),
                borderColor: const Color.fromRGBO(248, 197, 143, 1),
                backgroundColor: const Color.fromRGBO(248, 197, 143, .2)),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // tag24Seasons("立冬",fontColor: Color.fromRGBO(51,102,153, 1),borderColor: Color.fromRGBO(51,102,153, 1),backgroundColor:Color.fromRGBO(51,102,153, .2)),
            // tag24Seasons("立冬", fontColor: Color.fromRGBO(220, 220, 220, 1), borderColor: Color.fromRGBO(220, 220, 220, 1), backgroundColor: Color.fromRGBO(220, 220, 220, .2)),
            tag24Seasons("立冬",
                fontColor: const Color.fromRGBO(192, 192, 192, 1),
                borderColor: const Color.fromRGBO(192, 192, 192, 1),
                backgroundColor: const Color.fromRGBO(192, 192, 192, .2),
                isBold: true),
            const SizedBox(
              width: 12,
            ),
            // tag24Seasons("立冬", fontColor: Color.fromRGBO(176, 224, 230, 1), borderColor: Color.fromRGBO(176, 224, 230, 1), backgroundColor: Color.fromRGBO(176, 224, 230, .2)),
            // 冬季节气颜色 - 蓝色系
            tag24Seasons("小雪",
                fontColor: const Color.fromRGBO(173, 216, 230, 1),
                borderColor: const Color.fromRGBO(173, 216, 230, 1),
                backgroundColor: const Color.fromRGBO(173, 216, 230, .2)),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("大雪",
                fontColor: const Color.fromRGBO(0, 191, 255, 1),
                borderColor: const Color.fromRGBO(0, 191, 255, 1),
                backgroundColor: const Color.fromRGBO(0, 191, 255, .2)),
            const SizedBox(
              width: 32,
            ),

            tag24Seasons("冬至",
                fontColor: const Color.fromRGBO(61, 89, 171, 1),
                borderColor: const Color.fromRGBO(61, 89, 171, 1),
                backgroundColor: const Color.fromRGBO(61, 89, 171, .2),
                isBold: true),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("小寒",
                fontColor: const Color.fromRGBO(0, 0, 139, 1),
                borderColor: const Color.fromRGBO(0, 0, 139, 1),
                backgroundColor: const Color.fromRGBO(0, 0, 139, .2)),
            const SizedBox(
              width: 12,
            ),
            tag24Seasons("大寒",
                fontColor: const Color.fromRGBO(75, 0, 130, 1),
                borderColor: const Color.fromRGBO(75, 0, 130, 1),
                backgroundColor: const Color.fromRGBO(75, 0, 130, .2)),
          ],
        )
      ],
    );
  }

  Widget tag24Seasons(
    String name, {
    Color fontColor = Colors.grey,
    Color borderColor = Colors.grey,
    Color backgroundColor = Colors.white,
    bool isBold = false,
  }) {
    return Season24Tag(
      name: name,
      fontColor: fontColor,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      isBold: isBold,
    );

    var listContent = name.split("");
    final first = listContent.first;
    final second = listContent.last;
    // TextStyle fontStyle = TextStyle(
    //     height: 1,
    //     fontSize: 14,
    //     fontWeight: isBold?FontWeight.w600:FontWeight.normal,
    //     color: fontColor,
    //     shadows: [
    //       Shadow(color: Colors.white.withOpacity(.2),offset: Offset(1,1),blurRadius: 1)
    //     ]
    // );
    TextStyle fontStyle = TaiYiClassicTheme.getSerifStyle(
        height: 1,
        fontSize: 14,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        color: fontColor,
        shadows: [
          Shadow(
              color: Colors.white.withOpacity(.2),
              offset: const Offset(1, 1),
              blurRadius: 1)
        ]);
    return Container(
      padding: const EdgeInsets.only(bottom: 3, left: 3, right: 3),
      decoration: isBold
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 2),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            )
          : const BoxDecoration(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 6),
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: isBold ? 2 : 1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: borderColor.withOpacity(.2),
                  offset: const Offset(1, 1),
                  blurRadius: 1)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(first, style: fontStyle),
            Text(second, style: fontStyle),
          ],
        ),
      ),
    );
  }

  Widget panel() {
    var nearBorderSide = const BorderSide(color: Colors.black, width: 1);
    var farBorderSide = const BorderSide(color: Colors.grey, width: 1);
    var normalBorderSide = BorderSide(color: Colors.grey.shade300, width: 1);

    return Container(
        width: 256 * 3,
        height: 256 * 3,
        alignment: Alignment.center,
        // color: Colors.red.withOpacity(.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                gongWithDoorName(
                    ConstantTaiYiNineGongDataClass(
                        "绝阴", "立夏", "阴洛", "巽", "玖", const Tuple2("辰", "巳"),
                        tianMenDiHu: "地户"),
                    true,
                    false,
                    Border(
                        top: farBorderSide,
                        left: farBorderSide,
                        bottom: farBorderSide,
                        right: normalBorderSide)),
                gongWithDoorName(
                    ConstantTaiYiNineGongDataClass(
                        "易气", "夏至", "上天", "离", "贰", const Tuple2("午", null)),
                    false,
                    false,
                    Border(top: farBorderSide, right: normalBorderSide)),
                gongWithDoorName(
                    ConstantTaiYiNineGongDataClass(
                        "和气", "立秋", "玄委", "坤", "柒", const Tuple2("未", "申"),
                        tianMenDiHu: "人路"),
                    false,
                    false,
                    Border(
                        right: farBorderSide,
                        top: farBorderSide,
                        bottom: normalBorderSide)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                gongWithDoorName(
                    ConstantTaiYiNineGongDataClass(
                        "绝气", "春分", "仓门", "震", "肆", const Tuple2("卯", null)),
                    true,
                    true,
                    Border(
                        top: nearBorderSide,
                        left: nearBorderSide,
                        bottom: normalBorderSide)),
                Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                      border: Border(
                    left: nearBorderSide,
                    bottom: nearBorderSide,
                    right: farBorderSide,
                    top: farBorderSide,
                  )),
                ),
                gongWithDoorName(
                    ConstantTaiYiNineGongDataClass(
                        "绝气", "秋分", "苍果", "兑", "陆", const Tuple2("酉", null)),
                    false,
                    false,
                    Border(right: farBorderSide, bottom: farBorderSide)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                gongWithDoorName(
                    ConstantTaiYiNineGongDataClass(
                        "和气", "立春", "天留", "艮", "叁", const Tuple2("丑", "寅"),
                        tianMenDiHu: "鬼方"),
                    true,
                    true,
                    Border(left: nearBorderSide, bottom: nearBorderSide)),
                gongWithDoorName(
                    ConstantTaiYiNineGongDataClass(
                        "易气", "冬至", "叶蛰", "坎", "捌", const Tuple2("子", null)),
                    true,
                    true,
                    Border(
                        bottom: nearBorderSide,
                        left: normalBorderSide,
                        right: normalBorderSide)),
                gongWithDoorName(
                    ConstantTaiYiNineGongDataClass(
                        "绝阳", "立冬", "新洛", "乾", "壹", const Tuple2("戌", "亥"),
                        tianMenDiHu: "天门"),
                    false,
                    true,
                    Border(
                        top: nearBorderSide,
                        right: nearBorderSide,
                        bottom: nearBorderSide)),
              ],
            ),
          ],
        ));
  }

  late TextStyle twelveDiZhiTextStyle;
  TextStyle getTwelveDiZhiTextStyle(String diZhiStr) {
    Color fontColor = zodiacColors[diZhiStr]!;
    return twelveDiZhiTextStyle.copyWith(color: fontColor.withOpacity(.6));
  }

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
  TextStyle nineAreaNameTextStyle = const TextStyle(
    color: Colors.grey,
    fontSize: 16,
    height: 1,
  );
  late TextStyle eightSeasonTextStyle;
  @override
  void initState() {
    super.initState();
    eightSeasonTextStyle = TaiYiClassicTheme.getTitleStyle(
      color: Colors.grey,
      fontSize: 16,
      height: 1,
    );
    twelveDiZhiTextStyle = TaiYiClassicTheme.getChineseStyle(
      color: Colors.grey,
      fontSize: 24,
      height: 1,
      fontWeight: FontWeight.w500,
    );
    nineAreaNameTextStyle = TextStyle(
      color: Colors.grey,
      fontSize: 16,
      height: 1,
    );
  }

  TextStyle eightSkyDoorTextStyle = TaiYiClassicTheme.getTitleStyle(
    fontSize: 16,
    color: Colors.grey,
    fontWeight: FontWeight.w600,
  );

  Widget _buildLeftTopCorner(ConstantTaiYiNineGongDataClass taiYi) {
    // if (taiYi.name == "乾"){
    //   return _buildCornerBox(taiYi.yinYangArea, Alignment.topLeft);
    // }else
    if (taiYi.name == "巽") {
      return _buildCornerBox(taiYi.tianMenDiHu!, Alignment.topLeft);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildRightTopCorner(ConstantTaiYiNineGongDataClass taiYi) {
    // if (taiYi.name == "艮"){
    //   return _buildCornerBox(taiYi.yinYangArea, Alignment.topRight);
    // }else
    if (taiYi.name == "坤") {
      return _buildCornerBox(taiYi.tianMenDiHu!, Alignment.topRight);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildRightBottomCorner(ConstantTaiYiNineGongDataClass taiYi) {
    // if (taiYi.name ==  "巽"){
    //   return _buildCornerBox(taiYi.yinYangArea, Alignment.bottomRight);
    // }else
    if (taiYi.name == "乾") {
      return _buildCornerBox(taiYi.tianMenDiHu!, Alignment.bottomRight);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildLeftBottomCorner(ConstantTaiYiNineGongDataClass taiYi) {
    // if (taiYi.name ==  "坤"){
    //   return _buildCornerBox(taiYi.yinYangArea, Alignment.bottomLeft);
    // }else
    if (taiYi.name == "艮") {
      return _buildCornerBox(taiYi.tianMenDiHu!, Alignment.bottomLeft);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget centerContent(ConstantTaiYiNineGongDataClass taiYi) {
    var seasonName = taiYi.eightSeason;
    Color color = Seasons24ColorMapper[seasonName] ?? Colors.grey;
    double height = 120;
    return SizedBox(
      height: height,
      width: height,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    // height: 40,
                    // width: 40,
                    // color: Colors.blue.withOpacity(.1),
                    ),
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.blue.withOpacity(.3),
                    border: Border(
                      bottom: BorderSide(
                          color: nineAreaNameTextStyle.color ?? Colors.grey,
                          width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 2),
                  height: 20,
                  child: Text(
                    taiYi.yinYangArea,
                    style: nineAreaNameTextStyle,
                  ),
                  // child: Text,
                ),
                Container(
                    // color: Colors.blue.withOpacity(.5),
                    ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  width: 32,
                  padding: const EdgeInsets.only(top: 8),
                  // color: Colors.red.withOpacity(.1),
                  child: Column(
                    children: [
                      tag24Seasons(taiYi.eightSeason,
                          fontColor: color,
                          borderColor: color,
                          backgroundColor: color.withOpacity(.2)),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
              Container(
                height: 70,
                width: 70,
                // color: Colors.red.withOpacity(.3),
                alignment: Alignment.center,
                child: Text(
                  taiYi.name,
                  style: nineGongNameTextStyle,
                ),
              ),
              Expanded(
                child: Container(
                  height: 70,
                  width: 20,
                  // color: Colors.red.withOpacity(.5),
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      Text(
                        taiYi.number,
                        style: nineGongNumberTextStyle,
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        eightGuaMapper[taiYi.name]!,
                        style: nineGongNumberTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    // height: 40,
                    // width: 40,
                    // color: Colors.orange.withOpacity(.1),
                    ),
                Container(
                    // height: 80,
                    // width: 80,
                    // color: Colors.orange.withOpacity(.3),
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "「${taiYi.skyDoor}」",
                      style: eightSeasonTextStyle,
                    ),
                  ],
                )),
                Container(
                    // color: Colors.orange.withOpacity(.5),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget centerContentBak(ConstantTaiYiNineGongDataClass taiYi) {
    var seasonName = taiYi.eightSeason;
    Color color = Seasons24ColorMapper[seasonName] ?? Colors.grey;
    double height = 120;
    return Row(
      children: [
        // 中间字左侧
        Expanded(
          child: Row(
            children: [
              _buildLeftSideBox(taiYi),
              const Expanded(child: SizedBox()), // Empty container for spacing
              SizedBox(
                height: height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: tag24Seasons(taiYi.eightSeason,
                          fontColor: color,
                          borderColor: color,
                          backgroundColor: color.withOpacity(.2),
                          isBold: false),
                      // child: _24SeasonsColorMapper
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          // color: Colors.blue,
          height: height,
          child: Column(
            children: [
              Container(
                height: 20,
                padding: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: nineAreaNameTextStyle.color ?? Colors.grey,
                        width: 1),
                  ),
                ),
                child: Text(
                  taiYi.yinYangArea,
                  style: nineAreaNameTextStyle,
                ),
              ),
              SizedBox(
                  height: 70,
                  child: _buildCenterSquare(taiYi.name, Colors.transparent)),
              Container(
                width: 72,
                height: 30,
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "「${taiYi.skyDoor}」",
                      style: eightSeasonTextStyle,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                height: height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    _buildNumberBox(taiYi.number, Colors.transparent),
                    const Expanded(child: SizedBox()),
                    Container(
                      height: 20,
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        eightGuaMapper[taiYi.name] ?? taiYi.name,
                        style: const TextStyle(
                            fontSize: 20, color: Colors.grey, height: 1),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()), // Empty container for spacing
              _buildRightSideBox(taiYi)
            ],
          ),
        ),
      ],
    );
  }

  Widget gongWithDoorName(ConstantTaiYiNineGongDataClass taiYi, bool isYangYin,
      bool isNear, Border border) {
    var seasonName = taiYi.eightSeason;
    Color color = Seasons24ColorMapper[seasonName] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.all(6),
      width: 256,
      height: 256,
      decoration: BoxDecoration(
        color: isYangYin ? Colors.white : Colors.grey.withOpacity(.1),
        border: border,
        // border: isNear?Border.all(color:Colors.black,width: 2):Border.all(color: Colors.grey,width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLeftTopCorner(taiYi),
                _buildGongTopCenter(taiYi),
                _buildRightTopCorner(taiYi),
              ],
            ),
          ),
          Row(
            children: [
              // 中间字左侧
              Expanded(
                child: Row(
                  children: [
                    _buildLeftSideBox(taiYi),
                    const Expanded(
                        child: SizedBox()), // Empty container for spacing
                  ],
                ),
              ),
              Opacity(
                opacity: .4,
                child: Transform.scale(
                    scale: .8,
                    // child: centerContent(taiYi)
                    child: TaiYiGongContentBackground(
                      taiYi: taiYi,
                      nineAreaNameTextStyle: nineAreaNameTextStyle,
                      nineGongNameTextStyle: nineGongNameTextStyle,
                      nineGongNumberTextStyle: nineGongNumberTextStyle,
                      eightGuaMapper: eightGuaMapper,
                      eightSeasonTextStyle: eightSeasonTextStyle,
                      zodiacColors: zodiacColors,
                      seasons24ColorMapper: Seasons24ColorMapper,
                    )),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                        child: SizedBox()), // Empty container for spacing
                    _buildRightSideBox(taiYi)
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLeftBottomCorner(taiYi),
                  _buildGongBottomCenter(taiYi),
                  _buildRightBottomCorner(taiYi)
                ]),
          ),
        ],
      ),
    );
  }

  Widget gong(
      ConstantTaiYiNineGongDataClass taiYi, bool isYangYin, bool isNear) {
    return Container(
      padding: const EdgeInsets.all(6),
      width: 256,
      height: 256,
      decoration: BoxDecoration(
        color: isYangYin ? Colors.white : Colors.grey.withOpacity(.1),
        border: isNear
            ? Border.all(color: Colors.grey, width: 1)
            : Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                taiYi.name == "乾"
                    ? _buildCornerBox(taiYi.yinYangArea, Alignment.topLeft)
                    : const Expanded(
                        child: SizedBox()), // Empty container for spacing
                _buildGongTopCenter(taiYi),
                taiYi.name == "艮"
                    ? _buildCornerBox(taiYi.yinYangArea, Alignment.topRight)
                    : const Expanded(
                        child: SizedBox()), // Empty container for spacing
                // const Expanded(child: SizedBox()), // Empty container for spacing
              ],
            ),
          ),
          Row(
            children: [
              _buildLeftSideBox(taiYi),
              _buildCenterSquare(taiYi.name, Colors.transparent),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Expanded(child: SizedBox()),
                          _buildNumberBox(taiYi.number, Colors.transparent),
                        ],
                      ),
                    ),
                    const Expanded(
                        child: SizedBox()), // Empty container for spacing
                    _buildRightSideBox(taiYi)
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  taiYi.name == "坤"
                      ? _buildCornerBox(taiYi.yinYangArea, Alignment.bottomLeft)
                      : const Expanded(
                          child: SizedBox()), // Empty container for spacing
                  _buildGongBottomCenter(taiYi),
                  taiYi.name == "巽"
                      ? _buildCornerBox(
                          taiYi.yinYangArea, Alignment.bottomRight)
                      : const Expanded(
                          child: SizedBox()), // Empty container for spacing
                ]),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSideBox(ConstantTaiYiNineGongDataClass taiYiKan) {
    if (taiYiKan.name == "巽") {
      String char = taiYiKan.diZhi.item1;
      return _buildSideBox(char, getTwelveDiZhiTextStyle(char),
          Alignment.centerLeft, Colors.transparent);
    } else if (taiYiKan.name == "艮") {
      String char = taiYiKan.diZhi.item2!;
      return _buildSideBox(char, getTwelveDiZhiTextStyle(char),
          Alignment.centerLeft, Colors.transparent);
    } else if (taiYiKan.name == "震") {
      String char = taiYiKan.diZhi.item1;
      return _buildSideBox(char, getTwelveDiZhiTextStyle(char),
          Alignment.centerLeft, Colors.transparent);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildRightSideBox(ConstantTaiYiNineGongDataClass taiYiKan) {
    if (taiYiKan.name == "坤") {
      String char = taiYiKan.diZhi.item2!;
      return _buildSideBox(char, getTwelveDiZhiTextStyle(char),
          Alignment.centerRight, Colors.transparent);
    } else if (taiYiKan.name == "兑") {
      String char = taiYiKan.diZhi.item1;
      return _buildSideBox(char, getTwelveDiZhiTextStyle(char),
          Alignment.centerRight, Colors.transparent);
    } else if (taiYiKan.name == "乾") {
      String char = taiYiKan.diZhi.item1;
      return _buildSideBox(char, getTwelveDiZhiTextStyle(char),
          Alignment.centerRight, Colors.transparent);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildGongBottomCenter(ConstantTaiYiNineGongDataClass taiYiKan) {
    // if (taiYiKan.name == "离"){
    //   return _buildCenterBox(
    //       taiYiKan.yinYangArea,nineAreaNameTextStyle, Colors.transparent, Alignment.bottomCenter);
    // }
    // else
    if (taiYiKan.name == "坎") {
      String char = taiYiKan.diZhi.item1;
      return _buildCenterBox(char, getTwelveDiZhiTextStyle(char),
          Colors.transparent, Alignment.bottomCenter);
    } else if (taiYiKan.name == "艮") {
      String char = taiYiKan.diZhi.item1;
      return _buildCenterBox(char, getTwelveDiZhiTextStyle(char),
          Colors.transparent, Alignment.bottomCenter);
    } else if (taiYiKan.name == "乾") {
      String char = taiYiKan.diZhi.item2!;
      return _buildCenterBox(char, getTwelveDiZhiTextStyle(char),
          Colors.transparent, Alignment.bottomCenter);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildGongTopCenter(ConstantTaiYiNineGongDataClass taiYiKan) {
    // if (taiYiKan.name == "坎"){
    //   return _buildCenterBox(
    //       taiYiKan.yinYangArea, nineAreaNameTextStyle, Colors.transparent, Alignment.topCenter);
    // }
    // else
    if (taiYiKan.name == "坤") {
      String char = taiYiKan.diZhi.item1;
      return _buildCenterBox(char, getTwelveDiZhiTextStyle(char),
          Colors.transparent, Alignment.topCenter);
    } else if (taiYiKan.name == "离") {
      String char = taiYiKan.diZhi.item1;
      return _buildCenterBox(char, getTwelveDiZhiTextStyle(char),
          Colors.transparent, Alignment.topCenter);
    } else if (taiYiKan.name == "巽") {
      String char = taiYiKan.diZhi.item2!;
      return _buildCenterBox(char, getTwelveDiZhiTextStyle(char),
          Colors.transparent, Alignment.topCenter);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

// Helper function to build side boxes
  Widget _buildSideBox(
      String text, TextStyle style, Alignment alignment, Color color) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
        ),
        child: Align(
          alignment: alignment,
          child: Text(
            text,
            style: style,
          ),
        ),
      ),
    );
  }

// Helper function to build the center square
  Widget _buildCenterSquare(String text, Color color) {
    return SizedBox(
      width: 70,
      height: 70,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
        ),
        child: Center(
          child: Text(
            text,
            style: nineGongNameTextStyle,
          ),
        ),
      ),
    );
  }

// Helper function to build the number box
  Widget _buildNumberBox(String number, Color color) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          // color: Colors.black,
          ),
      child: Text(
        number,
        style: nineGongNumberTextStyle,
      ),
    );
  }

// Helper function to build corner boxes
  Widget _buildCornerBox(String text, Alignment alignment) {
    return Expanded(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Align(
          alignment: alignment,
          child: Text(
            text,
            style: nineAreaNameTextStyle,
          ),
        ),
      ),
    );
  }

// Helper function to build center boxes
  Widget _buildCenterBox(String text, TextStyle style, Color color,
      [Alignment alignment = Alignment.topCenter]) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
        ),
        child: Align(
          alignment: alignment,
          child: Text(
            text,
            style: style,
          ),
        ),
      ),
    );
  }
}
