import 'package:flutter/material.dart';

import 'pages/taiyi_pan_page.dart';
import 'theme/taiyi_classic_theme.dart';

void main() => runApp(const MyApp());

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

