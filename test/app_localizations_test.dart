import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aite_mobile/utils/collection_status.dart';
import 'package:aite_mobile/utils/project_status.dart';
import 'package:aite_mobile/utils/task_status.dart';

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

  test('status labels follow the selected app language', () {
    expect(projectStatusLabel('COMPLETED', languageCode: 'en'), 'Completed');
    expect(projectStatusLabel('COMPLETED', languageCode: 'ar'), 'مكتمل');
    expect(taskStatusLabel('in_progress', languageCode: 'en'), 'In progress');
    expect(taskStatusLabel('in_progress', languageCode: 'ar'), 'قيد التنفيذ');
    expect(
      collectionStatusLabel('FULLY_COLLECTED', languageCode: 'en'),
      'Fully collected',
    );
    expect(
      collectionStatusLabel('FULLY_COLLECTED', languageCode: 'ar'),
      'محصل بالكامل',
    );
  });
}
