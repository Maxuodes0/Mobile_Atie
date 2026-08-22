import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../data/models/user.dart';
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
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return user == null ? const AiteOnboarding() : const AppShell();
          },
        );
      },
    );
  }
}
