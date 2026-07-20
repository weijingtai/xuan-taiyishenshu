import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:taiyishenshu/widgets/deity_management_dialog.dart';
import '../taiyi/test_harness.dart';

import 'package:taiyishenshu/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await TaiYiTestHarness.setup();
  });

  testWidgets('Given user is on Pan Page, When unchecking TaiYi, Then warning appears', (tester) async {
    final assembly = await TaiYiTestHarness.createAssembly();
    final controller = TaiYiPanController(assembly: assembly);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TaiYiPanPage(controller: controller),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Open Deity Management Dialog
    final managementBtn = find.byIcon(Icons.auto_awesome);
    expect(managementBtn, findsOneWidget);
    await tester.tap(managementBtn);
    await tester.pumpAndSettle();

    // Find TaiYi chip and uncheck it
    final taiYiChip = find.descendant(of: find.byType(DeityManagementDialog), matching: find.text('太乙'));
    expect(taiYiChip, findsOneWidget);

    await tester.tap(taiYiChip);
    await tester.pumpAndSettle();

    // Close dialog (must settle the dismiss animation before reading the main page)
    await tester.tap(find.widgetWithText(TextButton, '关闭'));
    await tester.pumpAndSettle();

    // Verify warning message appears on the main page
    // (Dialog is dismissed; the dialog's own banner is gone, only the page banner remains.)
    expect(find.textContaining('部分基础星神或关键计算项已隐藏'), findsOneWidget);
  });
}
