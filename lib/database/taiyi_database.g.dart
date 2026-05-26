// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taiyi_database.dart';

// ignore_for_file: type=lint
class $UserSchoolsTable extends UserSchools
    with TableInfo<$UserSchoolsTable, UserSchool> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSchoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _contentJsonMeta =
      const VerificationMeta('contentJson');
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
      'content_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, source, contentJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_schools';
  @override
  VerificationContext validateIntegrity(Insertable<UserSchool> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('content_json')) {
      context.handle(
          _contentJsonMeta,
          contentJson.isAcceptableOrUnknown(
              data['content_json']!, _contentJsonMeta));
    } else if (isInserting) {
      context.missing(_contentJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSchool map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSchool(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      contentJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_json'])!,
    );
  }

  @override
  $UserSchoolsTable createAlias(String alias) {
    return $UserSchoolsTable(attachedDatabase, alias);
  }
}

class UserSchool extends DataClass implements Insertable<UserSchool> {
  final String id;
  final String name;
  final String source;
  final String contentJson;
  const UserSchool(
      {required this.id,
      required this.name,
      required this.source,
      required this.contentJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['source'] = Variable<String>(source);
    map['content_json'] = Variable<String>(contentJson);
    return map;
  }

  UserSchoolsCompanion toCompanion(bool nullToAbsent) {
    return UserSchoolsCompanion(
      id: Value(id),
      name: Value(name),
      source: Value(source),
      contentJson: Value(contentJson),
    );
  }

  factory UserSchool.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSchool(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String>(json['source']),
      contentJson: serializer.fromJson<String>(json['contentJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String>(source),
      'contentJson': serializer.toJson<String>(contentJson),
    };
  }

  UserSchool copyWith(
          {String? id, String? name, String? source, String? contentJson}) =>
      UserSchool(
        id: id ?? this.id,
        name: name ?? this.name,
        source: source ?? this.source,
        contentJson: contentJson ?? this.contentJson,
      );
  UserSchool copyWithCompanion(UserSchoolsCompanion data) {
    return UserSchool(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
      contentJson:
          data.contentJson.present ? data.contentJson.value : this.contentJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSchool(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('contentJson: $contentJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, source, contentJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSchool &&
          other.id == this.id &&
          other.name == this.name &&
          other.source == this.source &&
          other.contentJson == this.contentJson);
}

class UserSchoolsCompanion extends UpdateCompanion<UserSchool> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> source;
  final Value<String> contentJson;
  final Value<int> rowid;
  const UserSchoolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSchoolsCompanion.insert({
    required String id,
    required String name,
    this.source = const Value.absent(),
    required String contentJson,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        contentJson = Value(contentJson);
  static Insertable<UserSchool> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? source,
    Expression<String>? contentJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (contentJson != null) 'content_json': contentJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSchoolsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? source,
      Value<String>? contentJson,
      Value<int>? rowid}) {
    return UserSchoolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      contentJson: contentJson ?? this.contentJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSchoolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('contentJson: $contentJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserDeitiesTable extends UserDeities
    with TableInfo<$UserDeitiesTable, UserDeity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserDeitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _contentJsonMeta =
      const VerificationMeta('contentJson');
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
      'content_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, source, contentJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_deities';
  @override
  VerificationContext validateIntegrity(Insertable<UserDeity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('content_json')) {
      context.handle(
          _contentJsonMeta,
          contentJson.isAcceptableOrUnknown(
              data['content_json']!, _contentJsonMeta));
    } else if (isInserting) {
      context.missing(_contentJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserDeity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserDeity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      contentJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_json'])!,
    );
  }

  @override
  $UserDeitiesTable createAlias(String alias) {
    return $UserDeitiesTable(attachedDatabase, alias);
  }
}

class UserDeity extends DataClass implements Insertable<UserDeity> {
  final String id;
  final String name;
  final String source;
  final String contentJson;
  const UserDeity(
      {required this.id,
      required this.name,
      required this.source,
      required this.contentJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['source'] = Variable<String>(source);
    map['content_json'] = Variable<String>(contentJson);
    return map;
  }

  UserDeitiesCompanion toCompanion(bool nullToAbsent) {
    return UserDeitiesCompanion(
      id: Value(id),
      name: Value(name),
      source: Value(source),
      contentJson: Value(contentJson),
    );
  }

  factory UserDeity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserDeity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String>(json['source']),
      contentJson: serializer.fromJson<String>(json['contentJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String>(source),
      'contentJson': serializer.toJson<String>(contentJson),
    };
  }

  UserDeity copyWith(
          {String? id, String? name, String? source, String? contentJson}) =>
      UserDeity(
        id: id ?? this.id,
        name: name ?? this.name,
        source: source ?? this.source,
        contentJson: contentJson ?? this.contentJson,
      );
  UserDeity copyWithCompanion(UserDeitiesCompanion data) {
    return UserDeity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
      contentJson:
          data.contentJson.present ? data.contentJson.value : this.contentJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserDeity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('contentJson: $contentJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, source, contentJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserDeity &&
          other.id == this.id &&
          other.name == this.name &&
          other.source == this.source &&
          other.contentJson == this.contentJson);
}

class UserDeitiesCompanion extends UpdateCompanion<UserDeity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> source;
  final Value<String> contentJson;
  final Value<int> rowid;
  const UserDeitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserDeitiesCompanion.insert({
    required String id,
    required String name,
    this.source = const Value.absent(),
    required String contentJson,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        contentJson = Value(contentJson);
  static Insertable<UserDeity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? source,
    Expression<String>? contentJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (contentJson != null) 'content_json': contentJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserDeitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? source,
      Value<String>? contentJson,
      Value<int>? rowid}) {
    return UserDeitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      contentJson: contentJson ?? this.contentJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserDeitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('contentJson: $contentJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TaiYiDatabase extends GeneratedDatabase {
  _$TaiYiDatabase(QueryExecutor e) : super(e);
  $TaiYiDatabaseManager get managers => $TaiYiDatabaseManager(this);
  late final $UserSchoolsTable userSchools = $UserSchoolsTable(this);
  late final $UserDeitiesTable userDeities = $UserDeitiesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [userSchools, userDeities];
}

typedef $$UserSchoolsTableCreateCompanionBuilder = UserSchoolsCompanion
    Function({
  required String id,
  required String name,
  Value<String> source,
  required String contentJson,
  Value<int> rowid,
});
typedef $$UserSchoolsTableUpdateCompanionBuilder = UserSchoolsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> source,
  Value<String> contentJson,
  Value<int> rowid,
});

class $$UserSchoolsTableFilterComposer
    extends Composer<_$TaiYiDatabase, $UserSchoolsTable> {
  $$UserSchoolsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentJson => $composableBuilder(
      column: $table.contentJson, builder: (column) => ColumnFilters(column));
}

class $$UserSchoolsTableOrderingComposer
    extends Composer<_$TaiYiDatabase, $UserSchoolsTable> {
  $$UserSchoolsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentJson => $composableBuilder(
      column: $table.contentJson, builder: (column) => ColumnOrderings(column));
}

class $$UserSchoolsTableAnnotationComposer
    extends Composer<_$TaiYiDatabase, $UserSchoolsTable> {
  $$UserSchoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
      column: $table.contentJson, builder: (column) => column);
}

class $$UserSchoolsTableTableManager extends RootTableManager<
    _$TaiYiDatabase,
    $UserSchoolsTable,
    UserSchool,
    $$UserSchoolsTableFilterComposer,
    $$UserSchoolsTableOrderingComposer,
    $$UserSchoolsTableAnnotationComposer,
    $$UserSchoolsTableCreateCompanionBuilder,
    $$UserSchoolsTableUpdateCompanionBuilder,
    (
      UserSchool,
      BaseReferences<_$TaiYiDatabase, $UserSchoolsTable, UserSchool>
    ),
    UserSchool,
    PrefetchHooks Function()> {
  $$UserSchoolsTableTableManager(_$TaiYiDatabase db, $UserSchoolsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSchoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSchoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSchoolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> contentJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSchoolsCompanion(
            id: id,
            name: name,
            source: source,
            contentJson: contentJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> source = const Value.absent(),
            required String contentJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSchoolsCompanion.insert(
            id: id,
            name: name,
            source: source,
            contentJson: contentJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSchoolsTableProcessedTableManager = ProcessedTableManager<
    _$TaiYiDatabase,
    $UserSchoolsTable,
    UserSchool,
    $$UserSchoolsTableFilterComposer,
    $$UserSchoolsTableOrderingComposer,
    $$UserSchoolsTableAnnotationComposer,
    $$UserSchoolsTableCreateCompanionBuilder,
    $$UserSchoolsTableUpdateCompanionBuilder,
    (
      UserSchool,
      BaseReferences<_$TaiYiDatabase, $UserSchoolsTable, UserSchool>
    ),
    UserSchool,
    PrefetchHooks Function()>;
typedef $$UserDeitiesTableCreateCompanionBuilder = UserDeitiesCompanion
    Function({
  required String id,
  required String name,
  Value<String> source,
  required String contentJson,
  Value<int> rowid,
});
typedef $$UserDeitiesTableUpdateCompanionBuilder = UserDeitiesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> source,
  Value<String> contentJson,
  Value<int> rowid,
});

class $$UserDeitiesTableFilterComposer
    extends Composer<_$TaiYiDatabase, $UserDeitiesTable> {
  $$UserDeitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentJson => $composableBuilder(
      column: $table.contentJson, builder: (column) => ColumnFilters(column));
}

class $$UserDeitiesTableOrderingComposer
    extends Composer<_$TaiYiDatabase, $UserDeitiesTable> {
  $$UserDeitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentJson => $composableBuilder(
      column: $table.contentJson, builder: (column) => ColumnOrderings(column));
}

class $$UserDeitiesTableAnnotationComposer
    extends Composer<_$TaiYiDatabase, $UserDeitiesTable> {
  $$UserDeitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
      column: $table.contentJson, builder: (column) => column);
}

class $$UserDeitiesTableTableManager extends RootTableManager<
    _$TaiYiDatabase,
    $UserDeitiesTable,
    UserDeity,
    $$UserDeitiesTableFilterComposer,
    $$UserDeitiesTableOrderingComposer,
    $$UserDeitiesTableAnnotationComposer,
    $$UserDeitiesTableCreateCompanionBuilder,
    $$UserDeitiesTableUpdateCompanionBuilder,
    (UserDeity, BaseReferences<_$TaiYiDatabase, $UserDeitiesTable, UserDeity>),
    UserDeity,
    PrefetchHooks Function()> {
  $$UserDeitiesTableTableManager(_$TaiYiDatabase db, $UserDeitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserDeitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserDeitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserDeitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> contentJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserDeitiesCompanion(
            id: id,
            name: name,
            source: source,
            contentJson: contentJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> source = const Value.absent(),
            required String contentJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserDeitiesCompanion.insert(
            id: id,
            name: name,
            source: source,
            contentJson: contentJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserDeitiesTableProcessedTableManager = ProcessedTableManager<
    _$TaiYiDatabase,
    $UserDeitiesTable,
    UserDeity,
    $$UserDeitiesTableFilterComposer,
    $$UserDeitiesTableOrderingComposer,
    $$UserDeitiesTableAnnotationComposer,
    $$UserDeitiesTableCreateCompanionBuilder,
    $$UserDeitiesTableUpdateCompanionBuilder,
    (UserDeity, BaseReferences<_$TaiYiDatabase, $UserDeitiesTable, UserDeity>),
    UserDeity,
    PrefetchHooks Function()>;

class $TaiYiDatabaseManager {
  final _$TaiYiDatabase _db;
  $TaiYiDatabaseManager(this._db);
  $$UserSchoolsTableTableManager get userSchools =>
      $$UserSchoolsTableTableManager(_db, _db.userSchools);
  $$UserDeitiesTableTableManager get userDeities =>
      $$UserDeitiesTableTableManager(_db, _db.userDeities);
}
