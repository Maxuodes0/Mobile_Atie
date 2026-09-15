import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';
import 'services/app_services.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppServices.init();
  runApp(const AiteApp());
}

class AiteApp extends StatelessWidget {
  const AiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aite Management',
      theme: AppTheme.light(),
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: AppLocalizations.resolveLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        Intl.defaultLocale = Localizations.localeOf(context).toString();
        return DefaultTextStyle.merge(
          style: const TextStyle(fontFamilyFallback: ['AiteSaudiRiyal']),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthGate(),
    );
  }
}
