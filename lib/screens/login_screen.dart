import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/api/api_exception.dart';
import '../data/api/auth_api.dart';
import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/error_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _background = Color(0xFFF8E6D4);
  static const _fieldBorder = Color(0xFFE7CDB6);
  static const _buttonColor = Color(0xFF111D2D);

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _mfaCode = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _submitted = false;
  String? _error;
  String? _mfaTransaction;
  String? _mfaMode;
  String? _mfaSecret;
  String? _mfaUri;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _mfaCode.dispose();
    super.dispose();
  }

  String _loginErrorMessage(Object error, bool isAr) {
    if (error is ApiException) {
      if (error.code == 'CSRF_INVALID') {
        return isAr
            ? 'حصل خطأ في الجلسة، حاول مرة ثانية'
            : 'Session error, please try again.';
      }
      return error.message;
    }

    return isAr
        ? 'تعذر تسجيل الدخول، حاول مرة أخرى'
        : 'Login failed. Try again.';
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    setState(() {
      _error = null;
      _submitted = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final result = await AppServices.session.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (result.requiresMfaEnrollment && result.transactionToken != null) {
        final setup = await AppServices.auth.startMfaEnrollment(
          result.transactionToken!,
        );
        if (!mounted) return;
        setState(() {
          _mfaTransaction = result.transactionToken;
          _mfaMode = 'enrollment';
          _mfaSecret = setup.secret;
          _mfaUri = setup.uri;
          _mfaCode.clear();
        });
      } else if (result.requiresMfaChallenge &&
          result.transactionToken != null) {
        setState(() {
          _mfaTransaction = result.transactionToken;
          _mfaMode = 'challenge';
          _mfaSecret = null;
          _mfaUri = null;
          _mfaCode.clear();
        });
      } else if (result.user == null) {
        throw Exception(result.message ?? 'Unexpected login response');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _loginErrorMessage(error, isAr));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleMfaSubmit() async {
    FocusScope.of(context).unfocus();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final transaction = _mfaTransaction;
    final code = _mfaCode.text.trim();
    if (transaction == null || code.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      late final AuthLoginResult result;
      if (_mfaMode == 'enrollment') {
        result = await AppServices.auth.confirmMfaEnrollment(
          transactionToken: transaction,
          code: code,
        );
      } else {
        result = await AppServices.auth.challengeMfa(
          transactionToken: transaction,
          code: code,
        );
      }
      if (result.user == null) {
        throw Exception(result.message ?? 'Unexpected MFA response');
      }
      if (_mfaMode == 'enrollment' && result.recoveryCodes.isNotEmpty) {
        await _showRecoveryCodes(result.recoveryCodes, isAr);
      }
      await AppServices.session.acceptAuthenticatedUser(result.user!);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _loginErrorMessage(error, isAr));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showRecoveryCodes(List<String> codes, bool isAr) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(isAr ? 'رموز الاسترداد' : 'Recovery codes'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isAr
                    ? 'احفظ هذه الرموز في مكان آمن. كل رمز يُستخدم مرة واحدة.'
                    : 'Save these codes securely. Each code can be used once.',
              ),
              const SizedBox(height: 14),
              SelectableText(
                codes.join('\n'),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(isAr ? 'حفظت الرموز' : 'I saved the codes'),
          ),
        ],
      ),
    );
  }

  void _showUnavailableMessage(bool isAr) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'سيتم توفير هذه الخدمة داخل التطبيق قريبًا.'
                : 'This service will be available in the app soon.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final compact = mediaQuery.size.height < 760;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: _background,
        body: Stack(
          children: [
            const Positioned.fill(child: _LoginBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsetsDirectional.fromSTEB(
                      28,
                      compact ? 10 : 18,
                      28,
                      22,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - (compact ? 32 : 40),
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _submitted
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: AutofillGroup(
                          child: Column(
                            children: [
                              const Text(
                                'AITE',
                                style: TextStyle(
                                  color: _buttonColor,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),
                              SizedBox(height: compact ? 4 : 8),
                              SizedBox(
                                height: compact ? 210 : 260,
                                child: Image.asset(
                                  'assets/images/New pics/Saufi Guy.png',
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                              SizedBox(height: compact ? 8 : 14),
                              Text(
                                isAr ? 'مرحبًا بعودتك' : 'Welcome back',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.ink,
                                  fontSize: 28,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isAr
                                    ? 'سجّل دخولك لمتابعة إدارة مشاريعك وفريقك.'
                                    : 'Sign in to continue managing\nyour projects and team.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF6D6862),
                                  fontSize: 14,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: compact ? 18 : 24),
                              if (_error != null) ...[
                                ErrorBanner(message: _error!),
                                const SizedBox(height: 12),
                              ],
                              if (_mfaMode == null) ...[
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: _fieldDecoration(
                                    hint: l10n.email,
                                    prefix: Icons.mail_outline_rounded,
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return l10n.emailRequired;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  decoration: _fieldDecoration(
                                    hint: l10n.password,
                                    prefix: Icons.lock_outline_rounded,
                                    suffix: IconButton(
                                      onPressed: () => setState(
                                        () => _obscure = !_obscure,
                                      ),
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 21,
                                        color: const Color(0xFF77716B),
                                      ),
                                    ),
                                  ),
                                  validator: (value) => (value ?? '').isEmpty
                                      ? l10n.passwordRequired
                                      : null,
                                ),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: TextButton(
                                    onPressed: () =>
                                        _showUnavailableMessage(isAr),
                                    style: TextButton.styleFrom(
                                      foregroundColor: _buttonColor,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                        10,
                                        8,
                                        0,
                                        8,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: Text(
                                      l10n.forgot,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                _MfaPanel(
                                  enrollment: _mfaMode == 'enrollment',
                                  secret: _mfaSecret,
                                  uri: _mfaUri,
                                  isArabic: isAr,
                                  codeController: _mfaCode,
                                  decoration: _fieldDecoration(
                                    hint: isAr
                                        ? 'رمز التحقق'
                                        : 'Verification code',
                                    prefix: Icons.shield_outlined,
                                  ),
                                  onSubmitted: _handleMfaSubmit,
                                ),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: TextButton.icon(
                                    onPressed: _loading
                                        ? null
                                        : () => setState(() {
                                              _mfaMode = null;
                                              _mfaTransaction = null;
                                              _mfaSecret = null;
                                              _mfaUri = null;
                                              _mfaCode.clear();
                                            }),
                                    icon: const Icon(Icons.arrow_back_rounded),
                                    label: Text(
                                      isAr
                                          ? 'العودة لتسجيل الدخول'
                                          : 'Back to sign in',
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  onPressed: _loading
                                      ? null
                                      : (_mfaMode == null
                                          ? _handleLogin
                                          : _handleMfaSubmit),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _buttonColor,
                                    disabledBackgroundColor:
                                        _buttonColor.withAlpha(170),
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    elevation: 0,
                                  ),
                                  child: _loading
                                      ? const SizedBox.square(
                                          dimension: 21,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _mfaMode == null
                                              ? l10n.signIn
                                              : (isAr
                                                  ? 'تحقق ومتابعة'
                                                  : 'Verify and continue'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              if (_mfaMode == null) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        _showUnavailableMessage(isAr),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _buttonColor,
                                      side:
                                          const BorderSide(color: _fieldBorder),
                                      shape: const StadiumBorder(),
                                    ),
                                    child: Text(
                                      isAr ? 'إنشاء حساب' : 'Create account',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: compact ? 24 : 38),
                              Text.rich(
                                TextSpan(
                                  text: isAr
                                      ? 'بالمتابعة، أنت توافق على '
                                      : 'By signing in, you agree to AITE’s ',
                                  children: [
                                    TextSpan(
                                      text: isAr
                                          ? 'شروط الخدمة وسياسة الخصوصية.'
                                          : 'Terms of Service and Privacy Policy.',
                                      style: const TextStyle(
                                        color: _buttonColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF8A837B),
                                  fontSize: 10.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: _fieldBorder),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8A837B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(prefix, size: 20, color: const Color(0xFF77716B)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withAlpha(30),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: _buttonColor, width: 1.2),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: Colors.red.shade500, width: 1.2),
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF4EA), Color(0xFFF8E6D4)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _MfaPanel extends StatelessWidget {
  const _MfaPanel({
    required this.enrollment,
    required this.secret,
    required this.uri,
    required this.isArabic,
    required this.codeController,
    required this.decoration,
    required this.onSubmitted,
  });

  final bool enrollment;
  final String? secret;
  final String? uri;
  final bool isArabic;
  final TextEditingController codeController;
  final InputDecoration decoration;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(105),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _LoginScreenState._fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            enrollment
                ? (isArabic
                    ? 'ربط تطبيق المصادقة'
                    : 'Connect your authenticator app')
                : (isArabic ? 'التحقق بخطوتين' : 'Two-step verification'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            enrollment
                ? (isArabic
                    ? 'افتح Google Authenticator أو Microsoft Authenticator، وأضف مفتاح الإعداد التالي.'
                    : 'Open Google Authenticator or Microsoft Authenticator and add the setup key below.')
                : (isArabic
                    ? 'أدخل الرمز المكوّن من 6 أرقام، أو استخدم أحد رموز الاسترداد.'
                    : 'Enter the 6-digit code, or use one of your recovery codes.'),
            style: const TextStyle(
              color: Color(0xFF6D6862),
              height: 1.4,
            ),
          ),
          if (enrollment && secret != null) ...[
            const SizedBox(height: 14),
            if (uri != null && uri!.isNotEmpty) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: uri!,
                    version: QrVersions.auto,
                    size: 190,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: _LoginScreenState._buttonColor,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: _LoginScreenState._buttonColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isArabic
                    ? 'امسح الباركود باستخدام تطبيق المصادقة'
                    : 'Scan the QR code with your authenticator app',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6D6862),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: secret!));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic ? 'تم نسخ مفتاح الإعداد' : 'Setup key copied',
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(155),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  secret!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: codeController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) => onSubmitted(),
            decoration: decoration,
          ),
        ],
      ),
    );
  }
}
