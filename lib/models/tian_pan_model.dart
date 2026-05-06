import '../enums/deity_kind.dart';
import '../enums/gong.dart';
import '../enums/taiyi_enum_extensions.dart';

/// 天盘数据模型。
///
/// 天盘承载太乙帝星、主客大将参将、三基五福、大游小游等核心星神。
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
    this.methodNote,
  });

  /// 太乙帝星所在宫。
  final EnumTaiYiGong taiYiGong;

  /// 主大将所在宫。
  final EnumTaiYiGong hostGeneralGong;

  /// 客大将所在宫。
  final EnumTaiYiGong guestGeneralGong;

  /// 主参将所在宫。
  final EnumTaiYiGong hostDeputyGeneralGong;

  /// 客参将所在宫。
  final EnumTaiYiGong guestDeputyGeneralGong;

  /// 定大将所在宫（金镜/统宗排，集成可省略）。
  final EnumTaiYiGong? dingGeneralGong;

  /// 定参将所在宫。
  final EnumTaiYiGong? dingDeputyGeneralGong;

  /// 君基所在宫（金镜/统宗排，集成可省略）。
  final EnumTaiYiGong? junJiGong;

  /// 臣基所在宫。
  final EnumTaiYiGong? chenJiGong;

  /// 民基所在宫。
  final EnumTaiYiGong? minJiGong;

  /// 五福所在宫。
  final EnumTaiYiGong? wuFuGong;

  /// 大游所在宫。
  final EnumTaiYiGong? daYouGong;

  /// 小游所在宫。
  final EnumTaiYiGong? xiaoYouGong;

  /// 飞符所在宫。
  final EnumTaiYiGong? feifFuGong;

  /// 计算方法说明（记录流派差异）。
  final String? methodNote;

  /// 将天盘所有已落宫星神转为 DeityPlacement 列表，供 UI 渲染。
  List<DeityPlacement> toPlacements() {
    final placements = <DeityPlacement>[
      DeityPlacement(
        kind: EnumDeityKind.taiYi,
        gong: taiYiGong,
      ),
      DeityPlacement(
        kind: EnumDeityKind.hostGeneral,
        gong: hostGeneralGong,
      ),
      DeityPlacement(
        kind: EnumDeityKind.guestGeneral,
        gong: guestGeneralGong,
      ),
      DeityPlacement(
        kind: EnumDeityKind.hostDeputyGeneral,
        gong: hostDeputyGeneralGong,
      ),
      DeityPlacement(
        kind: EnumDeityKind.guestDeputyGeneral,
        gong: guestDeputyGeneralGong,
      ),
      if (dingGeneralGong != null)
        DeityPlacement(
          kind: EnumDeityKind.dingGeneral,
          gong: dingGeneralGong!,
        ),
      if (dingDeputyGeneralGong != null)
        DeityPlacement(
          kind: EnumDeityKind.dingDeputyGeneral,
          gong: dingDeputyGeneralGong!,
        ),
      if (junJiGong != null)
        DeityPlacement(
          kind: EnumDeityKind.junJi,
          gong: junJiGong!,
        ),
      if (chenJiGong != null)
        DeityPlacement(
          kind: EnumDeityKind.chenJi,
          gong: chenJiGong!,
        ),
      if (minJiGong != null)
        DeityPlacement(
          kind: EnumDeityKind.minJi,
          gong: minJiGong!,
        ),
      if (wuFuGong != null)
        DeityPlacement(
          kind: EnumDeityKind.wuFu,
          gong: wuFuGong!,
        ),
      if (daYouGong != null)
        DeityPlacement(
          kind: EnumDeityKind.daYou,
          gong: daYouGong!,
        ),
      if (xiaoYouGong != null)
        DeityPlacement(
          kind: EnumDeityKind.xiaoYou,
          gong: xiaoYouGong!,
        ),
      if (feifFuGong != null)
        DeityPlacement(
          kind: EnumDeityKind.feiFu,
          gong: feifFuGong!,
        ),
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
    'methodNote': methodNote,
  };
}

/// 星神落宫记录，用于统一表达任一星神的宫位映射。
class DeityPlacement {
  const DeityPlacement({
    required this.kind,
    required this.gong,
    this.reason,
    this.metadata = const {},
  });

  /// 星神类型。
  final EnumDeityKind kind;

  /// 所落太乙宫。
  final EnumTaiYiGong gong;

  /// 落宫原因或计算说明。
  final String? reason;

  /// 扩展元数据。
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'gongId': gong.id,
    'reason': reason,
    'metadata': metadata,
  };
}
