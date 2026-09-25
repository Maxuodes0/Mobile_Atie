import 'package:aite_mobile/data/models/monthly_collection_point.dart';
import 'package:aite_mobile/l10n/app_localizations.dart';
import 'package:aite_mobile/screens/dashboard/widgets/dashboard_collections_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('collection rhythm can be swiped and tapped', (tester) async {
    tester.view.physicalSize = const Size(390, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final points = List.generate(
        12,
        (index) => MonthlyCollectionPoint(
            month: 'M${index + 1}',
            collected: (index + 1) * 100.0,
            uncollected: 0));
    await tester.pumpWidget(MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
          body: SingleChildScrollView(
        child: DashboardCollectionsCard(kpis: null, collections: points),
      )),
    ));
    final chart = find.byKey(const ValueKey('collection-rhythm-scroll'));
    expect(chart, findsOneWidget);
    final scrollable = tester.state<ScrollableState>(
        find.descendant(of: chart, matching: find.byType(Scrollable)));
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    await tester.drag(chart, const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
    await tester.tap(chart);
    await tester.pumpAndSettle();
    expect(find.text('Swipe to explore; tap a month for its amount'),
        findsNothing);
  });
}
