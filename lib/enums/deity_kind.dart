/// 太乙排盘中所有内置星神/神煞的类型枚举。
///
/// 按排盘层级分类：
/// - 地盘神：[zhengShen]/[jianShen]（十六神在地盘的固定映射）
/// - 人盘神：[tianMu]/[shiJi]（天目/始击，从人盘流转推算）
/// - 天盘神：[taiYi]/[jiShen]/[hostGeneral]/[guestGeneral]/
///   [hostDeputyGeneral]/[guestDeputyGeneral]/[junJi]/[chenJi]/[minJi]/
///   [wuFu]/[daYou]/[xiaoYou]/[feiFu]
/// - 神盘神：[taiSui]/[suiPo]/[zhiFu]/[qingLong]/[zhuQue]/[baiHu]/[xuanWu]
enum EnumDeityKind {
  zhengShen('正神'),
  jianShen('间神'),
  taiYi('太乙'),
  tianMu('天目'),
  shiJi('始击'),
  jiShen('计神'),
  hostGeneral('主大将'),
  guestGeneral('客大将'),
  hostDeputyGeneral('主参将'),
  guestDeputyGeneral('客参将'),
  dingGeneral('定大将'),
  dingDeputyGeneral('定参将'),
  junJi('君基'),
  chenJi('臣基'),
  minJi('民基'),
  wuFu('五福'),
  daYou('大游'),
  xiaoYou('小游'),
  feiFu('飞符'),
  taiSui('太岁'),
  suiPo('岁破'),
  zhiFu('直符'),
  qingLong('青龙'),
  zhuQue('朱雀'),
  baiHu('白虎'),
  xuanWu('玄武'),
  heShen('河神'),
  fengBo('风伯'),
  yuShi('雨师'),
  feiLu('飞禄'),
  feiMa('飞马'),
  heiFu('黑符');

  const EnumDeityKind(this.label);
  final String label;
}

/// 星神所属盘面层级。
enum EnumDeityLayer {
  diPan('地盘'),
  renPan('人盘'),
  tianPan('天盘'),
  shenPan('神盘'),
  mingPan('命盘');

  const EnumDeityLayer(this.label);
  final String label;
}
