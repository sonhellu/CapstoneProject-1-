import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hi_cam_app/l10n/app_localizations.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscure = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                t.login,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
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
                hintText: 'Enter your password',
                controller: passwordController,
                obscureText: obscure,
                suffix: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                ),
                validator: (value) {
                  final v = value ?? '';
                  if (v.isEmpty) return '${t.password} required';
                  if (v.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(t.forgotPassword),
                ),
              ),
              const SizedBox(height: 8),
              _GradientButton(
                text: t.login,
                onPressed: () {
                  final ok = _formKey.currentState?.validate() ?? false;
                  if (ok) {
                    context.go('/feed');
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(t.or),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleIconButton(icon: Icons.g_mobiledata, onTap: () {}),
                  const SizedBox(width: 16),
                  _CircleIconButton(icon: Icons.facebook, onTap: () {}),
                  const SizedBox(width: 16),
                  _CircleIconButton(icon: Icons.apple, onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.dontHaveAccount),
                  TextButton(
                    onPressed: () => context.go('/sign-up'),
                    child: Text(t.signUp),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        alignment: Alignment.center,
        child: Icon(icon),
      ),
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
  double _elevation = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _elevation = _focusNode.hasFocus ? 8 : 0);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        boxShadow: _elevation > 0
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
      child: Focus(
        focusNode: _focusNode,
        child: widget.child,
      ),
    );
  }
}
