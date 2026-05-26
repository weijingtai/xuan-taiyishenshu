import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

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
          ),
        );

  TaiYiDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}
