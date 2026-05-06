import '../enums/eight_door.dart';
import '../enums/gong.dart';
import '../models/di_pan_model.dart';
import 'pan_data_model.dart';

/// 太乙行宫顺序：顺时针逐一宫循环（1乾→2离→3艮→4震→5巽→6兑→7坤→8坎→回1乾）。
///
/// 三派一致，用于主算/客算/定算的逐宫累加计算。
const List<EnumTaiYiGong> taiYiPalaceOrder = [
  EnumTaiYiGong.Qian,   // 1 乾
  EnumTaiYiGong.Li,     // 2 离
  EnumTaiYiGong.Gen,    // 3 艮
  EnumTaiYiGong.Zhen,   // 4 震
  EnumTaiYiGong.Xun,    // 5 巽
  EnumTaiYiGong.Dui,    // 6 兑
  EnumTaiYiGong.Kun,    // 7 坤
  EnumTaiYiGong.Kan,    // 8 坎
];

/// 开休生伤杜景死惊八门顺序。
const List<EnumEightDoor> eightDoorOrder = [
  EnumEightDoor.Kai,
  EnumEightDoor.Xiu,
  EnumEightDoor.Sheng,
  EnumEightDoor.Shang,
  EnumEightDoor.Du,
  EnumEightDoor.Jing,
  EnumEightDoor.Si,
  EnumEightDoor.JingMen,
];

/// 十二地支顺序。
const List<String> twelveBranches = [
  '子',
  '丑',
  '寅',
  '卯',
  '辰',
  '巳',
  '午',
  '未',
  '申',
  '酉',
  '戌',
  '亥',
];

/// 十六神顺序，包含乾、坤、艮、巽四间神。
const List<String> sixteenDeities = [
  '子',
  '丑',
  '艮',
  '寅',
  '卯',
  '辰',
  '巽',
  '巳',
  '午',
  '未',
  '坤',
  '申',
  '酉',
  '戌',
  '乾',
  '亥',
];

/// 十二神简化顺序，用于集成派等简化体系。
const List<String> twelveDeities = [
  '子',
  '丑',
  '寅',
  '卯',
  '辰',
  '巳',
  '午',
  '未',
  '申',
  '酉',
  '戌',
  '亥',
];

/// 地支到所在太乙宫的映射。
const Map<String, EnumTaiYiGong> branchPalace = {
  '子': EnumTaiYiGong.Kan,
  '丑': EnumTaiYiGong.Gen,
  '寅': EnumTaiYiGong.Gen,
  '卯': EnumTaiYiGong.Zhen,
  '辰': EnumTaiYiGong.Xun,
  '巳': EnumTaiYiGong.Xun,
  '午': EnumTaiYiGong.Li,
  '未': EnumTaiYiGong.Kun,
  '申': EnumTaiYiGong.Kun,
  '酉': EnumTaiYiGong.Dui,
  '戌': EnumTaiYiGong.Qian,
  '亥': EnumTaiYiGong.Qian,
};

/// 创建一组空九宫数据，供起盘结果逐步填充计算项。
List<PalaceDataModel> createEmptyPalaces() {
  return List.unmodifiable(
    EnumTaiYiGong.values.map((gong) {
      return PalaceDataModel(
        gong: gong,
        items: const [],
      );
    }),
  );
}

/// 地盘固定数据：每宫对应的正神与间神名。
///
/// 中宫无星神。三派一致、永不动。
const Map<EnumTaiYiGong, ({String zhengShen, String jianShen})>
    diPanGodsByPalace = {
  EnumTaiYiGong.Qian: (zhengShen: '阳德', jianShen: '大义'),
  EnumTaiYiGong.Li: (zhengShen: '大威', jianShen: '大神'),
  EnumTaiYiGong.Gen: (zhengShen: '和德', jianShen: '吕申'),
  EnumTaiYiGong.Zhen: (zhengShen: '高丛', jianShen: '太阳'),
  EnumTaiYiGong.Dui: (zhengShen: '太簇', jianShen: '武德'),
  EnumTaiYiGong.Kun: (zhengShen: '大武', jianShen: '天道'),
  EnumTaiYiGong.Kan: (zhengShen: '地主', jianShen: '阴德'),
  EnumTaiYiGong.Xun: (zhengShen: '大炅', jianShen: '阴主'),
};

/// 创建地盘固定数据。
DiPanModel createDiPan() {
  final palaces = EnumTaiYiGong.values.map((gong) {
    final gods = diPanGodsByPalace[gong];
    return DiPanPalaceModel(
      gong: gong,
      zhengShen: gods?.zhengShen,
      jianShen: gods?.jianShen,
    );
  }).toList(growable: false);
  return DiPanModel(palaces: List.unmodifiable(palaces));
}

/// 十二地支对冲表（子↔午、丑↔未、寅↔申、卯↔酉、辰↔戌、巳↔亥）。
const Map<String, String> branchClash = {
  '子': '午', '午': '子',
  '丑': '未', '未': '丑',
  '寅': '申', '申': '寅',
  '卯': '酉', '酉': '卯',
  '辰': '戌', '戌': '辰',
  '巳': '亥', '亥': '巳',
};

/// 太乙宫对冲表（乾↔巽、离↔坎、艮↔坤、震↔兑）。
const Map<EnumTaiYiGong, EnumTaiYiGong> gongClash = {
  EnumTaiYiGong.Qian: EnumTaiYiGong.Xun,
  EnumTaiYiGong.Xun: EnumTaiYiGong.Qian,
  EnumTaiYiGong.Li: EnumTaiYiGong.Kan,
  EnumTaiYiGong.Kan: EnumTaiYiGong.Li,
  EnumTaiYiGong.Gen: EnumTaiYiGong.Kun,
  EnumTaiYiGong.Kun: EnumTaiYiGong.Gen,
  EnumTaiYiGong.Zhen: EnumTaiYiGong.Dui,
  EnumTaiYiGong.Dui: EnumTaiYiGong.Zhen,
};

/// 四神固定落宫（三派一致）。
///
/// 青龙→艮（春）、朱雀→离（夏）、白虎→兑（秋）、玄武→坎（冬）。
const Map<String, EnumTaiYiGong> siShenFixedPalace = {
  '青龙': EnumTaiYiGong.Gen,
  '朱雀': EnumTaiYiGong.Li,
  '白虎': EnumTaiYiGong.Dui,
  '玄武': EnumTaiYiGong.Kan,
};
