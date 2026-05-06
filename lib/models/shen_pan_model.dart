import '../enums/deity_kind.dart';
import '../enums/gong.dart';
import '../enums/taiyi_enum_extensions.dart';
import 'tian_pan_model.dart';

/// 神盘数据模型。
///
/// 神盘承载太岁、岁破、直符、四神（青龙/朱雀/白虎/玄武）等
/// 年神/时神。金镜派额外排河神、风伯、雨师。
class ShenPanModel {
  const ShenPanModel({
    required this.taiSuiGong,
    required this.suiPoGong,
    required this.zhiFuGong,
    this.qingLongGong,
    this.zhuQueGong,
    this.baiHuGong,
    this.xuanWuGong,
    this.heShenGong,
    this.fengBoGong,
    this.yuShiGong,
    this.methodNote,
  });

  /// 太岁所在宫（当年地支宫）。
  final EnumTaiYiGong taiSuiGong;

  /// 岁破所在宫（太岁对冲宫）。
  final EnumTaiYiGong suiPoGong;

  /// 直符所在宫（太乙所在宫，三派同）。
  final EnumTaiYiGong zhiFuGong;

  /// 青龙所在宫。
  final EnumTaiYiGong? qingLongGong;

  /// 朱雀所在宫。
  final EnumTaiYiGong? zhuQueGong;

  /// 白虎所在宫。
  final EnumTaiYiGong? baiHuGong;

  /// 玄武所在宫。
  final EnumTaiYiGong? xuanWuGong;

  /// 河神所在宫（金镜派排）。
  final EnumTaiYiGong? heShenGong;

  /// 风伯所在宫（金镜派排）。
  final EnumTaiYiGong? fengBoGong;

  /// 雨师所在宫（金镜派排）。
  final EnumTaiYiGong? yuShiGong;

  /// 计算方法说明。
  final String? methodNote;

  /// 将神盘所有已落宫星神转为 DeityPlacement 列表。
  List<DeityPlacement> toPlacements() {
    final placements = <DeityPlacement>[
      DeityPlacement(kind: EnumDeityKind.taiSui, gong: taiSuiGong),
      DeityPlacement(kind: EnumDeityKind.suiPo, gong: suiPoGong),
      DeityPlacement(kind: EnumDeityKind.zhiFu, gong: zhiFuGong),
      if (qingLongGong != null)
        DeityPlacement(kind: EnumDeityKind.qingLong, gong: qingLongGong!),
      if (zhuQueGong != null)
        DeityPlacement(kind: EnumDeityKind.zhuQue, gong: zhuQueGong!),
      if (baiHuGong != null)
        DeityPlacement(kind: EnumDeityKind.baiHu, gong: baiHuGong!),
      if (xuanWuGong != null)
        DeityPlacement(kind: EnumDeityKind.xuanWu, gong: xuanWuGong!),
      if (heShenGong != null)
        DeityPlacement(kind: EnumDeityKind.heShen, gong: heShenGong!),
      if (fengBoGong != null)
        DeityPlacement(kind: EnumDeityKind.fengBo, gong: fengBoGong!),
      if (yuShiGong != null)
        DeityPlacement(kind: EnumDeityKind.yuShi, gong: yuShiGong!),
    ];
    return placements;
  }

  Map<String, Object?> toJson() => {
    'taiSuiGong': taiSuiGong.id,
    'suiPoGong': suiPoGong.id,
    'zhiFuGong': zhiFuGong.id,
    'qingLongGong': qingLongGong?.id,
    'zhuQueGong': zhuQueGong?.id,
    'baiHuGong': baiHuGong?.id,
    'xuanWuGong': xuanWuGong?.id,
    'heShenGong': heShenGong?.id,
    'fengBoGong': fengBoGong?.id,
    'yuShiGong': yuShiGong?.id,
    'methodNote': methodNote,
  };
}
