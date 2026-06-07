import 'package:meta/meta.dart';

import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// 测试专用的内存星神偏好 Repository。
///
/// **严禁在生产装配 (TaiYiDataAssembly) 中引用本类。**
/// 生产入口应使用 SharedPreferencesDeityPreferenceRepository。
@visibleForTesting
class InMemoryDeityPreferenceRepository implements DeityPreferenceRepository {
  final Map<String, bool> _enabledMap = {};

  @override
  Future<bool> isEnabled(String deityId) async {
    return _enabledMap[deityId] ?? true; // default enabled
  }

  @override
  Future<void> setEnabled(String deityId, bool enabled) async {
    _enabledMap[deityId] = enabled;
  }

  @override
  Future<Map<String, bool>> loadEnabledMap() async {
    return Map<String, bool>.from(_enabledMap);
  }
}
