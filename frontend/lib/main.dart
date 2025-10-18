import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MainApp());
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
  void changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode, '');
      _materialAppKey = UniqueKey(); // Force rebuild of MaterialApp
    });
    
    // Add a small delay for smooth transition
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          // Trigger a subtle rebuild for smooth transition
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: _materialAppKey,
      title: 'Hello Campus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red[600],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[600]!, width: 2),
          ),
        ),
        useMaterial3: true,
      ),
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
  }
}
