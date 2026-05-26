import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'taiyi_database_memory_stub.dart'
    if (dart.library.ffi) 'taiyi_database_memory_native.dart';

part 'taiyi_database.g.dart';

class UserSchools extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get source => text().withDefault(const Constant('user'))();
  TextColumn get contentJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserDeities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get source => text().withDefault(const Constant('user'))();
  TextColumn get contentJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [UserSchools, UserDeities])
class TaiYiDatabase extends _$TaiYiDatabase {
  TaiYiDatabase()
      : super(
          driftDatabase(
            name: 'taiyi_database',
            native: const DriftNativeOptions(
              databaseDirectory: getApplicationSupportDirectory,
            ),
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
              onResult: (result) {
                debugPrint(
                  '[TaiYiDatabase] Web storage: ${result.chosenImplementation}',
                );
                if (result.missingFeatures.isNotEmpty) {
                  debugPrint(
                    '[TaiYiDatabase] Missing features: ${result.missingFeatures}',
                  );
                }
              },
            ),
          ),
        );

  /// In-memory test executor. Native-only — on web this throws
  /// UnsupportedError. Used by the integration tests in
  /// `test/integration/zt30_*.dart`.
  TaiYiDatabase.memory() : super(createMemoryExecutor());

  @override
  int get schemaVersion => 1;
}
