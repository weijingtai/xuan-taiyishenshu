import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistence_assets/taiyishenshu/taiyishenshu_assets.dart';
import 'package:persistence_drift/taiyishenshu/taiyishenshu_drift.dart';
import 'package:persistence_preferences/taiyishenshu/taiyishenshu_preferences.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';

/// Constructs the three concrete backends and builds an injectable
/// [TaiYiDataAssembly]. This is the P2 host seam — backend construction
/// lives here, NOT inside product lib/.
Future<TaiYiDataAssembly> buildTaiYiAssembly() async {
  final prefs = await SharedPreferences.getInstance();
  final db = TaiYiDatabase();

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
    ],
  );

  // DriftUserRepository implements UserSchoolRepository + DeityRepository
  final driftRepo = DriftUserRepository(db);
  final preferenceRepo = SharedPreferencesDeityPreferenceRepository(prefs);

  return TaiYiDataAssembly(
    officialRepo: officialRepo,
    userRepo: driftRepo,
    deityRepo: driftRepo,
    preferenceRepo: preferenceRepo,
  );
}
