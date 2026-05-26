// ZT-25/10 Playwright E2E entry — 用根项目 lib/main.dart 的完整 MyApp 在浏览器跑全链路。
// 通过 `flutter build web -t lib/main_e2e.dart` 构建。
// 仅用于 BDD 验收；example/lib/main.dart 仍是 DeityDialogDemo。

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:taiyishenshu/theme/taiyi_classic_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '太乙神数',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          TaiYiClassicTheme.darkWood.value,
          const {
            50: TaiYiClassicTheme.paleGold,
            100: TaiYiClassicTheme.lightWood,
            200: TaiYiClassicTheme.earthYellow,
            300: TaiYiClassicTheme.mediumWood,
            400: TaiYiClassicTheme.darkWood,
            500: TaiYiClassicTheme.darkWood,
            600: TaiYiClassicTheme.darkWood,
            700: TaiYiClassicTheme.inkBlack,
            800: TaiYiClassicTheme.inkBlack,
            900: TaiYiClassicTheme.inkBlack,
          },
        ),
        scaffoldBackgroundColor: TaiYiClassicTheme.ricePaper,
        textTheme: Typography.blackMountainView,
        appBarTheme: const AppBarTheme(
          backgroundColor: TaiYiClassicTheme.darkWood,
          foregroundColor: TaiYiClassicTheme.paleGold,
        ),
      ),
      home: const TaiYiPanPage(),
    );
  }
}
