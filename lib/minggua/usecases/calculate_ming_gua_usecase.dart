import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import '../core/ming_gua_engine.dart';
import '../core/gua_sequence.dart';

/// 计算命卦 UseCase。
/// 注入 MingGuaRepository,加载配置后调用引擎计算。
class CalculateMingGuaUseCase {
  final MingGuaRepository repository;

  CalculateMingGuaUseCase({required this.repository});

  /// 计算命卦。[configId] 为空则使用默认配置 'tongZong'。
  Future<MingGuaResultContract> call({required int year, String? configId}) async {
    final id = configId ?? 'tongZong';
    final config = await repository.loadConfig(id);
    if (config == null) {
      throw StateError('MingGua config not found: $id');
    }

    final engine = MingGuaEngine(
      guaSequence: config.guaSequence,
      epochBase: config.epochBase,
    );

    return engine.calculate(year: year);
  }
}
