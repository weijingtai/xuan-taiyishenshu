import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:xuan_gua_core/xuan_gua_core.dart';
import '../core/ming_gua_engine.dart';
import 'package:taiyishenshu/gua_core/gua_sequence.dart';

/// Shared [RequestContext] for minggua usecase calls.
final _ctx = RequestContext(scopeUid: 'local-anonymous');

/// Unwrap a [Result] or throw the error.
T _unwrap<T>(Result<T> result) => switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };

/// 计算命卦 UseCase。
/// 注入 MingGuaRepository,加载配置后调用引擎计算。
class CalculateMingGuaUseCase {
  final MingGuaRepository repository;

  CalculateMingGuaUseCase({required this.repository});

  /// 计算命卦。[configId] 为空则使用默认配置 'tongZong'。
  Future<MingGuaResultContract> call({required int year, String? configId}) async {
    final id = configId ?? 'tongZong';
    final config = _unwrap(await repository.get(id, _ctx));
    if (config == null) {
      throw StateError('MingGua config not found: $id');
    }

    final engine = MingGuaEngine(
      guaSequence: config.guaSequence.map(Enum64Gua.fromName).toList(),
      epochBase: config.epochBase,
    );

    return engine.calculate(year: year);
  }
}
