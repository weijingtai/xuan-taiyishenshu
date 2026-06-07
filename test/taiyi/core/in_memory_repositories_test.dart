import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import '../fakes/in_memory_user_school_repository.dart';
import '../fakes/in_memory_user_deity_repository.dart';
import '../fakes/in_memory_deity_preference_repository.dart';

void main() {
  group('InMemoryUserSchoolRepository', () {
    late InMemoryUserSchoolRepository repo;

    setUp(() {
      repo = InMemoryUserSchoolRepository();
    });

    test('initially empty', () async {
      final schools = await repo.loadUserSchools();
      expect(schools, isEmpty);
    });

    test('save and load', () async {
      const school = TaiYiSchool(
        id: 'user1',
        name: '用户派',
        epoch: SchoolEpochConfig(ancientBase: 100, epochYear: 200),
        source: 'user',
      );
      await repo.saveUserSchool(school);
      final loaded = await repo.loadSchool('user1');
      expect(loaded, isNotNull);
      expect(loaded!.name, '用户派');
    });

    test('delete', () async {
      const school = TaiYiSchool(
        id: 'user1',
        name: '用户派',
        epoch: SchoolEpochConfig(ancientBase: 100, epochYear: 200),
      );
      await repo.saveUserSchool(school);
      await repo.deleteUserSchool('user1');
      final loaded = await repo.loadSchool('user1');
      expect(loaded, isNull);
    });

    test('loadUserSchools returns all', () async {
      await repo.saveUserSchool(const TaiYiSchool(
        id: 'a', name: 'A',
        epoch: SchoolEpochConfig(ancientBase: 0, epochYear: 0),
      ));
      await repo.saveUserSchool(const TaiYiSchool(
        id: 'b', name: 'B',
        epoch: SchoolEpochConfig(ancientBase: 0, epochYear: 0),
      ));
      final all = await repo.loadUserSchools();
      expect(all.length, 2);
    });
  });

  group('InMemoryUserDeityRepository', () {
    late InMemoryUserDeityRepository repo;

    setUp(() {
      repo = InMemoryUserDeityRepository();
    });

    test('initially empty', () async {
      final deities = await repo.loadUserDeities();
      expect(deities, isEmpty);
    });

    test('save and load', () async {
      const deity = DeityDefinition(
        id: 'custom_taiYi',
        name: '自定义太乙',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.steppedCycle,
        ),
        source: 'user',
      );
      await repo.saveUserDeity(deity);
      final loaded = await repo.loadDeity('custom_taiYi');
      expect(loaded, isNotNull);
      expect(loaded!.name, '自定义太乙');
    });

    test('delete', () async {
      const deity = DeityDefinition(
        id: 'custom_taiYi',
        name: '自定义太乙',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.steppedCycle,
        ),
      );
      await repo.saveUserDeity(deity);
      await repo.deleteUserDeity('custom_taiYi');
      expect(await repo.loadDeity('custom_taiYi'), isNull);
    });
  });

  group('InMemoryDeityPreferenceRepository', () {
    late InMemoryDeityPreferenceRepository repo;

    setUp(() {
      repo = InMemoryDeityPreferenceRepository();
    });

    test('default is enabled', () async {
      expect(await repo.isEnabled('anyDeity'), true);
    });

    test('setEnabled and isEnabled', () async {
      await repo.setEnabled('taiYi', false);
      expect(await repo.isEnabled('taiYi'), false);
      await repo.setEnabled('taiYi', true);
      expect(await repo.isEnabled('taiYi'), true);
    });

    test('loadEnabledMap returns current state', () async {
      await repo.setEnabled('a', false);
      await repo.setEnabled('b', true);
      final map = await repo.loadEnabledMap();
      expect(map['a'], false);
      expect(map['b'], true);
    });
  });
}
