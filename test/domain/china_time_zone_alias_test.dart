import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:xuan_time_location/xuan_time_location.dart';
import 'package:taiyishenshu/src/module/taiyishenshu_module_manifest.dart';
import 'package:taiyishenshu/src/module/taiyishenshu_storage_dependencies.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

void main() {
  group('产品时区标识 Asia/Beijing', () {
    test('经模块真实入口初始化后，别名可解析且指向 IANA Asia/Shanghai', () {
      // 走模块真实装配入口完成时区库初始化与别名注册（幂等）
      TaiyishenshuModuleManifest.createProviders(_dependencies());

      final loc = tz.getLocation(chinaTimeZoneId);
      expect(loc.name, 'Asia/Shanghai',
          reason: 'Asia/Beijing 必须映射到 Asia/Shanghai');
    });
  });
}

TaiyishenshuStorageDependencies _dependencies() =>
    TaiyishenshuStorageDependencies(
      officialSchoolRepo: _SchoolRepo(),
      userSchoolRepo: _UserSchoolRepo(),
      deityRepo: _DeityRepo(),
      deityPreferenceRepo: _PrefRepo(),
      recordRepo: _RecordRepo(),
    );

class _SchoolRepo implements SchoolRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UserSchoolRepo implements UserSchoolRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DeityRepo implements DeityRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PrefRepo implements DeityPreferenceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordRepo implements TaiyiRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}