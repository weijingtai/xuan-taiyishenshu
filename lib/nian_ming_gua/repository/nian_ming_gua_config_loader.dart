import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

/// 从 Flutter assets 加载64卦天干配爻配置。
Future<List<NianMingGuaConfigContract>> loadNianMingGuaConfigs() async {
  final jsonStr = await rootBundle.loadString(
    'assets/nian_ming_gua/sixty_four_gua_stems.json',
  );
  final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
  return jsonList
      .map((e) => NianMingGuaConfigContract.fromJson(e as Map<String, dynamic>))
      .toList();
}
