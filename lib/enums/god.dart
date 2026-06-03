import "package:metaphysics_core/enums.dart";
import 'gong.dart';

enum EnumZhengJianType {
  Zheng(YinYang.YANG, "正神", "正"),
  Jian(YinYang.YIN, "间神", "间");

  const EnumZhengJianType(this.yinYang, this.name, this.singleName);
  final YinYang yinYang;
  final String name;
  final String singleName;
}

// 文昌行宫位的顺序
const WenChang_Seq = [
  EnumTaiYiSixteenGods.Shen_WuDe,
  EnumTaiYiSixteenGods.You_TaiCu,
  EnumTaiYiSixteenGods.Xu_YinZhu,
  EnumTaiYiSixteenGods.Qian_YangDe,
  EnumTaiYiSixteenGods.Qian_YangDe,
  EnumTaiYiSixteenGods.Hai_DaYi,
  EnumTaiYiSixteenGods.Zi_DiZhu,
  EnumTaiYiSixteenGods.Chou_TaiYin,
  EnumTaiYiSixteenGods.Gen_HeDe,
  EnumTaiYiSixteenGods.Yin_LvShen,
  EnumTaiYiSixteenGods.Mao_GaoCong,
  EnumTaiYiSixteenGods.Chen_TaiYang,
  EnumTaiYiSixteenGods.Xun_DaJiong,
  EnumTaiYiSixteenGods.Si_DaShen,
  EnumTaiYiSixteenGods.Wu_DaWei,
  EnumTaiYiSixteenGods.Wei_TianDao,
  EnumTaiYiSixteenGods.Kun_DaWu,
  EnumTaiYiSixteenGods.Kun_DaWu
];
// 计神行宫的顺序
const JiShen_Seq = [
  EnumTaiYiSixteenGods.Yin_LvShen,
  EnumTaiYiSixteenGods.Chou_TaiYin,
  EnumTaiYiSixteenGods.Zi_DiZhu,
  EnumTaiYiSixteenGods.Hai_DaYi,
  EnumTaiYiSixteenGods.Xu_YinZhu,
  EnumTaiYiSixteenGods.You_TaiCu,
  EnumTaiYiSixteenGods.Shen_WuDe,
  EnumTaiYiSixteenGods.Wei_TianDao,
  EnumTaiYiSixteenGods.Wu_DaWei,
  EnumTaiYiSixteenGods.Si_DaShen,
  EnumTaiYiSixteenGods.Chen_TaiYang,
  EnumTaiYiSixteenGods.Mao_GaoCong
];

enum EnumTaiYiSixteenGods {
  Zi_DiZhu(1, EnumZhengJianType.Zheng, "地主", "子", EnumTaiYiGong.Kan),
  Qian_YangDe(2, EnumZhengJianType.Zheng, "阳德", "乾", EnumTaiYiGong.Qian),
  Gen_HeDe(3, EnumZhengJianType.Zheng, "和德", "艮", EnumTaiYiGong.Gen),
  Yin_LvShen(4, EnumZhengJianType.Jian, "吕申", "寅", EnumTaiYiGong.Gen),

  Mao_GaoCong(5, EnumZhengJianType.Zheng, "高丛", "卯", EnumTaiYiGong.Zhen),
  Chen_TaiYang(6, EnumZhengJianType.Jian, "太阳", "辰", EnumTaiYiGong.Zhen),
  Xun_DaJiong(7, EnumZhengJianType.Zheng, "大炅", "巽", EnumTaiYiGong.Xun),
  Si_DaShen(8, EnumZhengJianType.Jian, "大神", "巳", EnumTaiYiGong.Li),
  Wu_DaWei(9, EnumZhengJianType.Zheng, "大威", "午", EnumTaiYiGong.Li),
  Wei_TianDao(10, EnumZhengJianType.Jian, "天道", "未", EnumTaiYiGong.Kun),
  Kun_DaWu(11, EnumZhengJianType.Zheng, "大武", "坤", EnumTaiYiGong.Kun),
  Shen_WuDe(12, EnumZhengJianType.Jian, "武德", "申", EnumTaiYiGong.Dui),
  You_TaiCu(13, EnumZhengJianType.Zheng, "太簇", "酉", EnumTaiYiGong.Dui),
  Xu_YinZhu(14, EnumZhengJianType.Jian, "阴主", "戌", EnumTaiYiGong.Xun),
  Chou_TaiYin(15, EnumZhengJianType.Jian, "阴德", "丑", EnumTaiYiGong.Kan),
  Hai_DaYi(16, EnumZhengJianType.Jian, "大义", "亥", EnumTaiYiGong.Qian);

  const EnumTaiYiSixteenGods(
      this.seq, this.type, this.name, this.singleName, this.gong);
  final int seq;
  final EnumZhengJianType type;
  final String singleName;
  final String name;
  final EnumTaiYiGong gong;

  get isJian => type == EnumZhengJianType.Jian;
  get isZheng => type == EnumZhengJianType.Zheng;
}
