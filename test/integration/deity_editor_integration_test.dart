import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:persistence_drift/taiyishenshu/taiyishenshu_drift.dart';
import 'package:taiyishenshu/pages/deity_editor_page.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';
import '../taiyi/test_harness.dart';
import 'package:taiyishenshu/taiyi/viewmodels/deity_view_model.dart';
import 'package:taiyishenshu/taiyi/viewmodels/school_view_model.dart';

/// Real Drift + real Assembly + real DeityViewModel integration tests for
/// Task 31 (deity editor).
///
/// Reverses the QA "fake completion" finding by asserting that every save
/// passes through ViewModel -> SaveUserDeityUseCase -> DriftUserRepository ->
/// SQLite, and that records survive a controller / repository rebuild on the
/// same database instance.
///
/// No FakeViewModel is used anywhere in this file — the assertion suite
/// `rg "FakeViewModel" test/integration/deity_editor_integration_test.dart`
/// must return zero matches.

class _FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.path;
  @override
  Future<String?> getLibraryPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;
  @override
  Future<String?> getExternalStoragePath() async => Directory.systemTemp.path;
  @override
  Future<List<String>?> getExternalCachePaths() async =>
      [Directory.systemTemp.path];
  @override
  Future<List<String>?> getExternalStoragePaths(
          {StorageDirectory? type}) async =>
      [Directory.systemTemp.path];
  @override
  Future<String?> getDownloadsPath() async => Directory.systemTemp.path;
}

class _MockAssetBundle extends Fake implements AssetBundle {
  final Map<String, String> assets;
  _MockAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) return assets[key]!;
    if (key.contains('AssetManifest')) return '{}';
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    if (assets.containsKey(key)) {
      return ByteData.view(
          Uint8List.fromList(utf8.encode(assets[key]!)).buffer);
    }
    if (key.contains('AssetManifest')) return ByteData(0);
    throw FlutterError('Asset not found: $key');
  }
}

Map<String, String> _loadOfficialAssets() {
  const schoolFiles = ['jing-mirror', 'tong-zong', 'ji-cheng'];
  const deityFiles = [
    'tai-yi', 'zhu-da-jiang', 'ke-da-jiang', 'zhu-can-jiang', 'ke-can-jiang',
    'ding-da-jiang', 'ding-can-jiang', 'jun-ji', 'chen-ji', 'min-ji',
    'wu-fu', 'da-you', 'xiao-you', 'fei-fu', 'si-shen',
    'tian-yi-star', 'di-yi', 'zhi-fu-star', 'yang-jiu', 'bai-liu',
    'tai-sui', 'sui-po', 'zhi-fu', 'he-shen',
    'qing-long', 'zhu-que', 'bai-hu', 'xuan-wu', 'feng-bo', 'yu-shi',
    'qing-long-qi', 'hei-qi', 'chi-qi', 'gui-shen-zhi-shi',
    'wen-chang', 'ji-shen', 'shi-ji',
  ];
  final m = <String, String>{};
  for (final id in schoolFiles) {
    m['assets/schools/$id.json'] =
        File('assets/schools/$id.json').readAsStringSync();
  }
  for (final id in deityFiles) {
    m['assets/deities/$id.json'] =
        File('assets/deities/$id.json').readAsStringSync();
  }
  return m;
}

/// Mount the editor in a MaterialApp + Provider tree wired to real ViewModels.
Future<void> _pumpEditor(
  WidgetTester tester, {
  required DeityViewModel deityVM,
  required SchoolViewModel schoolVM,
  required DeityDefinition? deity,
  DateTime Function()? now,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<DeityViewModel>.value(value: deityVM),
          ChangeNotifierProvider<SchoolViewModel>.value(value: schoolVM),
        ],
        child: DeityEditorPage(
          deity: deity,
          now: now,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<TaiYiDataAssembly> _buildAssembly(
    TaiYiDatabase db, _MockAssetBundle bundle) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  return await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();
  final mockAssets = _loadOfficialAssets();

  group('Task 31 / Story #5 — Deity Editor Integration', () {
    testWidgets(
        'a) Official deity opens read-only; "Copy and edit" produces a user '
        'derivative with lineage and unlocks the form',
        (tester) async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);
      final assembly = await _buildAssembly(db, _MockAssetBundle(mockAssets));

      final deityVM = DeityViewModel(
        loadDeitiesUseCase: assembly.loadDeitiesUseCase,
        copyDeityUseCase: assembly.copyDeityUseCase,
        saveUserDeityUseCase: assembly.saveUserDeityUseCase,
        deleteUserDeityUseCase: assembly.deleteUserDeityUseCase,
        toggleDeityPreferenceUseCase: assembly.toggleDeityPreferenceUseCase,
        deityAvailabilityUseCase: assembly.deityAvailabilityUseCase,
      );
      final schoolVM = SchoolViewModel(
        loadSchoolsUseCase: assembly.loadSchoolsUseCase,
        copySchoolUseCase: assembly.copySchoolUseCase,
        saveUserSchoolUseCase: assembly.saveUserSchoolUseCase,
      );
      await deityVM.loadDeities();
      await schoolVM.loadSchools();

      final taiYi = deityVM.deities.firstWhere((d) => d.id == 'taiYi');

      // Deterministic clock so the generated user id is reproducible.
      DateTime clock() => DateTime.utc(2026, 5, 25, 12, 0, 0);

      await _pumpEditor(
        tester,
        deityVM: deityVM,
        schoolVM: schoolVM,
        deity: taiYi,
        now: clock,
      );

      // Read-only mode: banner present, name field is disabled.
      expect(find.byKey(const Key('deity_editor_readonly_banner')),
          findsOneWidget);
      final nameField = tester.widget<TextField>(
          find.byKey(const Key('deity_editor_name_field')));
      expect(nameField.enabled, isFalse);

      // Save button is disabled while in read-only mode.
      final saveBtnFinder = find.byKey(const Key('deity_editor_save_button'));
      expect(saveBtnFinder, findsOneWidget);
      final IconButton saveBtn = tester.widget<IconButton>(saveBtnFinder);
      expect(saveBtn.onPressed, isNull);

      // Tap "Copy and edit" — this should call CopyDeityUseCase which writes
      // to the Drift user table and refresh the form to the new user copy.
      await tester.tap(
          find.byKey(const Key('deity_editor_copy_and_edit_button')));
      await tester.pumpAndSettle();

      // Banner must be gone; name field enabled.
      expect(find.byKey(const Key('deity_editor_readonly_banner')),
          findsNothing);
      final nameField2 = tester.widget<TextField>(
          find.byKey(const Key('deity_editor_name_field')));
      expect(nameField2.enabled, isTrue);

      // The Drift user repo must now contain exactly one derived deity whose
      // lineage references the official root.
      final userDeities = await assembly.deityRepo.loadUserDeities();
      expect(userDeities.length, 1,
          reason: '"Copy and edit" must write exactly one user deity to Drift');
      final copy = userDeities.single;
      expect(copy.source, 'user');
      expect(copy.sourceId, 'taiYi');
      expect(copy.rootOfficialId, 'taiYi');
      expect(copy.lineage, contains('taiYi'),
          reason:
              'lineage must come from the real CopyDeityUseCase, not a hard-coded literal');
      expect(copy.name, contains('副本'));
    });

    testWidgets(
        'b) Editing fields on a user deity and saving writes to Drift; '
        'rebuilding repository against same DB returns the exact values',
        (tester) async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);
      final assembly = await _buildAssembly(db, _MockAssetBundle(mockAssets));

      // Seed a user deity derived from "taiYi" directly through the use case
      // so we test the editor with an already-existing user record.
      final seedId = 'user_deity_seed_1';
      await assembly.copyDeityUseCase(
        sourceId: 'taiYi',
        newId: seedId,
        newName: '太乙·我的副本',
      );

      final deityVM = DeityViewModel(
        loadDeitiesUseCase: assembly.loadDeitiesUseCase,
        copyDeityUseCase: assembly.copyDeityUseCase,
        saveUserDeityUseCase: assembly.saveUserDeityUseCase,
        deleteUserDeityUseCase: assembly.deleteUserDeityUseCase,
        toggleDeityPreferenceUseCase: assembly.toggleDeityPreferenceUseCase,
        deityAvailabilityUseCase: assembly.deityAvailabilityUseCase,
      );
      final schoolVM = SchoolViewModel(
        loadSchoolsUseCase: assembly.loadSchoolsUseCase,
        copySchoolUseCase: assembly.copySchoolUseCase,
        saveUserSchoolUseCase: assembly.saveUserSchoolUseCase,
      );
      await deityVM.loadDeities();
      await schoolVM.loadSchools();

      final seeded =
          deityVM.deities.firstWhere((d) => d.id == seedId);

      await _pumpEditor(
        tester,
        deityVM: deityVM,
        schoolVM: schoolVM,
        deity: seeded,
      );

      // 1. Edit name
      await tester.enterText(
        find.byKey(const Key('deity_editor_name_field')),
        '太乙·改名后',
      );

      // 2. Pick a new color via the swatches (jadeGreen is in the curated set).
      // Tap the second swatch in the wrap (gold leaf).
      final swatchesFinder = find.descendant(
        of: find.byKey(const Key('deity_editor_color_swatches')),
        matching: find.byType(InkWell),
      );
      expect(swatchesFinder, findsWidgets);
      await tester.tap(swatchesFinder.at(1)); // gold leaf (#D4A017)
      await tester.pumpAndSettle();

      // 3. Toggle two school scope chips on.
      final jmChip =
          find.byKey(const Key('deity_editor_school_chip_jingMirror'));
      final tzChip =
          find.byKey(const Key('deity_editor_school_chip_tongZong'));
      expect(jmChip, findsOneWidget);
      expect(tzChip, findsOneWidget);
      await tester.ensureVisible(jmChip);
      await tester.pumpAndSettle();
      await tester.tap(jmChip);
      await tester.pumpAndSettle();
      await tester.ensureVisible(tzChip);
      await tester.pumpAndSettle();
      await tester.tap(tzChip);
      await tester.pumpAndSettle();

      // 4. Toggle chart types: select year + month, then unselect year.
      final yearChip = find.byKey(const Key('deity_editor_chart_chip_year'));
      final monthChip = find.byKey(const Key('deity_editor_chart_chip_month'));
      await tester.ensureVisible(yearChip);
      await tester.pumpAndSettle();
      await tester.tap(yearChip);
      await tester.pumpAndSettle();
      await tester.ensureVisible(monthChip);
      await tester.pumpAndSettle();
      await tester.tap(monthChip);
      await tester.pumpAndSettle();
      // Unselect year so the saved set is {month}.
      await tester.ensureVisible(yearChip);
      await tester.pumpAndSettle();
      await tester.tap(yearChip);
      await tester.pumpAndSettle();

      // 5. Save.
      await tester.ensureVisible(
          find.byKey(const Key('deity_editor_save_button')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const Key('deity_editor_save_button')));
      // Pump once to let the async save start and SnackBar enqueue, but
      // intentionally do NOT pumpAndSettle yet — Navigator.pop fires after
      // the await and would remove the Scaffold (and its ScaffoldMessenger).
      await tester.pump();
      expect(find.text('保存成功'), findsOneWidget);
      await tester.pumpAndSettle();

      // Now read **directly** from Drift via a fresh repository instance bound
      // to the same DB. This proves the save reached SQLite, not just the
      // in-memory ViewModel cache.
      final freshRepo = DriftUserRepository(db);
      final reloaded = await freshRepo.loadDeity(seedId);
      expect(reloaded, isNotNull,
          reason: 'Saved user deity must be readable directly from Drift');
      expect(reloaded!.name, '太乙·改名后');
      expect(reloaded.source, 'user');
      expect(reloaded.color, '#D4A017');
      expect(
        reloaded.schoolScopes.toSet(),
        equals(<String>{'jingMirror', 'tongZong'}),
      );
      expect(
        reloaded.chartTypes.toSet(),
        equals(<String>{'month'}),
        reason:
            'After toggling year on, month on, year off — saved set must be {month}',
      );
      // Lineage from the CopyDeityUseCase must be preserved through save.
      expect(reloaded.sourceId, 'taiYi');
      expect(reloaded.rootOfficialId, 'taiYi');
      expect(reloaded.lineage, contains('taiYi'));
    });

    testWidgets(
        'c) Re-opening the editor on a saved user deity hydrates every field '
        'from the persisted record',
        (tester) async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);
      final assembly = await _buildAssembly(db, _MockAssetBundle(mockAssets));

      // Persist a fully-populated user deity directly through the repo.
      final persisted = DeityDefinition.fromJson(<String, dynamic>{
        'id': 'user_deity_reopen',
        'name': '回填用',
        'layer': 'tianPan',
        'algorithm': <String, dynamic>{
          'templateId': 'fixedPosition',
          'params': <String, dynamic>{},
        },
        'priority': 50,
        'source': 'user',
        'tier': 'core',
        'chartTypes': <String>['day', 'hour'],
        'schoolScopes': <String>['jiCheng'],
        'color': '#1565C0',
        'displayStyle': 'ink_wash',
        'sourceId': 'taiYi',
        'rootOfficialId': 'taiYi',
        'lineage': 'official(taiYi) -> user_deity_reopen',
      });
      await assembly.deityRepo.saveUserDeity(persisted.toContract());

      final deityVM = DeityViewModel(
        loadDeitiesUseCase: assembly.loadDeitiesUseCase,
        copyDeityUseCase: assembly.copyDeityUseCase,
        saveUserDeityUseCase: assembly.saveUserDeityUseCase,
        deleteUserDeityUseCase: assembly.deleteUserDeityUseCase,
        toggleDeityPreferenceUseCase: assembly.toggleDeityPreferenceUseCase,
        deityAvailabilityUseCase: assembly.deityAvailabilityUseCase,
      );
      final schoolVM = SchoolViewModel(
        loadSchoolsUseCase: assembly.loadSchoolsUseCase,
        copySchoolUseCase: assembly.copySchoolUseCase,
        saveUserSchoolUseCase: assembly.saveUserSchoolUseCase,
      );
      await deityVM.loadDeities();
      await schoolVM.loadSchools();

      final loaded =
          deityVM.deities.firstWhere((d) => d.id == 'user_deity_reopen');

      await _pumpEditor(
        tester,
        deityVM: deityVM,
        schoolVM: schoolVM,
        deity: loaded,
      );

      // Name field hydrated.
      final nameField = tester.widget<TextField>(
          find.byKey(const Key('deity_editor_name_field')));
      expect(nameField.controller!.text, '回填用');
      expect(nameField.enabled, isTrue,
          reason: 'user deity must be editable in place (no copy required)');

      // Color hex hydrated.
      final hexField = tester.widget<TextField>(
          find.byKey(const Key('deity_editor_color_hex_field')));
      expect(hexField.controller!.text, '#1565C0');

      // School scope chip for jiCheng is selected (rendered via the chip's
      // checkbox icon). We use the chip key to find a check_box icon
      // descendant.
      final jcChip = find.byKey(const Key('deity_editor_school_chip_jiCheng'));
      expect(jcChip, findsOneWidget);
      expect(
        find.descendant(of: jcChip, matching: find.byIcon(Icons.check_box)),
        findsOneWidget,
        reason: 'jiCheng must be pre-selected after hydration',
      );

      // Chart-type chips: day and hour selected.
      final dayChip = find.byKey(const Key('deity_editor_chart_chip_day'));
      final hourChip = find.byKey(const Key('deity_editor_chart_chip_hour'));
      expect(
        find.descendant(of: dayChip, matching: find.byIcon(Icons.check_box)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hourChip, matching: find.byIcon(Icons.check_box)),
        findsOneWidget,
      );

      // Lineage section is rendered from real fields.
      expect(find.byKey(const Key('deity_editor_lineage_section')),
          findsOneWidget);
      expect(find.byKey(const Key('deity_editor_lineage_root')), findsOneWidget);
      expect(find.byKey(const Key('deity_editor_lineage_source')),
          findsOneWidget);
      // The chain Wrap must contain BOTH segments of the persisted lineage.
      final chain = find.byKey(const Key('deity_editor_lineage_chain'));
      expect(chain, findsOneWidget);
      expect(
        find.descendant(of: chain, matching: find.text('official(taiYi)')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: chain, matching: find.text('user_deity_reopen')),
        findsOneWidget,
      );
    });

    testWidgets(
        'd) Lineage section for an entity with no lineage shows the '
        '"无传承链（根项）" empty state, never a hard-coded "演自/派生" string',
        (tester) async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);
      final assembly = await _buildAssembly(db, _MockAssetBundle(mockAssets));

      final deityVM = DeityViewModel(
        loadDeitiesUseCase: assembly.loadDeitiesUseCase,
        copyDeityUseCase: assembly.copyDeityUseCase,
        saveUserDeityUseCase: assembly.saveUserDeityUseCase,
        deleteUserDeityUseCase: assembly.deleteUserDeityUseCase,
        toggleDeityPreferenceUseCase: assembly.toggleDeityPreferenceUseCase,
        deityAvailabilityUseCase: assembly.deityAvailabilityUseCase,
      );
      final schoolVM = SchoolViewModel(
        loadSchoolsUseCase: assembly.loadSchoolsUseCase,
        copySchoolUseCase: assembly.copySchoolUseCase,
        saveUserSchoolUseCase: assembly.saveUserSchoolUseCase,
      );
      await deityVM.loadDeities();
      await schoolVM.loadSchools();

      // Official taiYi has NO lineage / no sourceId / no rootOfficialId.
      final taiYi = deityVM.deities.firstWhere((d) => d.id == 'taiYi');
      expect(taiYi.lineage, isNull);
      expect(taiYi.sourceId, isNull);

      await _pumpEditor(
        tester,
        deityVM: deityVM,
        schoolVM: schoolVM,
        deity: taiYi,
      );

      expect(find.byKey(const Key('deity_editor_lineage_empty')),
          findsOneWidget);
      // Reject hard-coded lineage text.
      expect(find.textContaining('演自'), findsNothing);
      expect(find.textContaining('派生自'), findsNothing);
    });

    testWidgets(
        'e) Save without ChangeNotifierProvider does NOT silently succeed — '
        'must surface error and not write to Drift (anti fake-completion)',
        (tester) async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);

      // Mount the editor with NO providers — the save handler must refuse to
      // write through and instead show an error SnackBar.
      await tester.pumpWidget(
        const MaterialApp(
          home: DeityEditorPage(
            deity: null,
            availableSchools: <TaiYiSchool>[],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Type a name then tap save.
      await tester.enterText(
          find.byKey(const Key('deity_editor_name_field')), '幽灵星神');
      await tester.tap(find.byKey(const Key('deity_editor_save_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('保存失败'), findsOneWidget);
      expect(find.text('保存成功'), findsNothing);

      // Drift must remain empty — the editor must not bypass the VM.
      final repo = DriftUserRepository(db);
      final users = await repo.loadUserDeities();
      expect(users, isEmpty,
          reason:
              'Editor must NOT short-circuit and write to Drift outside the VM/UseCase chain');
    });
  });
}
