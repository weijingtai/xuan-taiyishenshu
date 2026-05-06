/// 太乙格局类型枚举。
///
/// 格局定义三派一致，差异仅在金镜派是否细拆小格局。
enum EnumGeJu {
  yan('掩'),
  qiu('囚'),
  ji('击'),
  po('迫'),
  ge('格'),
  dui('对'),
  guan('关'),
  fei('废'),
  guai('乖'),
  ti('提'),
  xie('挟'),
  tui('推'),
  siGuoGu('四郭固'),
  sanMenJu('三门具'),
  chang('长'),
  duan('短'),
  he('和'),
  buHe('不和'),
  dingSuan('定算'),
  dingJi('定计');

  const EnumGeJu(this.label);
  final String label;
}
