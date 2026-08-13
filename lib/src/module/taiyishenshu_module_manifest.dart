import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart'
    as contract;

import 'taiyishenshu_storage_dependencies.dart';
import '../../taiyi/taiyi_assembly.dart';
import '../../taiyi/core/school_repository.dart' as product;
import '../../controllers/taiyi_pan_controller.dart';
import '../../domain/pipeline/taiyi_pipeline_executor.dart';
import '../adapters/taiyi_contract_adapters.dart';

/// Wraps contract-typed [contract.DeityPreferenceRepository] into product-typed
/// [product.DeityPreferenceRepository].
class _ContractDeityPreferenceAdapter implements product.DeityPreferenceRepository {
  final contract.DeityPreferenceRepository _inner;
  _ContractDeityPreferenceAdapter(this._inner);

  @override
  Future<bool> isEnabled(String deityId) => _inner.isEnabled(deityId);

  @override
  Future<void> setEnabled(String deityId, bool enabled) =>
      _inner.setEnabled(deityId, enabled);

  @override
  Future<Map<String, bool>> loadEnabledMap() => _inner.loadEnabledMap();
}

final class TaiyishenshuModuleManifest {
  const TaiyishenshuModuleManifest._();

  static const String id = 'taiyishenshu';
  static const String displayNameKey = 'module_taiyishenshu_name';
  static const String version = '0.1.0';
  static const String minShellVersion = '0.1.0-a3';

  static List<SingleChildWidget> createProviders(
    TaiyishenshuStorageDependencies deps,
  ) {
    final assembly = TaiYiDataAssembly(
      officialRepo: ContractOfficialSchoolAdapter(deps.officialSchoolRepo),
      userRepo: ContractUserSchoolAdapter(deps.userSchoolRepo),
      deityRepo: ContractDeityAdapter(deps.deityRepo),
      preferenceRepo: _ContractDeityPreferenceAdapter(deps.deityPreferenceRepo),
      recordRepo: deps.recordRepo,
    );
    return [
      Provider<TaiYiDataAssembly>.value(value: assembly),
      ChangeNotifierProvider<TaiYiPanController>(
        create: (_) => TaiYiPanController(
          assembly: assembly,
          pipelineExecutor: TaiyiPipelineExecutor(),
        ),
      ),
    ];
  }
}
