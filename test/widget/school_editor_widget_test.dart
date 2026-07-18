// Widget tests for SchoolEditorPage. Verifies UI structure, read-only banner
// for official schools, and field rendering for user schools.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taiyishenshu/l10n/app_localizations.dart';
import 'package:taiyishenshu/pages/school_editor_page.dart';
import 'package:taiyishenshu/taiyi/core/chart_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/deity_override.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/usecases/copy_school_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/load_schools_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/save_user_school_usecase.dart';
import 'package:taiyishenshu/taiyi/viewmodels/school_view_model.dart';
import '../taiyi/fakes/in_memory_user_school_repository.dart';

TaiYiSchool _officialSchool() => const TaiYiSchool(
      id: 'jingMirror',
      name: '金镜派',
      source: 'official',
      epoch: SchoolEpochConfig(
        ancientBase: 1937281,
        epochYear: 724,
        correction: 0,
        tropicalYear: 365.2425,
      ),
      deityIds: ['taiYi', 'wenChang', 'jiShen'],
      wenChangStayRule: true,
      useTwelveJiShen: false,
      palaceFormula: 'jingMirror',
      eightDoorMode: 'dynamic',
      chartConfigs: {'year': ChartConfig()},
      deityConfigs: {'taiYi': DeityOverride()},
      privateDeities: ['user_my_taiyi'],
    );

TaiYiSchool _userSchool() => _officialSchool().copyWith(
      id: 'user_mine',
      name: '我的派',
      source: 'user',
      sourceId: 'jingMirror',
      rootOfficialId: 'jingMirror',
      lineage: 'official(jingMirror) -> user_mine',
    );

Widget _wrap(Widget child, SchoolViewModel vm) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChangeNotifierProvider<SchoolViewModel>.value(
      value: vm,
      child: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SchoolEditorPage UI', () {
    late SchoolViewModel vm;
    late _MockOfficialRepo officialRepo;
    late InMemoryUserSchoolRepository userRepo;

    setUp(() {
      officialRepo = _MockOfficialRepo([_officialSchool()]);
      userRepo = InMemoryUserSchoolRepository();
      vm = SchoolViewModel(
        loadSchoolsUseCase: LoadSchoolsUseCase(officialRepo, userRepo),
        copySchoolUseCase: CopySchoolUseCase(officialRepo, userRepo),
        saveUserSchoolUseCase: SaveUserSchoolUseCase(userRepo),
      );
    });

    testWidgets('official school renders read-only banner and disabled fields',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SchoolEditorPage(
          args: const SchoolEditorArgs(schoolId: 'jingMirror', mode: 'edit'),
          initialSchool: _officialSchool(),
        ),
        vm,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('official_readonly_banner')), findsOneWidget);
      expect(find.text('这是官方流派,只能查看。若需修改请先复制为我的流派。'),
          findsOneWidget);
      expect(find.byKey(const Key('copy_and_edit_button')), findsOneWidget);

      // Save button must NOT appear for official (readOnly) school.
      expect(find.byKey(const Key('save_button')), findsNothing);

      // Name field is disabled.
      final nameField = tester
          .widget<TextFormField>(find.byKey(const Key('school_name_input')));
      expect(nameField.enabled, isFalse);

      // Epoch fields are all present.
      const epochKeys = [
        'epoch_ancientBase_input',
        'epoch_epochYear_input',
        'epoch_correction_input',
        'epoch_ancientMonthBase_input',
        'epoch_ancientDayBase_input',
        'epoch_ancientHourBase_input',
        'epoch_zhangSui_input',
        'epoch_zhangYue_input',
        'epoch_dayOffset_input',
        'epoch_hourOffset_input',
        'epoch_tropicalYear_input',
      ];
      for (final k in epochKeys) {
        expect(find.byKey(Key(k), skipOffstage: false), findsOneWidget,
            reason: 'missing $k');
      }

      // Algorithm controls (need skipOffstage:false because ListView lazy-builds)
      expect(find.byKey(const Key('palace_formula_dropdown'), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const Key('wenchang_switch'), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const Key('jishen_switch'), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const Key('eight_door_dropdown'), skipOffstage: false),
          findsOneWidget);

      // Preserved metadata summaries
      expect(find.byKey(const Key('deity_ids_summary'), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const Key('chart_configs_summary'), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const Key('deity_configs_summary'), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const Key('private_deities_summary'), skipOffstage: false),
          findsOneWidget);
    });

    testWidgets('user school renders save button and editable fields',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SchoolEditorPage(
          args: const SchoolEditorArgs(schoolId: 'user_mine', mode: 'edit'),
          initialSchool: _userSchool(),
        ),
        vm,
      ));
      await tester.pumpAndSettle();

      // No read-only banner for user school.
      expect(find.byKey(const Key('official_readonly_banner')), findsNothing);
      // Save button visible.
      expect(find.byKey(const Key('save_button')), findsOneWidget);

      // Name field enabled.
      final nameField = tester
          .widget<TextFormField>(find.byKey(const Key('school_name_input')));
      expect(nameField.enabled, isTrue);

      // Lineage shown
      expect(find.textContaining('official(jingMirror) -> user_mine'),
          findsOneWidget);
    });
  });
}

class _MockOfficialRepo implements SchoolRepository {
  final List<TaiYiSchool> _schools;
  _MockOfficialRepo(this._schools);

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async => _schools;

  @override
  Future<TaiYiSchool?> loadSchool(String id) async =>
      _schools.where((s) => s.id == id).cast<TaiYiSchool?>().firstOrNull;

  @override
  Future<List<DeityDefinition>> loadAllDeities() async => <DeityDefinition>[];

  @override
  Future<DeityDefinition?> loadDeity(String id) async => null;

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
