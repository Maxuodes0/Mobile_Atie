import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aite_mobile/data/models/user.dart';
import 'package:aite_mobile/l10n/app_localizations.dart';
import 'package:aite_mobile/screens/more_screen.dart';
import 'package:aite_mobile/services/app_services.dart';

void main() {
  testWidgets('More shows tasks and mirrors navigation arrows in Arabic', (
    tester,
  ) async {
    AppServices.init();
    AppServices.session.user.value = const User(
      id: 'admin',
      name: 'Admin',
      email: 'admin@example.com',
      role: 'ADMIN',
      organizationId: 'organization',
    );

    Future<void> showMore(Locale locale) => tester.pumpWidget(
          MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const Scaffold(body: MoreScreen()),
          ),
        );

    await showMore(const Locale('ar'));
    expect(find.text('المهام'), findsOneWidget);
    expect(find.text('المالية'), findsNothing);
    expect(Icons.chevron_right_rounded.matchTextDirection, isTrue);
    final arabicArrow = find.byIcon(Icons.chevron_right_rounded).first;
    expect(Directionality.of(tester.element(arabicArrow)), TextDirection.rtl);

    await showMore(const Locale('en'));
    expect(find.text('Tasks'), findsOneWidget);
    final englishArrow = find.byIcon(Icons.chevron_right_rounded).first;
    expect(Directionality.of(tester.element(englishArrow)), TextDirection.ltr);

    await tester.pumpWidget(const SizedBox.shrink());
    AppServices.session.dispose();
  });
}
