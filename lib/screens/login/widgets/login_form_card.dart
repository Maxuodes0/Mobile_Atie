import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/error_banner.dart';

class LoginFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool loading;
  final bool obscure;
  final bool submitted;
  final String? error;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String emailLabel;
  final String passwordLabel;
  final String buttonLabel;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final String emailRequired;
  final String passwordRequired;

  const LoginFormCard({
    super.key,
    required this.formKey,
    required this.loading,
    required this.obscure,
    required this.submitted,
    required this.error,
    required this.emailController,
    required this.passwordController,
    required this.emailLabel,
    required this.passwordLabel,
    required this.buttonLabel,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.emailRequired,
    required this.passwordRequired,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        autovalidateMode: submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error != null) ...[
                ErrorBanner(message: error!),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: _filledFieldDecoration(hint: emailLabel),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return emailRequired;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => onSubmit(),
                decoration: _filledFieldDecoration(
                  hint: passwordLabel,
                  suffix: IconButton(
                    onPressed: onToggleObscure,
                    splashRadius: 20,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
                validator: (v) => (v ?? '').isEmpty ? passwordRequired : null,
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.black.withAlpha(160),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _filledFieldDecoration({
  required String hint,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: AppTheme.muted.withOpacitySafe(0.85),
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    suffixIcon: suffix,
    contentPadding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
    filled: true,
    fillColor: const Color(0xFFF0F1F3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0x55000000), width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.red.shade400, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
    ),
  );
}
