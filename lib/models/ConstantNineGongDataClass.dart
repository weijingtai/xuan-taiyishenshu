import 'package:metaphysics_core/models/ConstantNineGongDataClass.dart';
import 'package:tuple/tuple.dart';

class ConstantTaiYiNineGongDataClass extends ConstantNineGongDataClass {
  final String yinYangArea;
  final String eightSeason;
  final String skyDoor;
  ConstantTaiYiNineGongDataClass(this.yinYangArea, this.eightSeason,
      this.skyDoor, String name, String number, Tuple2<String, String?> diZhi,
      {String? tianMenDiHu})
      : super(name, number, diZhi, tianMenDiHu);
}
