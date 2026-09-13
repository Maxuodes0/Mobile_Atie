import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aite_mobile/l10n/app_localizations.dart';

void main() {
  test('uses Arabic when iPhone app language is Arabic', () {
    final locale = AppLocalizations.resolveLocale(
      const [Locale('ar', 'SA')],
      AppLocalizations.supportedLocales,
    );

    expect(locale.languageCode, 'ar');
  });

  test('uses English when iPhone app language is English', () {
    final locale = AppLocalizations.resolveLocale(
      const [Locale('en', 'US')],
      AppLocalizations.supportedLocales,
    );

    expect(locale.languageCode, 'en');
  });

  test('falls back to English for unsupported iPhone languages', () {
    final locale = AppLocalizations.resolveLocale(
      const [Locale('fr', 'FR')],
      AppLocalizations.supportedLocales,
    );

    expect(locale.languageCode, 'en');
  });
}
