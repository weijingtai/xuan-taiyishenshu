/// Re-export adapters for test convenience.
///
/// Pure adapters from taiyishenshu/src/adapters/.
/// SharedPreferenceAdapter from test/taiyi/fakes/ (storage-dependent, lives there
/// to keep main lib/ free of persistence_ dependencies).
library;

export 'package:taiyishenshu/src/adapters/taiyi_contract_adapters.dart';
export 'shared_preference_adapter.dart';
