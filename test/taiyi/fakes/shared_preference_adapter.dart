import 'package:persistence_preferences/taiyishenshu/taiyishenshu_preferences.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// Wraps a [SharedPreferencesDeityPreferenceRepository] into a
/// product-typed [DeityPreferenceRepository].
///
/// This adapter depends on persistence_preferences (a storage implementation),
/// so it lives outside the main lib/ to keep taiyishenshu's storage decoupling.
/// Tests import it via test/taiyi/fakes/taiyi_contract_adapters.dart.
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
