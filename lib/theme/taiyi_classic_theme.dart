import 'package:flutter/material.dart';

class TaiYiClassicTheme {
  static const Color inkBlack = Color(0xFF1A1A1A);
  static const Color cinnabar = Color(0xFFC23B22);
  static const Color goldLeaf = Color(0xFFD4A017);
  static const Color paleGold = Color(0xFFF5E6C8);
  static const Color inkWash = Color(0xFF4A4A4A);
  static const Color ricePaper = Color(0xFFFDF8EF);
  static const Color darkWood = Color(0xFF3E2723);
  static const Color mediumWood = Color(0xFF5D4037);
  static const Color lightWood = Color(0xFF8D6E63);
  static const Color jadeGreen = Color(0xFF2E7D32);
  static const Color waterBlue = Color(0xFF1565C0);
  static const Color earthYellow = Color(0xFFBF8C3E);

  static const gongBorderFar = BorderSide(color: inkBlack, width: 2);
  static const gongBorderNear = BorderSide(color: inkWash, width: 1);
  static const gongBorderNormal = BorderSide(color: lightWood, width: 1);

  /// 阳宫白色，阴宫浅灰，符合太乙阴阳数「阳白阴灰」规范。
  static const Color yangGongBg = Color(0xFFFFFFFF);       // 阳宫：白色
  static const Color yinGongBg  = Color(0xFFEEEEEE);       // 阴宫：浅灰

  static BoxDecoration gongDecoration({required bool isYangYin, required bool isNear}) {
    return BoxDecoration(
      color: isYangYin ? yangGongBg : yinGongBg,
      border: isNear
          ? Border.all(color: inkWash, width: 1)
          : Border.all(color: inkBlack, width: 2),
    );
  }

  static BoxDecoration centerDecoration() {
    return BoxDecoration(
      color: paleGold.withOpacity(0.5),
      border: Border.all(color: goldLeaf, width: 2),
    );
  }

  static const Map<String, Color> eightGuaColor = {
    '乾': Color(0xFFC23B22),
    '坤': Color(0xFF8D6E63),
    '震': Color(0xFF2E7D32),
    '巽': Color(0xFF558B2F),
    '坎': Color(0xFF1565C0),
    '离': Color(0xFFC62828),
    '艮': Color(0xFFBF8C3E),
    '兑': Color(0xFFF57F17),
  };

  static const Map<String, Color> zodiacColors = {
    '亥': Color(0xFF3D59AB),
    '丑': Color(0xFFD2B48C),
    '寅': Color(0xFF59C3C2),
    '卯': Color(0xFF789262),
    '辰': Color(0xFFE1A95F),
    '巳': Color(0xFFFF4500),
    '午': Color(0xFFCD5C5C),
    '未': Color(0xFFF4A460),
    '申': Color(0xFFE49E00),
    '酉': Color(0xFFED9121),
    '戌': Color(0xFFA0522D),
    '子': Color(0xFF4B0082),
  };

  static const Map<String, String> eightGuaSymbol = {
    '乾': '☰',
    '兑': '☱',
    '离': '☲',
    '震': '☳',
    '巽': '☴',
    '坎': '☵',
    '艮': '☶',
    '坤': '☷',
  };

  static const Map<String, Color> deityLayerColor = {
    '天盘': Color(0xFFC62828),
    '人盘': Color(0xFF1565C0),
    '神盘': Color(0xFF6A1B9A),
    '地盘': Color(0xFF2E7D32),
  };

  static const chineseNumbers = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];

  static String toChineseNumber(int n) {
    if (n >= 1 && n <= 9) return chineseNumbers[n];
    return n.toString();
  }
}
