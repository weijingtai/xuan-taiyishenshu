import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/usecases/load_schools_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/save_user_school_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/copy_school_usecase.dart';
import 'package:taiyishenshu/taiyi/data/in_memory_user_school_repository.dart';
import 'package:taiyishenshu/taiyi/viewmodels/school_view_model.dart';

class MockOfficialSchoolRepo implements SchoolRepository {
  final List<TaiYiSchool> schools;
  final List<DeityDefinition> deities;

  MockOfficialSchoolRepo({this.schools = const [], this.deities = const []});

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async => schools;
  @override
  Future<TaiYiSchool?> loadSchool(String id) async =>
      schools.where((s) => s.id == id).firstOrNull;
  @override
  Future<List<DeityDefinition>> loadAllDeities() async => deities;
  @override
  Future<DeityDefinition?> loadDeity(String id) async =>
      deities.where((d) => d.id == id).firstOrNull;
  @override
  Future<void> saveSchool(TaiYiSchool school) =>
      throw UnsupportedError('read-only');
  @override
  Future<void> saveDeity(DeityDefinition deity) =>
      throw UnsupportedError('read-only');
  @override
  Future<void> deleteSchool(String id) =>
      throw UnsupportedError('read-only');
  @override
  Future<void> deleteDeity(String id) =>
      throw UnsupportedError('read-only');
}

const _epoch = SchoolEpochConfig(ancientBase: 100, epochYear: 200);
const _officialSchool = TaiYiSchool(
  id: 'jingMirror',
  name: '金镜派',
  epoch: _epoch,
  source: 'official',
);

void main() {
  group('SchoolViewModel', () {
    late SchoolViewModel viewModel;
    late InMemoryUserSchoolRepository userRepo;

    setUp(() {
      final officialRepo = MockOfficialSchoolRepo(schools: [_officialSchool]);
      userRepo = InMemoryUserSchoolRepository();

      viewModel = SchoolViewModel(
        loadSchoolsUseCase: LoadSchoolsUseCase(officialRepo, userRepo),
        copySchoolUseCase: CopySchoolUseCase(officialRepo, userRepo),
        saveUserSchoolUseCase: SaveUserSchoolUseCase(userRepo),
      );
    });

    test('loadSchools populates the schools list', () async {
      expect(viewModel.schools, isEmpty);
      expect(viewModel.isLoading, isFalse);

      await viewModel.loadSchools();

      expect(viewModel.schools, isNotEmpty);
      expect(viewModel.schools.first.id, 'jingMirror');
    });

    test('selectSchool updates the current school', () async {
      await viewModel.loadSchools();
      
      expect(viewModel.currentSchool, isNull);
      
      viewModel.selectSchool('jingMirror');
      
      expect(viewModel.currentSchool?.id, 'jingMirror');
    });

    test('copySchool creates a new user school and reloads', () async {
      await viewModel.loadSchools();
      
      await viewModel.copySchool(
        sourceId: 'jingMirror',
        newId: 'user_jm',
        newName: '我的金镜派',
      );

      expect(viewModel.schools.length, 2);
      expect(viewModel.schools.any((s) => s.id == 'user_jm'), isTrue);
    });
  });
}
