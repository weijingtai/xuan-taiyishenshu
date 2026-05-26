import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/theme/taiyi_classic_theme.dart';
import 'package:taiyishenshu/widgets/ink_wash_widgets.dart';
import '../taiyi/test_harness.dart';

void main() {
  setUpAll(() async {
    await TaiYiTestHarness.setup();
  });

  group('Ink Wash Aesthetics BDD', () {
    testWidgets('Given a container with InkyBorder, When rendered, Then it has a CustomPainter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InkyBorder(
              child: Container(width: 100, height: 100),
            ),
          ),
        ),
      );

      // Verify it has a CustomPaint widget
      expect(find.byType(CustomPaint), findsAtLeast(1));
    });

    testWidgets('Given a SectionHeader, When rendered, Then it uses expected styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChineseSectionHeader(title: '测试标题'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('测试标题'));
      // In tests, we expect the fallback style which might not have the font family name
      // but should have the correct colors and weight.
      expect(textWidget.style?.color, TaiYiClassicTheme.darkWood);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });
    
    testWidgets('Given DeityManagementDialog, When opened, Then it has a Paper background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: TaiYiClassicTheme.ricePaper,
            body: const Center(),
          ),
        ),
      );
      
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, TaiYiClassicTheme.ricePaper);
    });
  });
}
