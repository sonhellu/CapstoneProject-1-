import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hi_cam_app/l10n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool obscure1 = true;
  bool obscure2 = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.createAccount)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    _LabeledField(
                      label: t.email,
                      hintText: 'email@gmail.com',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return '${t.email} required';
                        final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
                        if (!ok) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: t.password,
                      hintText: 'Create a password',
                      controller: passwordController,
                      obscureText: obscure1,
                      suffix: IconButton(
                        onPressed: () => setState(() => obscure1 = !obscure1),
                        icon: Icon(obscure1 ? Icons.visibility_off : Icons.visibility),
                      ),
                      validator: (value) {
                        final v = value ?? '';
                        if (v.isEmpty) return '${t.password} required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: t.confirmPassword,
                      hintText: 'Re-enter password',
                      controller: confirmController,
                      obscureText: obscure2,
                      suffix: IconButton(
                        onPressed: () => setState(() => obscure2 = !obscure2),
                        icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility),
                      ),
                      validator: (value) {
                        final v = value ?? '';
                        if (v.isEmpty) return 'Confirm required';
                        if (v != passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _GradientButton(
                text: t.createAccount,
                onPressed: () {
                  final ok = _formKey.currentState?.validate() ?? false;
                  if (ok) {
                    context.go('/feed');
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.alreadyHaveAccount),
                  TextButton(
                    onPressed: () => context.go('/sign-in'),
                    child: Text(t.login),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _LabeledField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        _FocusGlow(
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: label == 'Email' ? const Icon(Icons.email_outlined) : const Icon(Icons.lock_outline),
              suffixIcon: suffix,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onPressed,
            child: Center(
              child: Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusGlow extends StatefulWidget {
  final Widget child;
  const _FocusGlow({required this.child});

  @override
  State<_FocusGlow> createState() => _FocusGlowState();
}

class _FocusGlowState extends State<_FocusGlow> {
  final FocusNode _focusNode = FocusNode();
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          boxShadow: _focusNode.hasFocus
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
          borderRadius: BorderRadius.circular(28),
        ),
        child: widget.child,
      ),
    );
  }
}


