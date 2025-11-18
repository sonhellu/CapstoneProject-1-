import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_config.dart';

/// Authentication Service
class AuthService {
  /// Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiConfig.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
    );

    // Lưu thông tin đăng nhập
    await _saveLoginData(
      email: email,
      userData: response['user'] ?? {},
    );

    return response;
  }

  /// Register
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nickname,
    required String realname,
    required String mainLanguage,
    required String nationalityIso2,
    required int schoolId,
    required int departmentId,
    required int enrollmentYear,
  }) async {
    final response = await ApiService.post(
      ApiConfig.registerEndpoint,
      body: {
        'email': email,
        'password': password,
        'nickname': nickname,
        'realname': realname,
        'main_language': mainLanguage,
        'nationality_iso2': nationalityIso2,
        'school_id': schoolId,
        'department_id': departmentId,
        'enrollment_year': enrollmentYear,
      },
    );

    return response;
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Check login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  /// Save login data
  static Future<void> _saveLoginData({
    required String email,
    Map<String, dynamic>? userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    
    if (userData != null && userData.isNotEmpty) {
      await prefs.setString('userNickname', userData['nickname'] ?? '');
      await prefs.setString('userRealname', userData['realname'] ?? '');
    }
  }
}

