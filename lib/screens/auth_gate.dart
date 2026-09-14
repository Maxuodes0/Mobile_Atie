import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../data/models/user.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';
import 'onboarding_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Delay to ensure the widget tree is ready (avoids setState during build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppServices.session.restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppServices.session.restoring,
      builder: (context, restoring, _) {
        return ValueListenableBuilder<User?>(
          valueListenable: AppServices.session.user,
          builder: (context, user, __) {
            if (restoring) {
              return const _AiteBootstrapScreen();
            }
            return user == null ? const AiteOnboarding() : const AppShell();
          },
        );
      },
    );
  }
}

class _AiteBootstrapScreen extends StatelessWidget {
  const _AiteBootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.landingBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 104,
              height: 104,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
