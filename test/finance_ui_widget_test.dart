import 'package:aite_mobile/data/models/finance_module.dart';
import 'package:aite_mobile/l10n/app_localizations.dart';
import 'package:aite_mobile/screens/finance/finance_results.dart';
import 'package:aite_mobile/screens/finance/finance_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: Center(child: SizedBox(width: 380, child: child))),
    );

void main() {
  test('financial ISO dates keep their recorded calendar day', () {
    expect(financeDate('2025-02-10T00:00:00.000Z'), '10/02/2025');
    expect(financeDate('2025-02-10'), '10/02/2025');
  });

  testWidgets('cost category codes are localized without changing custom names',
      (tester) async {
    await tester.pumpWidget(_app(
        Builder(
            builder: (context) => Column(
                  children: [
                    Text(financeCostCategory(context, 'FOOD')),
                    Text(financeCostCategory(context, 'TRANSPORTATION')),
                    Text(financeCostCategory(context, 'ضيافة خاصة')),
                  ],
                )),
        locale: const Locale('ar')));

    expect(find.text('طعام'), findsOneWidget);
    expect(find.text('نقل'), findsOneWidget);
    expect(find.text('ضيافة خاصة'), findsOneWidget);
    expect(find.text('FOOD'), findsNothing);
  });

  testWidgets('period picker sends the backend Q1-Q4 contract', (tester) async {
    String? selected;
    await tester.pumpWidget(_app(FinancePeriodPicker(
      year: 2026,
      quarter: 'ALL',
      availableYears: const [2025, 2026],
      onYearChanged: (_) {},
      onQuarterChanged: (quarter) => selected = quarter,
    )));

    await tester.tap(find.text('All quarters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Q2').last);
    await tester.pumpAndSettle();
    expect(selected, 'Q2');
  });

  testWidgets('Arabic financial list keeps server totals and Latin digits',
      (tester) async {
    final data = FinanceDataPage.fromJson({
      'rows': [
        {'projectId': 'p1', 'projectName': 'مشروع ١', 'value': '1234.56'},
      ],
      'meta': {'total': 26, 'page': 1, 'pageSize': 25, 'totalPages': 2},
    });
    int? selectedPage;
    await tester.pumpWidget(_app(
        ListView(children: [
          FinanceResults(
            data: data,
            error: null,
            loading: false,
            onRetry: () {},
            onPage: (page) => selectedPage = page,
            rowBuilder: (_, row) => Text(financeMoney(row['value'])),
          ),
        ]),
        locale: const Locale('ar')));

    expect(find.textContaining('1,234.56'), findsOneWidget);
    expect(find.textContaining('26 سجل'), findsOneWidget);
    await tester.tap(find.byTooltip('الصفحة التالية'));
    expect(selectedPage, 2);
  });
}
