// ignore_for_file: constant_identifier_names

/// 开休生伤杜景死惊八门。
///
/// 注意：这不是 [EnumTaiYiDoor] 中的太乙门。太乙门为天、火、鬼、
/// 日、月、人、水、风、枢纽；两者在排盘模型中分开保存。
enum EnumEightDoor {
  Kai('开门', '开'),
  Xiu('休门', '休'),
  Sheng('生门', '生'),
  Shang('伤门', '伤'),
  Du('杜门', '杜'),
  Jing('景门', '景'),
  Si('死门', '死'),
  JingMen('惊门', '惊');

  const EnumEightDoor(this.name, this.singleName);

  /// 八门全名。
  final String name;

  /// 八门单字名。
  final String singleName;
}

/// 八门枚举的稳定 ID 与解析能力。
extension EnumEightDoorId on EnumEightDoor {
  String get id => name;

  static EnumEightDoor fromId(String id) {
    final value = tryFromId(id);
    if (value == null) {
      throw ArgumentError.value(id, 'id', '未知的八门 ID');
    }
    return value;
  }

  static EnumEightDoor? tryFromId(String id) {
    for (final item in EnumEightDoor.values) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }
}
