import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aite_mobile/data/models/finance_dashboard.dart';
import 'package:aite_mobile/l10n/app_localizations.dart';
import 'package:aite_mobile/screens/dashboard/widgets/dashboard_kpi_grid.dart';
import 'package:aite_mobile/theme/app_theme.dart';

void main() {
  const kpis = FinanceKpis(
    totalProjectValueWithoutVat: '11400129.06',
    totalCollectedAmount: '10102000.00',
    outstandingAmount: '1298129.06',
    totalCosts: '3134752.48',
    netProfit: '8267247.52',
    profitMargin: '72.52',
  );

  testWidgets('dashboard presents four large editorial KPI cards',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          body: SingleChildScrollView(
            child: DashboardKpiGrid(kpis: kpis),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('dashboard-kpi-card-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-kpi-card-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-kpi-card-2')), findsOneWidget);
    expect(find.text('Total contract value'), findsOneWidget);
    expect(find.text('Collected'), findsOneWidget);
    expect(find.text('Outstanding'), findsOneWidget);
    final horizontalList = tester.widget<ListView>(
      find.byKey(const ValueKey('dashboard-kpi-scroll')),
    );
    expect(horizontalList.scrollDirection, Axis.horizontal);

    await tester.drag(
      find.byKey(const ValueKey('dashboard-kpi-scroll')),
      const Offset(-900, 0),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dashboard-kpi-card-3')), findsOneWidget);
    expect(find.text('Project costs'), findsOneWidget);
  });

  testWidgets('dashboard KPI visual stays legible on a narrow phone',
      (tester) async {
    final dashboardFont = FontLoader(AppTheme.dashboardFontFamily)
      ..addFont(rootBundle.load('assets/fonts/LouisGeorgeCafe-Regular.ttf'));
    final currencyFont = FontLoader('AiteSaudiRiyal')
      ..addFont(rootBundle.load('assets/fonts/NotoNaskhArabic-Riyal.ttf'));
    await Future.wait([dashboardFont.load(), currencyFont.load()]);

    tester.view.physicalSize = const Size(390, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          backgroundColor: AppTheme.dashboardCanvas,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: RepaintBoundary(
              child: DashboardKpiGrid(kpis: kpis),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(DashboardKpiGrid),
      matchesGoldenFile('goldens/dashboard_kpi_design.png'),
    );
  });

  testWidgets('dashboard KPI cards remain overflow-free in Arabic',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          body: SingleChildScrollView(
            child: DashboardKpiGrid(kpis: kpis),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('إجمالي قيمة العقود'), findsOneWidget);
    expect(find.text('المبالغ المحصلة'), findsOneWidget);
    expect(tester.widget<Text>(find.text('›').first).textDirection,
        TextDirection.ltr);
  });
}
