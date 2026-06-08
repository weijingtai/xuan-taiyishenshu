import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/taiyishenshu/taiyishenshu_assets.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'dart:io';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:persistence_preferences/taiyishenshu/taiyishenshu_preferences.dart';
import 'package:persistence_drift/taiyishenshu/taiyishenshu_drift.dart';
import 'package:host_adapter_taiyishenshu/host_adapter_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getLibraryPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getApplicationDocumentsPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getExternalStoragePath() async => Directory.systemTemp.path;
  @override
  Future<List<String>?> getExternalCachePaths() async => [Directory.systemTemp.path];
  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async => [Directory.systemTemp.path];
  @override
  Future<String?> getDownloadsPath() async => Directory.systemTemp.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();

  group('AC2: OfficialJsonSchoolRepository Boundary', () {


    final repo = OfficialJsonSchoolRepository(schoolIds: [], deityIds: []);

    test('saveSchool should throw UnsupportedError', () {
      expect(
        () => repo.saveSchool(const TaiYiSchool(
          id: 'test',
          name: 'test',
          epoch: SchoolEpochConfig(ancientBase: 0, epochYear: 0),
        ).toContract()),
        throwsUnsupportedError,
      );
    });

    test('saveDeity should throw UnsupportedError', () {
      expect(
        () => repo.saveDeity(const DeityDefinition(
          id: 'test',
          name: 'test',
          layer: EnumDeityLayer.tianPan,
          algorithm: DeityAlgorithmSpec(templateId: AlgorithmTemplateId.fixedPosition, params: {}),
        ).toContract()),
        throwsUnsupportedError,
      );
    });

    test('deleteSchool should throw UnsupportedError', () {
      expect(
        () => repo.deleteSchool('test'),
        throwsUnsupportedError,
      );
    });
  });

  group('AC3 & AC4: Integrated Repository Persistence', () {
    test('DriftUserRepository should support true persistence', () async {
      // 1. Save data in first instance
      final db1 = TaiYiDatabase(); 
      final repo1 = DriftUserRepository(db1);

      final school = const TaiYiSchool(
        id: 'persistent_user_school',
        name: 'Persistent User School',
        epoch: SchoolEpochConfig(ancientBase: 100, epochYear: 2000),
        source: 'user',
      );

      await repo1.saveSchool(school.toContract());
      await db1.close();

      // 2. Instantiate a NEW database and repository
      // They should share the same file because getApplicationSupportPath is mocked to systemTemp
      final db2 = TaiYiDatabase();
      final repo2 = DriftUserRepository(db2);
      
      final schools = await repo2.loadAllSchools();
      expect(schools.any((s) => s.id == 'persistent_user_school'), isTrue);

      // Cleanup
      await repo2.deleteSchool('persistent_user_school');
      await db2.close();
    });

    test('SharedPreferencesDeityPreferenceRepository should support true persistence', () async {
      SharedPreferences.setMockInitialValues({});
      
      // 1. Save in first repository instance
      final prefs1 = await SharedPreferences.getInstance();
      final repo1 = SharedPreferencesDeityPreferenceRepository(prefs1);
      await repo1.setEnabled('taiYi_persistence', false);

      // 2. Instantiate a NEW repository instance (sharing the same underlying mock storage)
      final prefs2 = await SharedPreferences.getInstance();
      final repo2 = SharedPreferencesDeityPreferenceRepository(prefs2);
      
      expect(await repo2.isEnabled('taiYi_persistence'), isFalse);

      await repo2.setEnabled('taiYi_persistence', true);
      expect(await repo1.isEnabled('taiYi_persistence'), isTrue);
    });
  });
}
