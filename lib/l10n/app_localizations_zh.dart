// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get taiyishenshu => '太乙神数';

  @override
  String get noOfficialDeityLoaded => '未载入官方星神';

  @override
  String get close => '关闭';

  @override
  String get deleteDeity => '删除星神';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get saveSuccess => '保存成功';

  @override
  String copiedAsMyDeity(String name) {
    return '已复制为我的星神：$name';
  }

  @override
  String get save => '保存';

  @override
  String get copyAndEdit => '复制并编辑';

  @override
  String get mySchoolsEditable => '我的流派 (可编辑)';

  @override
  String switchFailed(String error) {
    return '切换失败: $error';
  }

  @override
  String get confirmCopy => '确认复制';

  @override
  String get copy => '复制';

  @override
  String copyFailed(String error) {
    return '复制失败: $error';
  }

  @override
  String schoolDetailAndLineage(String name) {
    return '$name 详情与传承链';
  }

  @override
  String viewSchoolDetailAndLineage(String name) {
    return '查看 $name 详情与传承链';
  }

  @override
  String get detailAndLineage => '详情与传承链';

  @override
  String copySchoolAsUser(String name) {
    return '复制 $name 为用户流派';
  }

  @override
  String get copyAsUserSchool => '复制为用户流派';

  @override
  String editSchool(String name) {
    return '编辑 $name';
  }

  @override
  String get editUserSchool => '编辑用户流派';
}
