import 'package:xuan_gua_core/xuan_gua_core.dart';

/// 《太乙统宗宝鉴》卷十三专属六十四卦序。
/// 索引 0..63, 对应卦序 1..64。
/// 第 42 位(序号43)为 Enum64Gua.tian_feng_gou(姤), 与周易通行序(夬)不同。
final List<Enum64Gua> kTaiYiGuaSequence = [
  // --- 运1 天地否泰之运 ---
  Enum64Gua.qian_wei_tian,     // 乾
  Enum64Gua.kun_wei_di,        // 坤
  Enum64Gua.shui_lei_tun,      // 屯
  Enum64Gua.shan_shui_meng,    // 蒙
  Enum64Gua.shui_tian_xu,      // 需
  Enum64Gua.tian_shui_song,    // 讼
  Enum64Gua.di_shui_shi,       // 师
  Enum64Gua.shui_di_bi,        // 比
  Enum64Gua.feng_tian_xiao_xu, // 小畜
  Enum64Gua.tian_ze_lv,        // 履
  Enum64Gua.di_tian_tai,       // 泰
  Enum64Gua.tian_di_pi,        // 否
  Enum64Gua.tian_huo_tong_ren, // 同人
  Enum64Gua.huo_tian_da_you,   // 大有
  Enum64Gua.di_shan_qian,      // 谦
  Enum64Gua.lei_di_yu,         // 豫
  Enum64Gua.ze_lei_sui,        // 随
  Enum64Gua.shan_feng_gu,      // 蛊
  Enum64Gua.di_ze_lin,         // 临
  Enum64Gua.feng_di_guan,      // 观
  Enum64Gua.huo_lei_shi_he,    // 噬嗑
  Enum64Gua.shan_huo_bi,       // 贲
  Enum64Gua.shan_di_bo,        // 剥
  Enum64Gua.di_lei_fu,         // 复
  Enum64Gua.tian_lei_wu_wang,  // 无妄
  Enum64Gua.shan_tian_da_xu,   // 大畜
  Enum64Gua.shan_lei_yi,       // 颐
  Enum64Gua.ze_feng_da_guo,    // 大过
  Enum64Gua.kan_wei_shui,      // 坎
  Enum64Gua.li_wei_huo,        // 离
  Enum64Gua.ze_shan_xian,      // 咸
  Enum64Gua.lei_feng_heng,     // 恒
  Enum64Gua.tian_shan_dun,     // 遁
  Enum64Gua.lei_tian_da_zhuang,// 大壮
  Enum64Gua.huo_di_jin,        // 晋
  Enum64Gua.di_huo_ming_yi,    // 明夷
  Enum64Gua.feng_huo_jia_ren,  // 家人
  Enum64Gua.huo_ze_kui,        // 睽
  Enum64Gua.shui_shan_jian,    // 蹇
  Enum64Gua.lei_shui_jie,      // 解
  Enum64Gua.shan_ze_sun,       // 损
  Enum64Gua.feng_lei_yi,       // 益
  Enum64Gua.tian_feng_gou,     // 姤
  Enum64Gua.ze_tian_guai,      // 夬
  Enum64Gua.ze_di_cui,         // 萃
  Enum64Gua.di_feng_sheng,     // 升
  Enum64Gua.ze_shui_kun,       // 困
  Enum64Gua.shui_feng_jing,    // 井
  Enum64Gua.ze_huo_ge,         // 革
  Enum64Gua.huo_feng_ding,     // 鼎
  Enum64Gua.zhen_wei_lei,      // 震
  Enum64Gua.gen_wei_shan,      // 艮
  Enum64Gua.feng_shan_jian,    // 渐
  Enum64Gua.lei_ze_gui_mei,    // 归妹
  Enum64Gua.lei_huo_feng,      // 丰
  Enum64Gua.huo_shan_lv,       // 旅
  Enum64Gua.xun_wei_feng,      // 巽
  Enum64Gua.dui_wei_ze,        // 兑
  Enum64Gua.feng_shui_huan,    // 涣
  Enum64Gua.shui_ze_jie,       // 节
  Enum64Gua.feng_ze_zhong_fu,  // 中孚
  Enum64Gua.lei_shan_xiao_gu,  // 小过
  Enum64Gua.shui_huo_ji_ji,    // 既济
  Enum64Gua.huo_shui_wei_ji,   // 未济
];

/// 根据六爻编码反查卦名。找不到返回 null。
String? findGuaNameByYao(List<bool> yao) {
  if (yao.length != 6) return null;
  final binaryStr = yao.map((b) => b ? '1' : '0').join();
  try {
    return Enum64Gua.fromBinaryStr(binaryStr).name;
  } catch (_) {
    return null;
  }
}

/// 返回 [guaName] 六爻中阳爻的数量。
int yangYaoCount(String guaName) {
  try {
    return Enum64Gua.fromName(guaName).yangYaoCount;
  } catch (_) {
    throw ArgumentError('Unknown gua: $guaName');
  }
}

/// 返回 [guaName] 的策数：阳爻×36 + 阴爻×24。
int ceCount(String guaName) {
  try {
    return Enum64Gua.fromName(guaName).ceCount;
  } catch (_) {
    throw ArgumentError('Unknown gua: $guaName');
  }
}

/// Enum64Gua 扩展：六爻编码工具。
extension Enum64GuaYaoX on Enum64Gua {
  /// 六爻 bool 编码 [初爻..上爻]，true=阳, false=阴。
  List<bool> get yaoBoolList =>
      bottomTopBinaryStr.split('').map((c) => c == '1').toList();

  /// 阳爻数量。
  int get yangYaoCount =>
      bottomTopBinaryStr.split('').where((c) => c == '1').length;

  /// 策数：阳爻×36 + 阴爻×24。
  int get ceCount {
    final yang = yangYaoCount;
    return yang * 36 + (6 - yang) * 24;
  }

  /// 标准卦名（现在 Enum64Gua.name 已是标准卦名，直接返回）。
  String get standardName => name;
}
