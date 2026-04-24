import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(l10n != null, 'AppLocalizations not found in widget tree');
    return l10n!;
  }

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'title': 'Login',
      'subtitle': "Let's Get Started",
      'email': 'Email',
      'password': 'Password',
      'signIn': 'Sign In',
      'forgot': 'Forgot password?',
      'emailRequired': 'Email is required',
      'emailInvalid': 'Enter a valid email',
      'passwordRequired': 'Password is required',
    },
    'ar': {
      'title': 'تسجيل الدخول',
      'subtitle': 'لنبدأ',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'signIn': 'تسجيل الدخول',
      'forgot': 'نسيت كلمة المرور؟',
      'emailRequired': 'البريد الإلكتروني مطلوب',
      'emailInvalid': 'أدخل بريد إلكتروني صحيح',
      'passwordRequired': 'كلمة المرور مطلوبة',
    },
  };

  String _t(String key) {
    final lang = _values[locale.languageCode];
    if (lang == null) return _values['en']![key] ?? key;
    return lang[key] ?? (_values['en']![key] ?? key);
  }

  String get title => _t('title');
  String get subtitle => _t('subtitle');
  String get email => _t('email');
  String get password => _t('password');
  String get signIn => _t('signIn');
  String get forgot => _t('forgot');
  String get emailRequired => _t('emailRequired');
  String get emailInvalid => _t('emailInvalid');
  String get passwordRequired => _t('passwordRequired');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
