import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:taiyishenshu/pages/entity_editor_page.dart';
import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
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
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    if (assets.containsKey(key)) {
      return ByteData.view(Uint8List.fromList(utf8.encode(assets[key]!)).buffer);
    }
    if (key.contains('AssetManifest')) return ByteData(0);
    throw FlutterError('Asset not found: $key');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final Map<String, String> mockAssets = {};

  setUpAll(() {
    final schoolIds = ['jing-mirror', 'tong-zong', 'ji-cheng'];
    for (final id in schoolIds) {
      final camelId = id == 'jing-mirror' ? 'jingMirror' : id == 'tong-zong' ? 'tongZong' : 'jiCheng';
      mockAssets['assets/schools/$camelId.json'] =
          File('assets/schools/$id.json').readAsStringSync();
    }
    
    final deityIds = ['tai-yi', 'wen-chang'];
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

  group('Deity Management BDD', () {
    testWidgets('AC8: Dialog shows sections', (tester) async {
      // Mock only 2 deities to avoid long list issues
      final bundle = MockAssetBundle(mockAssets);
      final assembly = TaiYiDataAssembly(bundle: bundle);
      final controller = TaiYiPanController(assembly: assembly);

      
      // We manually populate the official deities to control the test
      // Actually loadSchools will load them from mockAssets.
      
      await tester.pumpWidget(MaterialApp(home: TaiYiPanPage(controller: controller)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      expect(find.text('系统内置'), findsOneWidget);
      // "我的" might be offstage if the list is long, but with 2 deities it should be on screen.
      // Use find.textContaining for robustness
      expect(find.textContaining('我的'), findsOneWidget);
      expect(find.text('Marketplace'), findsOneWidget);
    });

    testWidgets('AC10: Copy deity shows SnackBar', (tester) async {
      final bundle = MockAssetBundle(mockAssets);
      final assembly = TaiYiDataAssembly(bundle: bundle);
      final controller = TaiYiPanController(assembly: assembly);
      await tester.pumpWidget(MaterialApp(home: TaiYiPanPage(controller: controller)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      final copyBtn = find.byIcon(Icons.copy).first;
      await tester.tap(copyBtn);
      await tester.pump();

      expect(find.textContaining('已复制'), findsOneWidget);
    });

    testWidgets('AC12: Editor shows lineage', (tester) async {


      await tester.pumpWidget(
        const MaterialApp(
          home: EntityEditorPage(
            type: EntityType.deity,
            initialName: '我的太乙',
            lineage: '官方 > 我的派生',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('传承链'), findsOneWidget);
      expect(find.text('官方 > 我的派生'), findsOneWidget);
    });
  });
}
