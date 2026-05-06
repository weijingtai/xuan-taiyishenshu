/// 命盘十二宫枚举（太乙命法）。
enum EnumMingGong {
  ming('命宫'),
  cai('财帛'),
  guan('官禄'),
  fu('福德'),
  tian('田宅'),
  fuMu('父母'),
  ji('疾厄'),
  qian('迁移'),
  you('交友'),
  hun('婚姻'),
  zi('子女'),
  nu('奴仆');

  const EnumMingGong(this.label);
  final String label;
}

/// 四神（青龙/朱雀/白虎/玄武）枚举。
enum EnumSiShen {
  qingLong('青龙', '春'),
  zhuQue('朱雀', '夏'),
  baiHu('白虎', '秋'),
  xuanWu('玄武', '冬');

  const EnumSiShen(this.label, this.season);
  final String label;
  final String season;
}
