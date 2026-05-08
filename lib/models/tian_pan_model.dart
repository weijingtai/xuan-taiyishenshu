import '../enums/deity_kind.dart';
import '../enums/gong.dart';
import '../enums/taiyi_enum_extensions.dart';

class TianPanModel {
  const TianPanModel({
    required this.taiYiGong,
    required this.hostGeneralGong,
    required this.guestGeneralGong,
    required this.hostDeputyGeneralGong,
    required this.guestDeputyGeneralGong,
    this.dingGeneralGong,
    this.dingDeputyGeneralGong,
    this.junJiGong,
    this.chenJiGong,
    this.minJiGong,
    this.wuFuGong,
    this.daYouGong,
    this.xiaoYouGong,
    this.feifFuGong,
    this.siShenGong,
    this.tianYiGong2,
    this.diYiGong,
    this.zhiFuGong2,
  this.junJiRuGongNianShu,
  this.chenJiRuGongNianShu,
  this.siShenRuGongNianShu,
  this.tianYiRuGongNianShu,
  this.diYiRuGongNianShu,
  this.zhiFuRuGongNianShu,
  this.methodNote,
  });

  final EnumTaiYiGong taiYiGong;
  final EnumTaiYiGong hostGeneralGong;
  final EnumTaiYiGong guestGeneralGong;
  final EnumTaiYiGong hostDeputyGeneralGong;
  final EnumTaiYiGong guestDeputyGeneralGong;
  final EnumTaiYiGong? dingGeneralGong;
  final EnumTaiYiGong? dingDeputyGeneralGong;
  final EnumTaiYiGong? junJiGong;
  final EnumTaiYiGong? chenJiGong;
  final EnumTaiYiGong? minJiGong;
  final EnumTaiYiGong? wuFuGong;
  final EnumTaiYiGong? daYouGong;
  final EnumTaiYiGong? xiaoYouGong;
  final EnumTaiYiGong? feifFuGong;

  final EnumTaiYiGong? siShenGong;
  final EnumTaiYiGong? tianYiGong2;
  final EnumTaiYiGong? diYiGong;
  final EnumTaiYiGong? zhiFuGong2;

  final int? junJiRuGongNianShu;
  final int? chenJiRuGongNianShu;
  final int? siShenRuGongNianShu;
  final int? tianYiRuGongNianShu;
  final int? diYiRuGongNianShu;
  final int? zhiFuRuGongNianShu;

  final String? methodNote;

  List<DeityPlacement> toPlacements() {
    final placements = <DeityPlacement>[
      DeityPlacement(kind: EnumDeityKind.taiYi, gong: taiYiGong),
      DeityPlacement(kind: EnumDeityKind.hostGeneral, gong: hostGeneralGong),
      DeityPlacement(kind: EnumDeityKind.guestGeneral, gong: guestGeneralGong),
      DeityPlacement(kind: EnumDeityKind.hostDeputyGeneral, gong: hostDeputyGeneralGong),
      DeityPlacement(kind: EnumDeityKind.guestDeputyGeneral, gong: guestDeputyGeneralGong),
      if (dingGeneralGong != null)
        DeityPlacement(kind: EnumDeityKind.dingGeneral, gong: dingGeneralGong!),
      if (dingDeputyGeneralGong != null)
        DeityPlacement(kind: EnumDeityKind.dingDeputyGeneral, gong: dingDeputyGeneralGong!),
      if (junJiGong != null)
        DeityPlacement(kind: EnumDeityKind.junJi, gong: junJiGong!),
      if (chenJiGong != null)
        DeityPlacement(kind: EnumDeityKind.chenJi, gong: chenJiGong!),
      if (minJiGong != null)
        DeityPlacement(kind: EnumDeityKind.minJi, gong: minJiGong!),
      if (wuFuGong != null)
        DeityPlacement(kind: EnumDeityKind.wuFu, gong: wuFuGong!),
      if (daYouGong != null)
        DeityPlacement(kind: EnumDeityKind.daYou, gong: daYouGong!),
      if (xiaoYouGong != null)
        DeityPlacement(kind: EnumDeityKind.xiaoYou, gong: xiaoYouGong!),
      if (feifFuGong != null)
        DeityPlacement(kind: EnumDeityKind.feiFu, gong: feifFuGong!),
      if (siShenGong != null)
        DeityPlacement(kind: EnumDeityKind.siShen, gong: siShenGong!),
      if (tianYiGong2 != null)
        DeityPlacement(kind: EnumDeityKind.tianYi, gong: tianYiGong2!),
      if (diYiGong != null)
        DeityPlacement(kind: EnumDeityKind.diYi, gong: diYiGong!),
      if (zhiFuGong2 != null)
        DeityPlacement(kind: EnumDeityKind.zhiFu, gong: zhiFuGong2!),
    ];
    return placements;
  }

  Map<String, Object?> toJson() => {
    'taiYiGong': taiYiGong.id,
    'hostGeneralGong': hostGeneralGong.id,
    'guestGeneralGong': guestGeneralGong.id,
    'hostDeputyGeneralGong': hostDeputyGeneralGong.id,
    'guestDeputyGeneralGong': guestDeputyGeneralGong.id,
    'dingGeneralGong': dingGeneralGong?.id,
    'dingDeputyGeneralGong': dingDeputyGeneralGong?.id,
    'junJiGong': junJiGong?.id,
    'chenJiGong': chenJiGong?.id,
    'minJiGong': minJiGong?.id,
    'wuFuGong': wuFuGong?.id,
    'daYouGong': daYouGong?.id,
    'xiaoYouGong': xiaoYouGong?.id,
    'feifFuGong': feifFuGong?.id,
    'siShenGong': siShenGong?.id,
    'tianYiGong2': tianYiGong2?.id,
    'diYiGong': diYiGong?.id,
    'zhiFuGong2': zhiFuGong2?.id,
    'junJiRuGongNianShu': junJiRuGongNianShu,
  'chenJiRuGongNianShu': chenJiRuGongNianShu,
  'siShenRuGongNianShu': siShenRuGongNianShu,
    'tianYiRuGongNianShu': tianYiRuGongNianShu,
    'diYiRuGongNianShu': diYiRuGongNianShu,
    'zhiFuRuGongNianShu': zhiFuRuGongNianShu,
    'methodNote': methodNote,
  };
}

class DeityPlacement {
  const DeityPlacement({
    required this.kind,
    required this.gong,
    this.reason,
    this.metadata = const {},
  });

  final EnumDeityKind kind;
  final EnumTaiYiGong gong;
  final String? reason;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'gongId': gong.id,
    'reason': reason,
    'metadata': metadata,
  };
}
