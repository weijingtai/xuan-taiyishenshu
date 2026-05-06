import 'door.dart';
import 'god.dart';
import 'gong.dart';

/// 太乙宫枚举的稳定 ID 与解析能力。
extension TaiYiGongId on EnumTaiYiGong {
  String get id => name;

  static EnumTaiYiGong fromId(String id) {
    final value = tryFromId(id);
    if (value == null) {
      throw ArgumentError.value(id, 'id', '未知的太乙宫 ID');
    }
    return value;
  }

  static EnumTaiYiGong? tryFromId(String id) {
    for (final item in EnumTaiYiGong.values) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }
}

/// 太乙门枚举的稳定 ID 与解析能力。
extension TaiYiDoorId on EnumTaiYiDoor {
  String get id => name;

  static EnumTaiYiDoor fromId(String id) {
    final value = tryFromId(id);
    if (value == null) {
      throw ArgumentError.value(id, 'id', '未知的太乙门 ID');
    }
    return value;
  }

  static EnumTaiYiDoor? tryFromId(String id) {
    for (final item in EnumTaiYiDoor.values) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }
}

/// 太乙十六神枚举的稳定 ID 与解析能力。
extension TaiYiSixteenGodId on EnumTaiYiSixteenGods {
  String get id => name;

  static EnumTaiYiSixteenGods fromId(String id) {
    final value = tryFromId(id);
    if (value == null) {
      throw ArgumentError.value(id, 'id', '未知的太乙十六神 ID');
    }
    return value;
  }

  static EnumTaiYiSixteenGods? tryFromId(String id) {
    for (final item in EnumTaiYiSixteenGods.values) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }
}
