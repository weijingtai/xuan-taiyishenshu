import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taiyishenshu/theme/taiyi_classic_theme.dart';
import 'deity_dialog_demo.dart';
import 'taiyi_host.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '太乙神数 - 星神管理演示',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: TaiYiClassicTheme.ricePaper,
        textTheme: GoogleFonts.notoSerifTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: TaiYiClassicTheme.darkWood,
          foregroundColor: TaiYiClassicTheme.paleGold,
        ),
      ),
      home: const DeityDialogDemo(),
    );
  }
}
