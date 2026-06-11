import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:xuan_gua_core/xuan_gua_core.dart';
import 'package:taiyishenshu/minggua/core/ming_gua_engine.dart';
import 'package:taiyishenshu/gua_core/gua_sequence.dart';
import 'package:taiyishenshu/minggua/usecases/calculate_ming_gua_usecase.dart';
import 'package:taiyishenshu/minggua/viewmodels/ming_gua_view_model.dart';

// ---------------------------------------------------------------------------
// Inline mock for MingGuaRepository (following the pattern from
// test/taiyi/usecases/usecases_test.dart).
// ---------------------------------------------------------------------------
class MockMingGuaRepository implements MingGuaRepository {
  final bool throwOnLoad;

  MockMingGuaRepository({this.throwOnLoad = false});

  static final _defaultConfig = MingGuaConfigContract(
    id: 'tongZong',
    name: '统宗',
    epochBase: 10153917,
    guaSequence: kTaiYiGuaSequence.map((g) => g.name).toList(),
    source: 'official',
  );

  @override
  Future<MingGuaConfigContract?> loadConfig(String id) async {
    if (throwOnLoad) throw Exception('config load failed');
    if (id == 'tongZong') return _defaultConfig;
    return null;
  }

  @override
  Future<List<MingGuaConfigContract>> loadAllConfigs() async {
    if (throwOnLoad) throw Exception('config load failed');
    return [_defaultConfig];
  }

  @override
  Future<void> saveConfig(MingGuaConfigContract config) async {
    throw UnsupportedError('read-only mock');
  }

  @override
  Future<void> deleteConfig(String id) async {
    throw UnsupportedError('read-only mock');
  }
}

void main() {
  group('ACT-006: UseCase + ViewModel', () {
    test('UseCase returns valid result', () async {
      final mockRepo = MockMingGuaRepository();
      final usecase = CalculateMingGuaUseCase(repository: mockRepo);
      final result = await usecase(year: 2026);
      expect(result.accumulatedYear, 10155943);
    });

    test('ViewModel notifies on calculate', () async {
      final mockRepo = MockMingGuaRepository();
      final usecase = CalculateMingGuaUseCase(repository: mockRepo);
      final vm = MingGuaViewModel(calculateUseCase: usecase);
      var notified = false;
      vm.addListener(() {
        notified = true;
      });
      await vm.calculate(year: 2026);
      expect(notified, true);
      expect(vm.result, isNotNull);
      expect(vm.isLoading, false);
    });

    test('ViewModel error state on invalid config', () async {
      final mockRepo = MockMingGuaRepository(throwOnLoad: true);
      final usecase = CalculateMingGuaUseCase(repository: mockRepo);
      final vm = MingGuaViewModel(calculateUseCase: usecase);
      await vm.calculate(year: 2026, configId: 'nonexistent');
      expect(vm.error, isNotNull);
    });
  });
}
