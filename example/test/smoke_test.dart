import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu_example/main.dart';
import 'package:taiyishenshu/theme/taiyi_classic_theme.dart';
import 'package:taiyishenshu/widgets/ink_wash_widgets.dart';

void main() {
  testWidgets('Example App Smoke Test', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExampleApp());

    // Verify that we are on the Deity Dialog Demo page
    expect(find.text('星神管理 Demo'), findsOneWidget);
    expect(find.text('打开管理弹窗'), findsOneWidget);

    // Tap the button to open the dialog
    await tester.tap(find.text('打开管理弹窗'));
    await tester.pumpAndSettle();

    // Verify dialog is open
    expect(find.text('星神管理'), findsOneWidget);
    expect(find.text('系统内置'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    // Verify specific ink-wash components are present
    expect(find.byType(PaperBackground), findsAtLeast(1));
    expect(find.byType(InkyBorder), findsAtLeast(1));
    expect(find.byType(ChineseSectionHeader), findsAtLeast(1));
  });
}
