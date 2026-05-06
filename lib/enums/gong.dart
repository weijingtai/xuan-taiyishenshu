import 'package:common/enums.dart';
import 'door.dart';

enum EnumTaiYiGong {
  Qian(1, Enum8Gua.Qian, "西北", "绝阳", EnumTaiYiDoor.Tian, "冀州", YinYang.YANG),
  Li(2, Enum8Gua.Li, "正南", "易气", EnumTaiYiDoor.Huo, "荆州", YinYang.YIN),
  Gen(3, Enum8Gua.Gen, "东北", "和", EnumTaiYiDoor.Gui, "青州", YinYang.YANG),
  Zhen(4, Enum8Gua.Zhen, "正东", "绝气", EnumTaiYiDoor.Ri, "徐州", YinYang.YANG),
  Dui(5, Enum8Gua.Dui, "正西", "绝气", EnumTaiYiDoor.Yue, "雍州", YinYang.YIN),
  Kun(6, Enum8Gua.Kun, "西南", "和", EnumTaiYiDoor.Ren, "益州", YinYang.YIN),
  Kan(7, Enum8Gua.Kan, "正北", "易气", EnumTaiYiDoor.Shui, "兖州", YinYang.YANG),
  Xun(8, Enum8Gua.Xun, "东南", "绝阴", EnumTaiYiDoor.Feng, "扬州", YinYang.YIN),
  Center(9, Enum8Gua.Kun, "中央", "枢纽", EnumTaiYiDoor.Center, "朝歌", YinYang.YIN);

  const EnumTaiYiGong(this.order, this.gua, this.direction, this.status,
      this.door, this.fenYe, this.yinYang);

  final Enum8Gua gua;
  final int order;
  final String direction;
  final String status;
  final EnumTaiYiDoor door; // 太乙门
  final String fenYe; // 分野
  final YinYang yinYang;
}
