// Widget tests for DeityEditorPage. Verify pure UI structure / read-only
// banner / chip rendering without booting the full Drift stack.
//
// Persistence is validated in
// test/integration/deity_editor_integration_test.dart — this file focuses on
// rendering shape, accessibility, and read-only enforcement.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/pages/deity_editor_page.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/data/in_memory_user_deity_repository.dart';
import 'package:taiyishenshu/taiyi/data/in_memory_user_school_repository.dart';
import 'package:taiyishenshu/taiyi/usecases/copy_deity_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/copy_school_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/delete_user_deity_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/deity_availability_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/load_deities_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/load_schools_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/save_user_deity_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/save_user_school_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/toggle_deity_preference_usecase.dart';
import 'package:taiyishenshu/taiyi/viewmodels/deity_view_model.dart';
import 'package:taiyishenshu/taiyi/viewmodels/school_view_model.dart';

DeityDefinition _officialTaiYi() => const DeityDefinition(
      id: 'taiYi',
      name: '太乙',
      layer: EnumDeityLayer.tianPan,
      algorithm: DeityAlgorithmSpec(templateId: AlgorithmTemplateId.fixedPosition),
      source: 'official',
      tier: 'core',
    );

DeityDefinition _userDerivedTaiYi() => const DeityDefinition(
      id: 'user_my_taiyi',
      name: '我的太乙',
      layer: EnumDeityLayer.tianPan,
      algorithm: DeityAlgorithmSpec(templateId: AlgorithmTemplateId.fixedPosition),
      source: 'user',
      tier: 'core',
      schoolScopes: <String>['jingMirror'],
      chartTypes: <String>['year'],
      color: '#C23B22',
      displayStyle: 'classical',
      sourceId: 'taiYi',
      rootOfficialId: 'taiYi',
      lineage: 'official(taiYi) -> user_my_taiyi',
    );

class _StubSchoolRepo implements SchoolRepository {
  final List<TaiYiSchool> _schools;
  final List<DeityDefinition> _deities;
  _StubSchoolRepo(this._schools, this._deities);

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async => _schools;
  @override
  Future<TaiYiSchool?> loadSchool(String id) async =>
      _schools.where((s) => s.id == id).cast<TaiYiSchool?>().firstOrNull;
  @override
  Future<List<DeityDefinition>> loadAllDeities() async => _deities;
  @override
  Future<DeityDefinition?> loadDeity(String id) async =>
      _deities.where((d) => d.id == id).cast<DeityDefinition?>().firstOrNull;
  @override
  Future<void> saveSchool(TaiYiSchool school) =>
      throw UnsupportedError('read-only');
  @override
  Future<void> saveDeity(DeityDefinition deity) =>
      throw UnsupportedError('read-only');
  @override
  Future<void> deleteSchool(String id) => throw UnsupportedError('read-only');
  @override
  Future<void> deleteDeity(String id) => throw UnsupportedError('read-only');
}

class _StubPrefRepo implements DeityPreferenceRepository {
  @override
  Future<bool> isEnabled(String deityId) async => true;
  @override
  Future<void> setEnabled(String deityId, bool enabled) async {}
  @override
  Future<Map<String, bool>> loadEnabledMap() async => <String, bool>{};
}

({DeityViewModel deityVM, SchoolViewModel schoolVM}) _wireVMs() {
  final officialRepo = _StubSchoolRepo(
    <TaiYiSchool>[
      const TaiYiSchool(
        id: 'jingMirror',
        name: '金镜派',
        source: 'official',
        epoch: SchoolEpochConfig(ancientBase: 1937281, epochYear: 724),
      ),
      const TaiYiSchool(
        id: 'tongZong',
        name: '统宗派',
        source: 'official',
        epoch: SchoolEpochConfig(ancientBase: 10155219, epochYear: 1303),
      ),
    ],
    <DeityDefinition>[_officialTaiYi()],
  );
  final userRepo = InMemoryUserDeityRepository();
  final userSchoolRepo = InMemoryUserSchoolRepository();
  final prefRepo = _StubPrefRepo();

  final deityVM = DeityViewModel(
    loadDeitiesUseCase: LoadDeitiesUseCase(officialRepo, userRepo),
    copyDeityUseCase: CopyDeityUseCase(officialRepo, userRepo),
    saveUserDeityUseCase: SaveUserDeityUseCase(userRepo),
    deleteUserDeityUseCase: DeleteUserDeityUseCase(userRepo),
    toggleDeityPreferenceUseCase: ToggleDeityPreferenceUseCase(prefRepo),
    deityAvailabilityUseCase: DeityAvailabilityUseCase(officialRepo, userSchoolRepo),
  );
  final schoolVM = SchoolViewModel(
    loadSchoolsUseCase: LoadSchoolsUseCase(officialRepo, userSchoolRepo),
    copySchoolUseCase: CopySchoolUseCase(officialRepo, userSchoolRepo),
    saveUserSchoolUseCase: SaveUserSchoolUseCase(userSchoolRepo),
  );
  return (deityVM: deityVM, schoolVM: schoolVM);
}

Widget _wrap(Widget child,
    {required DeityViewModel deityVM, required SchoolViewModel schoolVM}) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<DeityViewModel>.value(value: deityVM),
        ChangeNotifierProvider<SchoolViewModel>.value(value: schoolVM),
      ],
      child: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeityEditorPage UI structure', () {
    testWidgets(
        'Official deity: banner present, name field disabled, save disabled, '
        '"Copy and edit" button visible',
        (tester) async {
      final vms = _wireVMs();
      await vms.schoolVM.loadSchools();
      await vms.deityVM.loadDeities();

      await tester.pumpWidget(_wrap(
        DeityEditorPage(deity: _officialTaiYi()),
        deityVM: vms.deityVM,
        schoolVM: vms.schoolVM,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('deity_editor_readonly_banner')),
          findsOneWidget);
      expect(find.byKey(const Key('deity_editor_copy_and_edit_button')),
          findsOneWidget);
      final nameField = tester.widget<TextField>(
          find.byKey(const Key('deity_editor_name_field')));
      expect(nameField.enabled, isFalse);
      final IconButton saveBtn = tester.widget<IconButton>(
          find.byKey(const Key('deity_editor_save_button')));
      expect(saveBtn.onPressed, isNull);
    });

    testWidgets(
        'User deity: no banner, name editable, save enabled, school chips '
        'and chart-type chips reflect persisted state',
        (tester) async {
      final vms = _wireVMs();
      await vms.schoolVM.loadSchools();

      await tester.pumpWidget(_wrap(
        DeityEditorPage(deity: _userDerivedTaiYi()),
        deityVM: vms.deityVM,
        schoolVM: vms.schoolVM,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('deity_editor_readonly_banner')),
          findsNothing);
      final IconButton saveBtn = tester.widget<IconButton>(
          find.byKey(const Key('deity_editor_save_button')));
      expect(saveBtn.onPressed, isNotNull);

      final nameField = tester.widget<TextField>(
          find.byKey(const Key('deity_editor_name_field')));
      expect(nameField.enabled, isTrue);
      expect(nameField.controller!.text, '我的太乙');

      // jingMirror chip is selected (the persisted scope).
      final jmChip = find.byKey(const Key('deity_editor_school_chip_jingMirror'));
      expect(jmChip, findsOneWidget);
      expect(
        find.descendant(of: jmChip, matching: find.byIcon(Icons.check_box)),
        findsOneWidget,
      );
      // tongZong chip is not selected.
      final tzChip = find.byKey(const Key('deity_editor_school_chip_tongZong'));
      expect(
        find.descendant(
            of: tzChip, matching: find.byIcon(Icons.check_box_outline_blank)),
        findsOneWidget,
      );

      // year chip selected, ke chip rendered as placeholder reserved.
      final yearChip = find.byKey(const Key('deity_editor_chart_chip_year'));
      expect(
        find.descendant(of: yearChip, matching: find.byIcon(Icons.check_box)),
        findsOneWidget,
      );
      expect(find.byKey(const Key('deity_editor_chart_chip_ke')),
          findsOneWidget);
    });

    testWidgets(
        'Lineage section never hard-codes "演自/派生" — chain is parsed from '
        'real deity.lineage segments',
        (tester) async {
      final vms = _wireVMs();
      await vms.schoolVM.loadSchools();

      await tester.pumpWidget(_wrap(
        DeityEditorPage(deity: _userDerivedTaiYi()),
        deityVM: vms.deityVM,
        schoolVM: vms.schoolVM,
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('演自'), findsNothing);
      expect(find.textContaining('派生自'), findsNothing);
      // The chain must surface the literal lineage segments.
      final chain = find.byKey(const Key('deity_editor_lineage_chain'));
      expect(chain, findsOneWidget);
      expect(
        find.descendant(of: chain, matching: find.text('official(taiYi)')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: chain, matching: find.text('user_my_taiyi')),
        findsOneWidget,
      );
    });

    testWidgets('Touch targets for chips meet the >=44 pt minimum',
        (tester) async {
      final vms = _wireVMs();
      await vms.schoolVM.loadSchools();

      await tester.pumpWidget(_wrap(
        DeityEditorPage(deity: _userDerivedTaiYi()),
        deityVM: vms.deityVM,
        schoolVM: vms.schoolVM,
      ));
      await tester.pumpAndSettle();

      final jmChip = find.byKey(const Key('deity_editor_school_chip_jingMirror'));
      final size = tester.getSize(jmChip);
      expect(size.height >= 44, isTrue,
          reason: 'chip height (${size.height}) must be >= 44pt');
    });
  });
}
