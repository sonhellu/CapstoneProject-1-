// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ 빠져있던 import
import 'router.dart';
import 'theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/providers/locale_provider.dart';
import 'package:hi_cam_app/l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createRouter();
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: lightTheme,       
      darkTheme: darkTheme,    
      routerConfig: router,
      supportedLocales: const [Locale('en'), Locale('ko'), Locale('vi')],
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
    );
  }
}
