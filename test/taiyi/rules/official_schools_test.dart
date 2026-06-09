import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/school_document.dart';

void main() {
  group('Official Schools Schema and Validity Tests', () {
    final officialSchoolFiles = [
      'jing_mirror.json',
      'tong_zong.json',
      'tao_jin_ge.json',
      'fu_ying.json',
      'ji_cheng.json',
    ];

    test('verifies all five official school documents', () {
      final Set<String> ids = {};

      for (final filename in officialSchoolFiles) {
        final file = File('assets/schools/$filename');
        expect(file.existsSync(), true, reason: '${file.path} should exist');

        final content = file.readAsStringSync();
        final json = jsonDecode(content) as Map<String, dynamic>;

        // 1. Schema validation
        final errors = validateSchoolJson(json);
        expect(errors.isEmpty, true, reason: 'Validation errors in $filename: $errors');

        // 2. Parse check
        final doc = SchoolDocument.fromJson(json);
        expect(doc.meta.id, isNotEmpty);
        expect(doc.meta.owner, 'official');

        // 3. ID uniqueness check
        expect(ids.contains(doc.meta.id), false, reason: 'Duplicate school ID: ${doc.meta.id}');
        ids.add(doc.meta.id);

        // 4. Check that rules are not empty
        expect(doc.rules, isNotEmpty);
      }

      expect(ids.length, 5);
    });
  });
}
