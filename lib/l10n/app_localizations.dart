import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('zh')];

  /// No description provided for @taiyishenshu.
  ///
  /// In zh, this message translates to:
  /// **'太乙神数'**
  String get taiyishenshu;

  /// No description provided for @noOfficialDeityLoaded.
  ///
  /// In zh, this message translates to:
  /// **'未载入官方星神'**
  String get noOfficialDeityLoaded;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @deleteDeity.
  ///
  /// In zh, this message translates to:
  /// **'删除星神'**
  String get deleteDeity;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @saveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'保存成功'**
  String get saveSuccess;

  /// No description provided for @copiedAsMyDeity.
  ///
  /// In zh, this message translates to:
  /// **'已复制为我的星神：{name}'**
  String copiedAsMyDeity(String name);

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @copyAndEdit.
  ///
  /// In zh, this message translates to:
  /// **'复制并编辑'**
  String get copyAndEdit;

  /// No description provided for @mySchoolsEditable.
  ///
  /// In zh, this message translates to:
  /// **'我的流派 (可编辑)'**
  String get mySchoolsEditable;

  /// No description provided for @switchFailed.
  ///
  /// In zh, this message translates to:
  /// **'切换失败: {error}'**
  String switchFailed(String error);

  /// No description provided for @confirmCopy.
  ///
  /// In zh, this message translates to:
  /// **'确认复制'**
  String get confirmCopy;

  /// No description provided for @copy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copy;

  /// No description provided for @copyFailed.
  ///
  /// In zh, this message translates to:
  /// **'复制失败: {error}'**
  String copyFailed(String error);

  /// No description provided for @schoolDetailAndLineage.
  ///
  /// In zh, this message translates to:
  /// **'{name} 详情与传承链'**
  String schoolDetailAndLineage(String name);

  /// No description provided for @viewSchoolDetailAndLineage.
  ///
  /// In zh, this message translates to:
  /// **'查看 {name} 详情与传承链'**
  String viewSchoolDetailAndLineage(String name);

  /// No description provided for @detailAndLineage.
  ///
  /// In zh, this message translates to:
  /// **'详情与传承链'**
  String get detailAndLineage;

  /// No description provided for @copySchoolAsUser.
  ///
  /// In zh, this message translates to:
  /// **'复制 {name} 为用户流派'**
  String copySchoolAsUser(String name);

  /// No description provided for @copyAsUserSchool.
  ///
  /// In zh, this message translates to:
  /// **'复制为用户流派'**
  String get copyAsUserSchool;

  /// No description provided for @editSchool.
  ///
  /// In zh, this message translates to:
  /// **'编辑 {name}'**
  String editSchool(String name);

  /// No description provided for @editUserSchool.
  ///
  /// In zh, this message translates to:
  /// **'编辑用户流派'**
  String get editUserSchool;

  /// No description provided for @copiedAsNewName.
  ///
  /// In zh, this message translates to:
  /// **'已复制为「{name}」,可以开始编辑'**
  String copiedAsNewName(String name);

  /// No description provided for @schoolEditorTitle.
  ///
  /// In zh, this message translates to:
  /// **'流派编辑器'**
  String get schoolEditorTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
