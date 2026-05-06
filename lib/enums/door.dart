enum EnumTaiYiDoor {
  Tian("天门", "天"),
  Huo("火门", "火"),
  Gui("鬼门", "鬼"),
  Ri("日门", "日"),
  Yue("月门", "月"),
  Ren("人门", "人"),
  Shui("水门", "水"),
  Feng("风门", "风"),
  Center("枢纽", "枢");

  const EnumTaiYiDoor(this.name, this.singleName);
  final String name;
  final String singleName;
}
