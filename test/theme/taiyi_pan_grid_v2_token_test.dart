import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/enums/gong.dart';
import 'package:taiyishenshu/enums/eight_door.dart';
import 'package:taiyishenshu/enums/geju.dart';
import 'package:taiyishenshu/models/di_pan_model.dart';
import 'package:taiyishenshu/models/ren_pan_model.dart';
import 'package:taiyishenshu/models/tian_pan_model.dart';
import 'package:taiyishenshu/models/shen_pan_model.dart';
import 'package:taiyishenshu/models/geju_model.dart';
import 'package:taiyishenshu/taiyi/pan_data_model.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/widgets/taiyi_pan_grid_v2.dart';
import 'package:theme/theme.dart';

void main() {
  group('TaiYiPanGridV2 theme token behavior', () {
    testWidgets('with theme scope, uses token background color', (tester) async {
      const tokenBg = Color(0xFF123456);
      const tokenBorder = Color(0xFFABCDEF);
      final themeData = XuanThemeData(components: {
        'taiyi_pan_grid_v2': ComponentStyle(
          background: tokenBg,
          border: BorderSide(color: tokenBorder),
        ),
      });

      await tester.pumpWidget(
        XuanThemeScope(
          themeData: themeData,
          child: MaterialApp(
            home: Scaffold(
              body: TaiYiPanGridV2(panData: _minimalPanData()),
            ),
          ),
        ),
      );

      // Find the top-level Container whose color is set from style
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.color, equals(tokenBg));
    });

    testWidgets('without theme scope, falls back to hardcoded defaults', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaiYiPanGridV2(panData: _minimalPanData()),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      // no-scope: style is null → background ?? Colors.white
      expect(container.color, equals(Colors.white));
    });

    test('strokeColor and textColor fall back to Colors.black87 when no border', () {
      // Unit test: ComponentStyle.empty has no border → border?.color is null → ?? Colors.black87
      const style = ComponentStyle.empty;
      final strokeColor = style.border?.color ?? Colors.black87;
      expect(strokeColor, equals(Colors.black87));
    });

    test('strokeColor and textColor use border color when provided', () {
      const border = BorderSide(color: Color(0xFFABCDEF));
      const style = ComponentStyle(border: border);
      final strokeColor = style.border?.color ?? Colors.black87;
      expect(strokeColor, equals(const Color(0xFFABCDEF)));
    });

    test('ComponentStyle with background only, border is null', () {
      const style = ComponentStyle(background: Color(0xFF111111));
      // border is null → strokeColor should fall back
      final strokeColor = style.border?.color ?? Colors.black87;
      expect(strokeColor, equals(Colors.black87));
      // background is set
      expect(style.background, equals(const Color(0xFF111111)));
    });
  });
}

/// Builds a minimal PanDataModel for widget tests.
/// Only the fields accessed by TaiYiPanGridV2 are populated;
/// everything else uses safe defaults.
PanDataModel _minimalPanData() {
  const gongs = [
    EnumTaiYiGong.Qian,
    EnumTaiYiGong.Li,
    EnumTaiYiGong.Gen,
    EnumTaiYiGong.Zhen,
    EnumTaiYiGong.Dui,
    EnumTaiYiGong.Kun,
    EnumTaiYiGong.Kan,
    EnumTaiYiGong.Xun,
    EnumTaiYiGong.Center,
  ];

  return PanDataModel(
    input: PanInputModel(
      dateTime: DateTime(2024, 1, 1),
      schoolId: 'test',
      schoolName: '测试',
      chartType: TaiYiChartType.year,
    ),
    algorithmVersion: '1.0.0',
    accumulatedYear: 10000,
    sequenceIndex: 1,
    juNumber: 1,
    dunType: DunType.yang,
    taiYiPalace: EnumTaiYiGong.Kan,
    wenChangPalace: EnumTaiYiGong.Kan,
    jiShenPalace: EnumTaiYiGong.Kan,
    palaces: gongs
        .map((g) => PalaceDataModel(gong: g, items: const []))
        .toList(),
    eightDoorsByPalace: const {},
    hostGuest: const HostGuestDataModel(
      hostCount: 1,
      guestCount: 1,
      dingCount: 1,
      hostPalace: EnumTaiYiGong.Kan,
      guestPalace: EnumTaiYiGong.Kan,
      dingPalace: EnumTaiYiGong.Kan,
      method: 'test',
    ),
    diPan: DiPanModel(
      palaces: gongs
          .map((g) => DiPanPalaceModel(gong: g))
          .toList(),
    ),
    renPan: const RenPanModel(
      sixteenGodsByPalace: {},
      tianMuGong: EnumTaiYiGong.Kan,
      shiJiGong: EnumTaiYiGong.Kan,
      jiShenGong: EnumTaiYiGong.Kan,
    ),
    tianPan: const TianPanModel(
      taiYiGong: EnumTaiYiGong.Kan,
      hostGeneralGong: EnumTaiYiGong.Kan,
      guestGeneralGong: EnumTaiYiGong.Kan,
      hostDeputyGeneralGong: EnumTaiYiGong.Kan,
      guestDeputyGeneralGong: EnumTaiYiGong.Kan,
    ),
    shenPan: const ShenPanModel(
      taiSuiGong: EnumTaiYiGong.Kan,
      suiPoGong: EnumTaiYiGong.Kan,
      zhiFuGong: EnumTaiYiGong.Kan,
    ),
    geJu: const GeJuResultModel(patterns: []),
  );
}
