import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aite_mobile/screens/login_screen.dart';
import 'package:aite_mobile/l10n/app_localizations.dart';
import 'package:aite_mobile/services/app_services.dart';
import 'package:aite_mobile/theme/app_theme.dart';

void main() {
  testWidgets('Login screen renders', (tester) async {
    AppServices.init();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LoginScreen(),
      ),
    );

    expect(find.text('تسجيل الدخول'), findsAtLeastNWidgets(1));
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);

    AppServices.session.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
