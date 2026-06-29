import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistence_assets/taiyishenshu/taiyishenshu_assets.dart';
import 'package:persistence_drift/taiyishenshu/taiyishenshu_drift.dart';
import 'package:persistence_preferences/taiyishenshu/taiyishenshu_preferences.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';
import 'package:host_adapter_taiyishenshu/host_adapter_taiyishenshu.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_preferences/persistence_preferences.dart';
import 'package:drift/native.dart';
import 'package:persistence_drift/taiyishenshu/taiyishenshu_module_registry.dart';

/// Constructs the three concrete backends and builds an injectable
/// [TaiYiDataAssembly]. This is the P2 host seam — backend construction
/// lives here, NOT inside product lib/.
///
/// Contract repos are wrapped into product-typed ports via adapters.
Future<TaiYiDataAssembly> buildTaiYiAssembly() async {
  final prefs = await SharedPreferences.getInstance();
  final db = TaiYiDatabase();

  // Create contract-typed repos (from persistence packages)
  final officialRepo = OfficialJsonSchoolRepository(
    schoolIds: const ['jingMirror', 'tongZong', 'jiCheng'],
    deityIds: const [
      'taiYi', 'zhuDaJiang', 'keDaJiang', 'zhuCanJiang', 'keCanJiang',
      'dingDaJiang', 'dingCanJiang', 'junJi', 'chenJi', 'minJi',
      'wuFu', 'daYou', 'xiaoYou', 'feiFu', 'siShen',
      'tianYiStar', 'diYi', 'zhiFuStar', 'yangJiu', 'baiLiu',
      'taiSui', 'suiPo', 'zhiFu', 'heShen',
      'qingLong', 'zhuQue', 'baiHu', 'xuanWu', 'fengBo', 'yuShi',
      'qingLongQi', 'heiQi', 'chiQi', 'guiShenZhiShi',
      'wenChang', 'jiShen', 'shiJi',
      'tianHuang', 'ziWei', 'sheTi', 'xuanYuan', 'zhaoYao',
      'tianFu', 'xianChi', 'jiangGong', 'mingTang', 'yuTang',
    ],
  );

  // DriftUserRepository implements UserSchoolRepository + DeityRepository
  final driftRepo = DriftUserRepository(db);
  final preferenceRepo = SharedPreferencesDeityPreferenceRepository(prefs);

  final newDb = PersistenceDriftDatabase(NativeDatabase.memory());
  final sessionRepo = PreferencesAccountSessionRepository(prefs);
  final accountDb = AccountDatabase(NativeDatabase.memory());
  final identityLinkRepo = DriftAccountIdentityLinkRepository(accountDb);
  
  final bootstrapStore = DriftScopeBootstrapStore(newDb);
  final ledger = DriftScopeLedger(db: newDb, bootstrapStore: bootstrapStore);
  final resolver = ScopeResolver(
    sessionRepository: sessionRepo,
    identityLinkRepository: identityLinkRepo,
    ledger: ledger,
  );
  final resolvedScope = await resolver.resolve();
  final scopeUid = resolvedScope.scopeUid;

  final ds = DriftRecordDataSource(newDb, scopeUid: scopeUid);
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([TaiyishenshuModuleRegistry.codec()]));
  final recordBackedRepository = TaiyishenshuModuleRegistry.repository(store: store);

  // Wrap contract repos into product-typed ports
  final productOfficial = ContractOfficialSchoolAdapter(officialRepo);
  final productUser = ContractUserSchoolAdapter(driftRepo);
  final productDeity = ContractDeityAdapter(driftRepo);
  final productPreference = SharedPreferenceAdapter(preferenceRepo);

  return TaiYiDataAssembly(
    officialRepo: productOfficial,
    userRepo: productUser,
    deityRepo: productDeity,
    preferenceRepo: productPreference,
    recordRepo: recordBackedRepository,
  );
}
