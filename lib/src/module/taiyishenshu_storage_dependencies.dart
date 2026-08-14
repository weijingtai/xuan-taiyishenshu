import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:xuan_time_location/xuan_time_location.dart';

/// Storage ports injected into the taiyishenshu product by the host/assembly.
class TaiyishenshuStorageDependencies {
  const TaiyishenshuStorageDependencies({
    required this.officialSchoolRepo,
    required this.userSchoolRepo,
    required this.deityRepo,
    required this.deityPreferenceRepo,
    required this.recordRepo,
    this.timezoneProvider,
  });

  final SchoolRepository officialSchoolRepo;
  final UserSchoolRepository userSchoolRepo;
  final DeityRepository deityRepo;
  final DeityPreferenceRepository deityPreferenceRepo;
  final TaiyiRecordRepository recordRepo;

  /// 宿主解析的当前时区（用户偏好 > 地点 > 中国默认）。null 时回退 [chinaTimeZoneId]。
  final String Function()? timezoneProvider;
}
