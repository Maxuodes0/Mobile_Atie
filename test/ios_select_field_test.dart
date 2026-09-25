import 'package:aite_mobile/l10n/app_localizations.dart';
import 'package:aite_mobile/data/models/org_user.dart';
import 'package:aite_mobile/data/models/project_summary.dart';
import 'package:aite_mobile/screens/create_task/widgets/create_task_project_picker_sheet.dart';
import 'package:aite_mobile/screens/create_task/widgets/create_task_user_picker_sheet.dart';
import 'package:aite_mobile/theme/app_theme.dart';
import 'package:aite_mobile/widgets/ios_select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget testApp(Widget child,
        {TargetPlatform platform = TargetPlatform.android}) =>
    MaterialApp(
      theme: AppTheme.light().copyWith(platform: platform),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
          body: SafeArea(
              child: Padding(padding: const EdgeInsets.all(16), child: child))),
    );

void main() {
  testWidgets('short list selects the original value without search',
      (tester) async {
    String? chosen;
    await tester.pumpWidget(testApp(
        IosSelectField<String>(
          initialValue: 'first',
          decoration: const InputDecoration(labelText: 'Status'),
          items: const [
            DropdownMenuItem(value: 'first', child: Text('First')),
            DropdownMenuItem(value: 'second', child: Text('Second')),
          ],
          onChanged: (value) => chosen = value,
        ),
        platform: TargetPlatform.iOS));
    await tester.tap(find.text('First').first);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Status'), findsWidgets);
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(chosen, 'second');
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('many options search and long selected text fit small iPhone',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetViewInsets);
    const longName =
        'A very long project name that should never cover the chevron';
    String? chosen;
    await tester.pumpWidget(testApp(
        IosSelectField<String>(
          initialValue: 'p0',
          decoration: const InputDecoration(labelText: 'Project'),
          items: [
            const DropdownMenuItem(value: 'p0', child: Text(longName)),
            for (var i = 1; i <= 40; i++)
              DropdownMenuItem(value: 'p$i', child: Text('Project $i')),
          ],
          onChanged: (value) => chosen = value,
        ),
        platform: TargetPlatform.iOS));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(longName));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), 'Project 39');
    await tester.pumpAndSettle();
    expect(find.text('Project 39'), findsNWidgets(2));
    await tester.tap(find.text('Project 39').last);
    await tester.pumpAndSettle();
    expect(chosen, 'p39');
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty, loading, error and disabled states are safe',
      (tester) async {
    await tester.pumpWidget(testApp(const Column(children: [
      IosSelectField<String>(
        initialValue: null,
        decoration: InputDecoration(labelText: 'Empty'),
        items: [],
        onChanged: null,
        errorText: 'Required',
      ),
      IosSelectField<String>(
        initialValue: null,
        decoration: InputDecoration(labelText: 'Loading'),
        items: [],
        onChanged: null,
        loading: true,
      ),
      IosSelectField<String>(
        initialValue: 'a',
        decoration: InputDecoration(labelText: 'Disabled'),
        items: [DropdownMenuItem(value: 'a', child: Text('Alpha'))],
        onChanged: null,
      ),
    ])));
    expect(find.text('Required'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nullable option preserves all-years selection', (tester) async {
    int? chosen = 2026;
    await tester.pumpWidget(testApp(IosSelectField<int>(
      initialValue: 2026,
      decoration: const InputDecoration(labelText: 'Year'),
      items: const [
        DropdownMenuItem(value: null, child: Text('All years')),
        DropdownMenuItem(value: 2026, child: Text('2026')),
      ],
      onChanged: (value) => chosen = value,
    )));
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All years'));
    await tester.pumpAndSettle();
    expect(chosen, isNull);
    expect(find.text('All years'), findsOneWidget);
  });

  testWidgets('empty list opens a contained empty state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(testApp(IosSelectField<String>(
      initialValue: null,
      decoration: const InputDecoration(labelText: 'Client'),
      items: const [],
      onChanged: (_) {},
      searchable: true,
    )));
    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    expect(find.text('No options found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('form validation and selected IDs are preserved on Android',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    String? chosen;
    await tester.pumpWidget(testApp(Form(
      key: formKey,
      child: IosSelectField<String>(
        initialValue: null,
        decoration: const InputDecoration(labelText: 'Category'),
        items: const [
          DropdownMenuItem(value: 'food', child: Text('Food')),
          DropdownMenuItem(value: 'travel', child: Text('Travel')),
        ],
        validator: (value) => value == null ? 'Required' : null,
        onChanged: (value) => chosen = value,
      ),
    )));
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(chosen, 'food');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('existing project and employee sheets fit with iPhone keyboard',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetViewInsets);
    const projects = [
      ProjectSummary(
        id: 'p1',
        name: 'Project One',
        status: 'ON_TRACK',
        collectionStatus: null,
        totalCollectedAmount: null,
        clientName: 'Client',
        projectImage: null,
        createdAt: null,
      ),
    ];
    const users = [
      OrgUser(
          id: 'u1',
          name: 'Employee One',
          email: 'one@example.test',
          role: 'EMPLOYEE',
          profileImage: null),
    ];
    await tester.pumpWidget(testApp(Builder(
        builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (_) => const CreateTaskProjectPickerSheet(
                        items: projects, selectedId: 'p1'),
                  ),
                  child: const Text('Open projects'),
                ),
                TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (_) => const CreateTaskUserPickerSheet(
                        initialItems: users,
                        initialTotal: 1,
                        pageSize: 20,
                        selectedId: 'u1'),
                  ),
                  child: const Text('Open employees'),
                ),
              ],
            ))));
    await tester.tap(find.text('Open projects'));
    await tester.pumpAndSettle();
    expect(find.text('Select project'), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open employees'));
    await tester.pumpAndSettle();
    expect(find.text('Select assignee'), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
