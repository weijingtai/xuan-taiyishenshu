import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/school_repository.dart';
import 'package:taiyishenshu/taiyi/rules/school_document.dart';

void main() {
  group('SchoolRepository Tests', () {
    late SchoolRepository repository;

    setUp(() {
      repository = SchoolRepository(
        assetLoader: (path) async {
          final file = File(path);
          if (file.existsSync()) {
            return file.readAsStringSync();
          }
          throw FileSystemException('File not found', path);
        },
      );
    });

    test('loads official school successfully', () async {
      final doc = await repository.loadSchool('jing_mirror');
      expect(doc, isNotNull);
      expect(doc!.meta.id, 'jing_mirror');
      expect(doc.meta.owner, 'official');
    });

    test('refuses to modify official school', () async {
      final doc = await repository.loadSchool('jing_mirror');
      expect(doc, isNotNull);

      // Attempt to save official school should throw UnsupportedError
      expect(
        () => repository.saveSchool(doc!),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('refuses to delete official school', () async {
      expect(
        () => repository.deleteSchool('jing_mirror'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('fork official school, modify, save, and load back successfully', () async {
      final official = await repository.loadSchool('jing_mirror');
      expect(official, isNotNull);

      // Convert to JSON, modify metadata and id, then parse back as a user school
      final json = official!.toJson();
      final meta = Map<String, dynamic>.from(json['meta'] as Map);
      meta['id'] = 'user_forked_jing';
      meta['name'] = 'User Forked Jing';
      meta['owner'] = 'user';
      json['meta'] = meta;

      final forked = SchoolDocument.fromJson(json);

      // Save user school
      await repository.saveSchool(forked);

      // Load back
      final loaded = await repository.loadSchool('user_forked_jing');
      expect(loaded, isNotNull);
      expect(loaded!.meta.id, 'user_forked_jing');
      expect(loaded.meta.name, 'User Forked Jing');
      expect(loaded.meta.owner, 'user');

      // Delete user school
      await repository.deleteSchool('user_forked_jing');
      final deleted = await repository.loadSchool('user_forked_jing');
      expect(deleted, isNull);
    });

    test('rejects save on invalid school document', () async {
      final official = await repository.loadSchool('jing_mirror');
      expect(official, isNotNull);

      final json = official!.toJson();
      final meta = Map<String, dynamic>.from(json['meta'] as Map);
      meta['id'] = 'invalid_user_school';
      meta['owner'] = 'user';
      json['meta'] = meta;

      // Introduce a DAG cycle to make it invalid
      json['rules'] = [
        {
          'id': 'ruleA',
          'kind': 'scalar',
          'output': 'scalar',
          'tree': {
            'op': '+',
            'a': {'int': 1},
            'b': {'var': 'ruleB'}
          }
        },
        {
          'id': 'ruleB',
          'kind': 'scalar',
          'output': 'scalar',
          'tree': {
            'op': '+',
            'a': {'int': 2},
            'b': {'var': 'ruleA'}
          }
        }
      ];

      final invalidDoc = SchoolDocument.fromJson(json);

      // Attempt to save should throw ArgumentError due to validation failure (DAG cycle)
      expect(
        () => repository.saveSchool(invalidDoc),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
