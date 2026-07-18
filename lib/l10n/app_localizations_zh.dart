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
}
