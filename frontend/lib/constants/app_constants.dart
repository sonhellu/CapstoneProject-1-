import 'package:flutter/material.dart';

/// Application-wide constants to replace magic numbers and strings
class AppConstants {
  // App Information
  static const String appName = 'Hello Campus';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFFD32F2F); // Red 700
  static const Color primaryLightColor = Color(0xFFFFCDD2); // Red 100
  static const Color primaryDarkColor = Color(0xFFB71C1C); // Red 900
  
  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkCardColor = Color(0xFF2C2C2C);
  
  // Light Theme Colors
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  
  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeLargeTitle = 32.0;
  
  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 12.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);
  
  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve slideCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  
  // Carousel Settings
  static const Duration carouselAutoPlayInterval = Duration(seconds: 4);
  static const Duration carouselAnimationDuration = Duration(milliseconds: 800);
  static const double carouselHeight = 200.0;
  
  // Form Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int maxEmailLength = 100;
  static const int maxNameLength = 50;
  
  // Network Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);
  
  // Storage Keys
  static const String keyLanguage = 'language';
  static const String keyTheme = 'isDarkMode';
  static const String keyLogin = 'isLoggedIn';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserNationality = 'userNationality';
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const bool defaultDarkMode = false;
  static const bool defaultLoginState = false;
  static const String defaultNationality = 'vietnam';
  
  // Error Messages
  static const String errorNetworkConnection = 'Network connection error';
  static const String errorServerError = 'Server error occurred';
  static const String errorUnknown = 'Unknown error occurred';
  static const String errorValidationFailed = 'Validation failed';
  
  // Success Messages
  static const String successLogin = 'Login successful';
  static const String successRegister = 'Registration successful';
  static const String successLogout = 'Logout successful';
  static const String successSave = 'Saved successfully';
  
  // UI Text
  static const String textFeatured = 'FEATURED';
  static const String textAuto = 'Auto';
  static const String textReadMore = 'Read More';
  static const String textToday = 'Today';
  static const String textYesterday = 'Yesterday';
  static const String textDaysAgo = 'days ago';
  
  // Icons
  static const IconData iconHome = Icons.home;
  static const IconData iconProfile = Icons.person;
  static const IconData iconChat = Icons.chat;
  static const IconData iconNotifications = Icons.notifications;
  static const IconData iconSchool = Icons.school;
  static const IconData iconEmail = Icons.email;
  static const IconData iconLock = Icons.lock;
  static const IconData iconPlay = Icons.play_arrow;
  static const IconData iconTime = Icons.access_time;
}

/// Extension methods for common operations
extension AppConstantsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  Color get primaryColor => Theme.of(this).primaryColor;
  
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// Common gradients used throughout the app
class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppConstants.primaryColor,
      AppConstants.primaryDarkColor,
    ],
  );
  
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppConstants.primaryLightColor,
      AppConstants.lightSurfaceColor,
    ],
  );
  
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppConstants.darkSurfaceColor,
      AppConstants.darkBackgroundColor,
    ],
  );
  
  static const LinearGradient cardOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black54,
    ],
  );
}
