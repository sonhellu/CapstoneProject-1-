import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/step1_basic_info.dart';
import '../features/onboarding/step2_univ_auth.dart'; 
import '../features/onboarding/step3_account_info.dart';
import '../features/onboarding/step4_profile.dart';
import '../features/onboarding/step5_terms_consent.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/home/home_shell.dart';

GoRouter createRouter() => GoRouter(
  debugLogDiagnostics: true, // 시작 시 라우트 테이블을 콘솔에 출력
  initialLocation: '/splash',
  redirect: (context, state) {
    if (state.matchedLocation == '/' || state.uri.path == '/') {
      return '/splash';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: '/onboarding-step2', builder: (c, s) => const Step2UnivAuthScreen()),
    GoRoute(path: '/onboarding-step3', builder: (c, s) => const Step3AccountInfoScreen()),
    GoRoute(path: '/onboarding-step4', builder: (c, s) => const Step4ProfileScreen()),
    GoRoute(path: '/onboarding-step5', builder: (c, s) => const Step5TermsConsentScreen()),
    GoRoute(path: '/sign-in', builder: (c, s) => const SignInScreen()),

    ShellRoute(
      builder: (context, state, child) =>
          HomeShell(child: child, location: state.uri.toString()),
      routes: [
        GoRoute(path: '/feed',     builder: (c, s) => const _Simple('Feed')),
        GoRoute(path: '/jobs',     builder: (c, s) => const _Simple('Jobs')),
        GoRoute(path: '/exchange', builder: (c, s) => const _Simple('Language Exchange')),
        GoRoute(path: '/profile',  builder: (c, s) => const _Simple('Profile')),
      ],
    ),
  ],
);

class _Simple extends StatelessWidget {
  final String text;
  const _Simple(this.text, {super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text(text)),
        body: Center(child: Text('Page: $text'))); }
