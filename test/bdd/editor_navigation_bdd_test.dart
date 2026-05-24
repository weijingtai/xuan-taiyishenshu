import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:taiyishenshu/pages/entity_editor_page.dart';
import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';


import 'package:google_fonts/google_fonts.dart';

class MockAssetBundle extends Fake implements AssetBundle {
  final Map<String, String> assets;
  MockAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) return assets[key]!;
    if (key.contains('AssetManifest')) return '{}';
    if (key.contains('FontManifest')) return '[]';
    return '{}';
  }

  @override
  Future<ByteData> load(String key) async {
    if (assets.containsKey(key)) {
      return ByteData.view(Uint8List.fromList(utf8.encode(assets[key]!)).buffer);
    }
    if (key.contains('AssetManifest')) return ByteData(0);
    return ByteData(0);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final Map<String, String> mockAssets = {};

  setUpAll(() {
    final schoolIds = ['jing-mirror'];
    for (final id in schoolIds) {
      mockAssets['assets/schools/jingMirror.json'] =
          File('assets/schools/$id.json').readAsStringSync();
    }
    final deityIds = [
      'tai-yi', 'zhu-da-jiang', 'ke-da-jiang', 'zhu-can-jiang', 'ke-can-jiang',
      'ding-da-jiang', 'ding-can-jiang', 'jun-ji', 'chen-ji', 'min-ji',
      'wu-fu', 'da-you', 'xiao-you', 'fei-fu', 'si-shen',
      'tian-yi-star', 'di-yi', 'zhi-fu-star', 'yang-jiu', 'bai-liu',
      'tai-sui', 'sui-po', 'zhi-fu', 'he-shen',
      'qing-long', 'zhu-que', 'bai-hu', 'xuan-wu', 'feng-bo', 'yu-shi',
      'qing-long-qi', 'hei-qi', 'chi-qi', 'gui-shen-zhi-shi',
      'wen-chang', 'ji-shen', 'shi-ji',
    ];
    for (final id in deityIds) {
      final parts = id.split('-');
      String camelId = parts[0];
      for (int i = 1; i < parts.length; i++) {
        camelId += parts[i][0].toUpperCase() + parts[i].substring(1);
      }
      mockAssets['assets/deities/$camelId.json'] = 
          File('assets/deities/$id.json').readAsStringSync();
    }
  });

  group('Full Management System BDD', () {
    testWidgets('Given user in Deity Dialog, When long pressing a deity, Then navigate to Editor', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;

      final bundle = MockAssetBundle(mockAssets);
      final assembly = TaiYiDataAssembly(bundle: bundle);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      await tester.pumpWidget(MaterialApp(home: TaiYiPanPage(controller: controller)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      final deityChip = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('太乙'),
      ).first;
      
      await tester.longPress(deityChip);
      await tester.pumpAndSettle();

      expect(find.text('星神编辑器'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('Given School Editor, When saving new school, Then it appears in selector bar', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;

      final bundle = MockAssetBundle(mockAssets);
      final assembly = TaiYiDataAssembly(bundle: bundle);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();
      
      await tester.pumpWidget(MaterialApp(home: TaiYiPanPage(controller: controller)));
      await tester.pumpAndSettle();


      // Click add school
      final addBtn = find.byTooltip('新建流派');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('流派编辑器'), findsOneWidget);

      // Enter name
      await tester.enterText(find.widgetWithText(TextField, '名称'), '自定义流派');
      await tester.pump();
      
      // Save
      final saveBtn = find.byKey(const Key('save_button'));
      await tester.tap(saveBtn);
      await tester.pumpAndSettle(); 

      // Should be back on Pan Page
      expect(find.byType(TaiYiPanPage), findsOneWidget);
      
      // Verify new school choice chip exists
      expect(find.text('自定义流派'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
