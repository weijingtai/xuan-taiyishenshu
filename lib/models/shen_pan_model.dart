import '../enums/deity_kind.dart';
import '../enums/gong.dart';
import '../enums/taiyi_enum_extensions.dart';
import 'tian_pan_model.dart';

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
    this.qingLongQiGong,
    this.heiQiGong,
    this.chiQiGong,
    this.guiShenZhiShiGong,
    this.heiQiRuGongNianShu,
    this.methodNote,
  });

  final EnumTaiYiGong taiSuiGong;
  final EnumTaiYiGong suiPoGong;
  final EnumTaiYiGong zhiFuGong;

  final EnumTaiYiGong? qingLongGong;
  final EnumTaiYiGong? zhuQueGong;
  final EnumTaiYiGong? baiHuGong;
  final EnumTaiYiGong? xuanWuGong;
  final EnumTaiYiGong? heShenGong;
  final EnumTaiYiGong? fengBoGong;
  final EnumTaiYiGong? yuShiGong;

  final EnumTaiYiGong? qingLongQiGong;
  final EnumTaiYiGong? heiQiGong;
  final EnumTaiYiGong? chiQiGong;
  final EnumTaiYiGong? guiShenZhiShiGong;

  final int? heiQiRuGongNianShu;

  final String? methodNote;

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
      if (qingLongQiGong != null)
        DeityPlacement(kind: EnumDeityKind.qingLongQi, gong: qingLongQiGong!),
      if (heiQiGong != null)
        DeityPlacement(kind: EnumDeityKind.heiQi, gong: heiQiGong!),
      if (chiQiGong != null)
        DeityPlacement(kind: EnumDeityKind.chiQi, gong: chiQiGong!),
      if (guiShenZhiShiGong != null)
        DeityPlacement(kind: EnumDeityKind.guiShenZhiShi, gong: guiShenZhiShiGong!),
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
    'qingLongQiGong': qingLongQiGong?.id,
    'heiQiGong': heiQiGong?.id,
    'chiQiGong': chiQiGong?.id,
    'guiShenZhiShiGong': guiShenZhiShiGong?.id,
    'heiQiRuGongNianShu': heiQiRuGongNianShu,
    'methodNote': methodNote,
  };
}
