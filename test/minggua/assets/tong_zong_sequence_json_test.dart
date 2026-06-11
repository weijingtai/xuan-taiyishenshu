import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

void main() {
  group('ACT-012: 统宗六十四卦序 JSON 配置文件', () {
    late Map<String, dynamic> json;

    setUpAll(() {
      final file = File('assets/minggua/tong_zong_sequence.json');
      json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('JSON可解析为MingGuaConfigContract', () {
      final config = MingGuaConfigContract.fromJson(json);
      expect(config.guaSequence.length, 64);
      expect(config.epochBase, 10153917);
    });

    test('第43位=姤', () {
      expect((json['guaSequence'] as List)[42], '姤');
    });

    test('第1位=乾,第64位=未济', () {
      final seq = json['guaSequence'] as List;
      expect(seq[0], '乾');
      expect(seq[63], '未济');
    });
  });
}
