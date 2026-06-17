import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Returns true if [source] contains a forbidden import of package:xuan_config.
/// Matches actual `import` statements only (not arbitrary text references).
bool containsForbiddenImport(String source) {
  return RegExp(r'''import\s+['"]package:xuan_config/''').hasMatch(source);
}

/// Walks all .dart files under [dir] and returns those that contain
/// a forbidden package:xuan_config import.
List<File> filesWithForbiddenImport(Directory dir) {
  final offenders = <File>[];
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      if (containsForbiddenImport(content)) {
        offenders.add(entity);
      }
    }
  }
  return offenders;
}

void main() {
  group('Theme token governance', () {
    test('production widgets do not import xuan_config', () {
      final libDir = Directory(
        '${Directory.current.path}/lib/widgets',
      );

      // Non-empty scan assertion: the lib/widgets directory must exist
      // and contain at least one .dart file.
      expect(libDir.existsSync(), isTrue, reason: 'lib/widgets must exist');
      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      expect(dartFiles, isNotEmpty, reason: 'must scan at least one .dart file');

      // GREEN predicate proof: the migrated file must be clean.
      final migratedSource = File('lib/widgets/taiyi_pan_grid_v2.dart')
          .readAsStringSync();
      expect(
        containsForbiddenImport(migratedSource),
        isFalse,
        reason: 'GREEN: migrated widget must not import xuan_config',
      );

      // RED predicate proof: a known-bad import statement should be detected.
      // Split the string to avoid self-detection by the regex.
      const sep = 'xuan_config';
      expect(
        containsForbiddenImport("import 'package:$sep/foo.dart';"),
        isTrue,
        reason: 'RED: predicate must detect package:xuan_config import',
      );

      // Actual governance check: no production widget may import xuan_config.
      final offenders = filesWithForbiddenImport(libDir);
      expect(
        offenders,
        isEmpty,
        reason:
            'No production widget may import package:xuan_config. '
            'Offenders: ${offenders.map((f) => f.path).join(', ')}',
      );
    });

    test('scan path self-proves RED via temp dir with offender', () {
      final tmpDir = Directory.systemTemp.createTempSync('governance_red_');
      try {
        // Write an offender file into the temp dir.
        File('${tmpDir.path}/offender.dart').writeAsStringSync(
          "import 'package:xuan_config/xuan_config.dart';\nvoid main() {}\n",
        );

        // The scan must find exactly one offender.
        final offenders = filesWithForbiddenImport(tmpDir);
        expect(offenders, hasLength(1));
        expect(offenders.first.path, contains('offender.dart'));
      } finally {
        tmpDir.deleteSync(recursive: true);
      }
    });

    test('phase 6 batch 1 component ids present in source', () {
      // Verify that taiyi_pan_grid_v2.dart contains the component id
      // 'taiyi_pan_grid_v2' in a component() call, proving the migration
      // has been applied.
      final source = File('lib/widgets/taiyi_pan_grid_v2.dart')
          .readAsStringSync();
      expect(
        source,
        contains("component('taiyi_pan_grid_v2')"),
        reason:
            'taiyi_pan_grid_v2.dart must contain '
            "component('taiyi_pan_grid_v2') after migration",
      );
    });
  });
}
