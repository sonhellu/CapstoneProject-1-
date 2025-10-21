import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale _locale = const Locale('en', '');
  bool _isLoggedIn = false;
  Key _materialAppKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadAppState();
  }

  Future<void> _loadAppState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language') ?? 'en';
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    setState(() {
      _locale = Locale(savedLanguage, '');
      _isLoggedIn = isLoggedIn;
    });
  }


  // Method to be called from language picker
  void changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    
    if (mounted) {
      setState(() {
        _locale = Locale(languageCode, '');
        _materialAppKey = UniqueKey(); // Force rebuild of MaterialApp
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          key: _materialAppKey,
          title: 'Hi Campus',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: _locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _isLoggedIn ? HomeScreen(onLanguageChanged: changeLanguage) : LoginScreen(onLanguageChanged: changeLanguage),
          routes: {
            '/login': (context) => LoginScreen(onLanguageChanged: changeLanguage),
            '/register': (context) => RegisterScreen(onLanguageChanged: changeLanguage),
            '/home': (context) => HomeScreen(onLanguageChanged: changeLanguage),
          },
        );
      },
    );
  }
}
