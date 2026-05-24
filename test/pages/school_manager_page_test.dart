import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taiyishenshu/pages/school_manager_page.dart';
import 'package:taiyishenshu/taiyi/viewmodels/school_view_model.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';

class FakeSchoolViewModel extends ChangeNotifier implements SchoolViewModel {
  @override
  List<TaiYiSchool> schools = [
    const TaiYiSchool(
      id: 'test_school_1',
      name: 'Test School 1',
      source: 'official',
      epoch: SchoolEpochConfig(ancientBase: 10153917, epochYear: 1984),
      wenChangStayRule: true,
      useTwelveJiShen: false,
      palaceFormula: 'jingMirror',
      eightDoorMode: 'dynamic',
    ),
  ];

  @override
  TaiYiSchool? currentSchool;

  @override
  bool isLoading = false;

  @override
  Future<void> loadSchools() async {}

  @override
  void selectSchool(String id) {
    currentSchool = schools.firstWhere((s) => s.id == id);
    notifyListeners();
  }

  @override
  Future<void> copySchool({required String sourceId, required String newId, String? newName}) async {
    final source = schools.firstWhere((s) => s.id == sourceId);
    schools = List.from(schools)..add(source.copyWith(
      id: newId,
      name: newName ?? '${source.name} (Copy)',
      source: 'user',
    ));
    notifyListeners();
  }

  @override
  Future<void> saveSchool(TaiYiSchool school) async {
    final index = schools.indexWhere((s) => s.id == school.id);
    if (index != -1) {
      schools = List.from(schools)..[index] = school;
      notifyListeners();
    }
  }
  
  @override
  get loadSchoolsUseCase => throw UnimplementedError();
  @override
  get copySchoolUseCase => throw UnimplementedError();
  @override
  get saveUserSchoolUseCase => throw UnimplementedError();
}

void main() {
  testWidgets('SchoolManagerPage shows a list of schools', (WidgetTester tester) async {
    final fakeViewModel = FakeSchoolViewModel();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SchoolViewModel>.value(
          value: fakeViewModel,
          child: const SchoolManagerPage(),
        ),
      ),
    );

    // Initial pump and maybe animation frame
    await tester.pumpAndSettle();

    // Verify it shows "Test School 1"
    expect(find.text('Test School 1'), findsOneWidget);
  });

  testWidgets('SchoolManagerPage allows copying a school', (WidgetTester tester) async {
    final fakeViewModel = FakeSchoolViewModel();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SchoolViewModel>.value(
          value: fakeViewModel,
          child: const SchoolManagerPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find copy button for the first school
    final copyButton = find.byIcon(Icons.copy).first;
    expect(copyButton, findsOneWidget);

    // Tap copy button
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    // Dialog appears, fill in new name
    expect(find.text('Copy School'), findsOneWidget);
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Copied School');
    
    // Tap copy in dialog
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();

    // Verify new school is in the list
    expect(find.text('Copied School'), findsOneWidget);
    // Custom schools should have an edit button, official ones don't
    expect(find.byIcon(Icons.edit), findsOneWidget); 
  });

  testWidgets('SchoolManagerPage allows editing a user-defined school', (WidgetTester tester) async {
    final fakeViewModel = FakeSchoolViewModel();
    // Add a custom school first
    fakeViewModel.schools.add(const TaiYiSchool(
      id: 'test_school_2',
      name: 'Custom School',
      source: 'user',
      epoch: SchoolEpochConfig(ancientBase: 10153917, epochYear: 1984),
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SchoolViewModel>.value(
          value: fakeViewModel,
          child: const SchoolManagerPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom School'), findsOneWidget);

    // Find edit button (only custom school has it)
    final editButton = find.byIcon(Icons.edit);
    expect(editButton, findsOneWidget);

    // Tap edit button
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // Dialog appears, change name
    expect(find.text('Edit School'), findsOneWidget);
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Edited Custom School');

    // Tap save in dialog
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify name updated
    expect(find.text('Edited Custom School'), findsOneWidget);
    expect(find.text('Custom School'), findsNothing);
  });

  testWidgets('SchoolManagerPage allows switching current school', (WidgetTester tester) async {
    final fakeViewModel = FakeSchoolViewModel();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SchoolViewModel>.value(
          value: fakeViewModel,
          child: const SchoolManagerPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Checkmark shouldn't be present initially because currentSchool is null
    expect(find.byIcon(Icons.check), findsNothing);

    // Tap the list tile to select it
    await tester.tap(find.text('Test School 1'));
    await tester.pumpAndSettle();

    // Now it should be the current school and show a checkmark
    expect(fakeViewModel.currentSchool?.id, 'test_school_1');
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
