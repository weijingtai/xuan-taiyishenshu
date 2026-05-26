import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'pages/taiyi_pan_page.dart';
import 'theme/taiyi_classic_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 显式启用 Semantics：让 Flutter Web 把 widget tree 的语义节点投射到 DOM。
  // 这是无障碍生产改进，同时也是 Playwright BDD 验收（ZT-25/10）可以稳定按
  // identifier 定位的前置。详见 docs/wjt-Claude/qa/zt-25-playwright-2026-05-26/
  // 下的 SPEC 第 3.1 节。
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

