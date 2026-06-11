import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/minggua/repository/ming_gua_repository_impl.dart';

void main() {
  group('ACT-005: Repository 具体实现', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('OfficialMingGuaRepository.saveConfig throws UnsupportedError', () {
      final repo = OfficialMingGuaRepository();
      expect(
        () => repo.saveConfig(MingGuaConfigContract(
          id: 'x',
          name: 'x',
          epochBase: 0,
          guaSequence: [],
        )),
        throwsUnsupportedError,
      );
    });

    test('UserMingGuaRepository CRUD roundtrip', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = UserMingGuaRepository();
      final cfg = MingGuaConfigContract(
        id: 'test',
        name: '测试',
        epochBase: 100,
        guaSequence: List.generate(64, (i) => '卦$i'),
      );
      await repo.saveConfig(cfg);
      final loaded = await repo.loadConfig('test');
      expect(loaded?.id, 'test');
      expect(loaded?.epochBase, 100);
      await repo.deleteConfig('test');
      final deleted = await repo.loadConfig('test');
      expect(deleted, null);
    });

    test('MergedMingGuaRepository user overrides official', () async {
      // Setup: official repo with a config, user repo with same id but different name
      SharedPreferences.setMockInitialValues({});
      final official = OfficialMingGuaRepository();
      final user = UserMingGuaRepository();
      final merged = MergedMingGuaRepository(official: official, user: user);

      // Save a user config that would override official
      final userCfg = MingGuaConfigContract(
        id: 'tongZong',
        name: '用户自定义统宗',
        epochBase: 99999,
        guaSequence: List.generate(64, (i) => '卦$i'),
      );
      await merged.saveConfig(userCfg);
      final loaded = await merged.loadConfig('tongZong');
      // User version should take precedence
      expect(loaded?.name, '用户自定义统宗');
      expect(loaded?.epochBase, 99999);
    });
  });
}
