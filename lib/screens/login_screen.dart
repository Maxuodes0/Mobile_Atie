import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/api/api_exception.dart';
import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import 'login/widgets/login_form_card.dart';
import 'login/widgets/login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _submitted = false;
  String? _error;

  late final AnimationController _headerAnimationController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _headerFade = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _email.dispose();
    _password.dispose();
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
      await AppServices.session.login(
        email: _email.text.trim(),
        password: _password.text,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _loginErrorMessage(e, isAr));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final topHeight = size.height * 0.55;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F8),
        body: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(
            bottom: math.max(bottomInset, safeBottom),
          ),
          child: Stack(
            children: [
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: LoginHeader(height: topHeight, title: 'Sign in'),
                ),
              ),
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsetsDirectional.fromSTEB(
                  22,
                  topHeight - 32,
                  22,
                  24,
                ),
                child: LoginFormCard(
                  formKey: _formKey,
                  loading: _loading,
                  obscure: _obscure,
                  submitted: _submitted,
                  error: _error,
                  emailController: _email,
                  passwordController: _password,
                  emailLabel: l10n.email,
                  passwordLabel: l10n.password,
                  buttonLabel: l10n.signIn,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onSubmit: _handleLogin,
                  emailRequired: l10n.emailRequired,
                  passwordRequired: l10n.passwordRequired,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
