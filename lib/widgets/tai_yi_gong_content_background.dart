import 'package:flutter/material.dart';
import 'package:common/widgets/season_24_tag.dart';

import '../models/ConstantNineGongDataClass.dart';

class TaiYiGongContentBackground extends StatelessWidget {
  final ConstantTaiYiNineGongDataClass taiYi;

  late Map<String, String> eightGuaMapper;
  late Map<String, Color> zodiacColors;
  late Map<String, Color> seasons24ColorMapper;

  TextStyle nineGongNumberTextStyle;
  TextStyle nineGongNameTextStyle;
  TextStyle nineAreaNameTextStyle;
  TextStyle eightSeasonTextStyle;
  TextStyle eightSkyDoorTextStyle;

  TaiYiGongContentBackground(
      {super.key,
      required this.taiYi,
      required this.eightGuaMapper,
      required this.zodiacColors,
      required this.seasons24ColorMapper,
      this.nineAreaNameTextStyle = const TextStyle(
        color: Colors.grey,
        fontSize: 16,
        height: 1,
      ),
      this.nineGongNameTextStyle = const TextStyle(
        color: Colors.grey,
        fontSize: 70,
        height: 1,
      ),
      this.nineGongNumberTextStyle = const TextStyle(
        color: Colors.grey,
        fontSize: 16,
        height: 1,
      ),
      this.eightSeasonTextStyle = const TextStyle(
        fontSize: 16,
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      ),
      this.eightSkyDoorTextStyle = const TextStyle(
        fontSize: 16,
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      )});

  @override
  Widget build(BuildContext context) {
    return centerContent(taiYi);
  }

  Widget centerContent(ConstantTaiYiNineGongDataClass taiYi) {
    var seasonName = taiYi.eightSeason;
    Color color = seasons24ColorMapper[seasonName] ?? Colors.grey;
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
                      Season24Tag(
                        name: taiYi.eightSeason,
                        fontColor: color,
                        borderColor: color,
                        backgroundColor: color.withOpacity(.2),
                        fontStyle: eightSeasonTextStyle,
                      ),
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
                Container(),
                Container(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "「${taiYi.skyDoor}」",
                      style: eightSkyDoorTextStyle,
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
}
