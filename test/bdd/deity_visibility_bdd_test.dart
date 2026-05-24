import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:provider/provider.dart';
import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:taiyishenshu/widgets/deity_management_dialog.dart';
import 'package:google_fonts/google_fonts.dart';


class MockAssetBundle extends Fake implements AssetBundle {
  final Map<String, String> assets;
  MockAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) {
      return assets[key]!;
    }
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

  testWidgets('Given user is on Pan Page, When unchecking TaiYi, Then warning appears', (tester) async {
    final bundle = MockAssetBundle(mockAssets);
    final controller = TaiYiPanController(bundle: bundle);

    await tester.pumpWidget(
      MaterialApp(
        home: TaiYiPanPage(controller: controller),
      ),
    );
    
    await tester.pumpAndSettle();

    // Open Deity Management Dialog (auto_awesome icon)
    final managementBtn = find.byIcon(Icons.auto_awesome);
    expect(managementBtn, findsOneWidget);
    await tester.tap(managementBtn);
    await tester.pumpAndSettle();

    // Find TaiYi chip and uncheck it
    final taiYiChip = find.descendant(of: find.byType(DeityManagementDialog), matching: find.text('太乙'));
    expect(taiYiChip, findsOneWidget);
    
    // Tap the chip
    await tester.tap(taiYiChip);
    await tester.pumpAndSettle();


    // Close dialog
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    // Verify warning message appears on the main page
    expect(find.textContaining('部分基础星神或关键计算项已隐藏'), findsOneWidget);
  });
}
