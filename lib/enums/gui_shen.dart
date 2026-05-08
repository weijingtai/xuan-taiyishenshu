/// 太乙贵神（九贵神）枚举。
///
/// 宫位编号（[palaceNum]）对应洛书九宫（1-9），
/// 顺序为：太乙→摄提→轩辕→招摇→天符→青龙→咸池→太阴→天乙。
enum EnumGuiShen {
  taiYi(1, '太乙', '太', '帝车之神，主兵主胜'),
  shetiTi(2, '摄提', '摄', '岁神之辅，主农主耕'),
  xuanYuan(3, '轩辕', '轩', '黄帝之神，主人主官'),
  zhaoYao(4, '招摇', '招', '将星之神，主战主将'),
  tianFu(5, '天符', '符', '中枢之神，主令主符'),
  qingLong(6, '青龙', '龙', '东方木神，主福主贵'),
  xianChi(7, '咸池', '池', '水宫之神，主财主欲'),
  taiYin(8, '太阴', '阴', '月神之使，主阴主密'),
  tianYi(9, '天乙', '乙', '天一贵神，主吉主助');

  const EnumGuiShen(this.palaceNum, this.label, this.shortLabel, this.meaning);

  /// 洛书宫位编号（1-9，对应宫位表）。
  final int palaceNum;

  /// 全称，如「太乙」。
  final String label;

  /// 单字缩写，用于宫格标注。
  final String shortLabel;

  /// 简要含义。
  final String meaning;

  /// 顺行序列：太乙→攝提→軒轅→招搖→天符→青龍→咸池→太陰→天乙
  static const forwardOrder = [
    EnumGuiShen.taiYi,
    EnumGuiShen.shetiTi,
    EnumGuiShen.xuanYuan,
    EnumGuiShen.zhaoYao,
    EnumGuiShen.tianFu,
    EnumGuiShen.qingLong,
    EnumGuiShen.xianChi,
    EnumGuiShen.taiYin,
    EnumGuiShen.tianYi,
  ];

  /// 逆行序列：太乙→天乙→太陰→咸池→青龍→天符→招搖→軒轅→攝提
  /// 用于值事贵神定位：命起一宫逆行九宫。
  static const reverseOrder = [
    EnumGuiShen.taiYi,
    EnumGuiShen.tianYi,
    EnumGuiShen.taiYin,
    EnumGuiShen.xianChi,
    EnumGuiShen.qingLong,
    EnumGuiShen.tianFu,
    EnumGuiShen.zhaoYao,
    EnumGuiShen.xuanYuan,
    EnumGuiShen.shetiTi,
  ];
}
