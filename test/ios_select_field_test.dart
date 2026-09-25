import 'package:aite_mobile/l10n/app_localizations.dart';
import 'package:aite_mobile/widgets/ios_select_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('iPhone selection opens a Cupertino wheel', (tester) async {
    String? chosen;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: IosSelectField<String>(
          initialValue: 'first',
          decoration: const InputDecoration(labelText: 'Year'),
          items: const [
            DropdownMenuItem(value: 'first', child: Text('First')),
            DropdownMenuItem(value: 'second', child: Text('Second')),
          ],
          onChanged: (value) => chosen = value,
        ),
      ),
    ));
    await tester.tap(find.text('First'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPicker), findsOneWidget);
    await tester.drag(find.byType(CupertinoPicker), const Offset(0, -50));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(chosen, 'second');
  });
}
