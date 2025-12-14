import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/news_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/multi_step_register_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => NewsProvider()),
      ],
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
  // Temporarily disable API authentication - Set true to bypass login
  static const bool BYPASS_AUTH = false;
  
  Locale _locale = const Locale('en', '');
  bool _isLoggedIn = false;
  bool _isLoading = true;
  Key _materialAppKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadAppState();
  }

  Future<void> _loadAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Ưu tiên dùng main_language từ profile, nếu không có thì dùng language
      String savedLanguage = prefs.getString('mainLanguage') ?? 
                            prefs.getString('language') ?? 
                            'en';
      
      // Bypass authentication nếu flag được bật
      final isLoggedIn = BYPASS_AUTH ? true : (prefs.getBool('isLoggedIn') ?? false);
      
      if (mounted) {
        setState(() {
          _locale = Locale(savedLanguage, '');
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Nếu bypass auth, vẫn set logged in
          if (BYPASS_AUTH) {
            _isLoggedIn = true;
          }
        });
      }
    }
  }

  // Method to reload app state (useful after registration)
  Future<void> reloadAppState() async {
    await _loadAppState();
  }

  // Method to be called from language picker - Optimized
  void changeLanguage(String languageCode) async {
    // Early return if same language
    if (_locale.languageCode == languageCode) return;
    
    final prefs = await SharedPreferences.getInstance();
    // Sync both language and mainLanguage
    await prefs.setString('language', languageCode);
    await prefs.setString('mainLanguage', languageCode);
    
    if (mounted) {
      setState(() {
        _locale = Locale(languageCode, '');
        _materialAppKey = UniqueKey(); // Force rebuild of MaterialApp
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
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
          home: _isLoggedIn 
            ? HomeScreen(onLanguageChanged: changeLanguage) 
            : LoginScreen(onLanguageChanged: changeLanguage),
          onGenerateRoute: (settings) {
            // Lazy route generation for better performance
            switch (settings.name) {
              case '/login':
                return MaterialPageRoute(
                  builder: (_) => LoginScreen(onLanguageChanged: changeLanguage),
                );
              case '/register':
                return MaterialPageRoute(
                  builder: (_) => RegisterScreen(onLanguageChanged: changeLanguage),
                );
              case '/multi-step-register':
                return MaterialPageRoute(
                  builder: (_) => MultiStepRegisterScreen(onLanguageChanged: changeLanguage),
                );
              case '/home':
                return MaterialPageRoute(
                  builder: (_) => HomeScreen(onLanguageChanged: changeLanguage),
                );
              default:
                return null;
            }
          },
        );
      },
    );
  }
}
