import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:taiyishenshu/theme/taiyi_classic_theme.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '太乙神数',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          TaiYiClassicTheme.darkWood.toARGB32(),
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
        textTheme: GoogleFonts.notoSerifKhitanSmallScriptTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: TaiYiClassicTheme.darkWood,
          foregroundColor: TaiYiClassicTheme.paleGold,
        ),
      ),
      home: const TaiYiPanPage(),
    );
  }
}
