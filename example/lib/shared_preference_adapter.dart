import 'package:persistence_preferences/taiyishenshu/taiyishenshu_preferences.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// Wraps a [SharedPreferencesDeityPreferenceRepository] into a
/// product-typed [DeityPreferenceRepository].
///
/// This adapter lives in example/ because it depends on persistence_preferences,
/// which is a storage implementation. The main lib/ adapters are pure Dart
/// contract-to-product mappings only.
class SharedPreferenceAdapter implements DeityPreferenceRepository {
  final SharedPreferencesDeityPreferenceRepository _inner;
  SharedPreferenceAdapter(this._inner);

  @override
  Future<bool> isEnabled(String deityId) => _inner.isEnabled(deityId);

  @override
  Future<void> setEnabled(String deityId, bool enabled) =>
      _inner.setEnabled(deityId, enabled);

  @override
  Future<Map<String, bool>> loadEnabledMap() => _inner.loadEnabledMap();
}
