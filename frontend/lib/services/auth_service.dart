import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_config.dart';

/// Authentication Service - Optimized
class AuthService {
  // Temporarily disable API authentication - Set true to bypass auth
  static const bool BYPASS_AUTH = false;
  /// Login with backend Render
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

    // Backend returns: {access_token, token_type}
    final accessToken = response['access_token'] as String?;
    
    if (accessToken == null) {
      throw ApiException('Failed to receive access token from server');
    }

    // Save login information
    await _saveLoginData(
      email: email,
      accessToken: accessToken,
    );

    return {
      'message': 'Login successful!',
      'access_token': accessToken,
    };
  }

  /// Register with backend Render
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nickname,
    required String realname,
    String? studentId, // Optional student ID
    required String gender,
    required String mainLanguage,
    required String nationalityIso2,
    required int schoolId,
    required int departmentId,
    required int enrollmentYear,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'nickname': nickname,
      'realname': realname,
      'gender': gender,
      'main_language': mainLanguage,
      'nationality_iso2': nationalityIso2,
      'school_id': schoolId,
      'department_id': departmentId,
      'enrollment_year': enrollmentYear,
    };
    
    // Add student_id only if provided
    if (studentId != null && studentId.trim().isNotEmpty) {
      body['student_id'] = studentId.trim();
    }
    
    final response = await ApiService.post(
      ApiConfig.registerEndpoint,
      body: body,
    );

    return response;
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Clear API cache
    ApiService.clearCache();
  }

  /// Check login status
  static Future<bool> isLoggedIn() async {
    // Bypass authentication if flag is enabled
    if (BYPASS_AUTH) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('accessToken');
    
    // Check both flag and token
    return isLoggedIn && token != null && token.isNotEmpty;
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
  
  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
  
  /// Get user nickname
  static Future<String?> getUserNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userNickname');
  }

  /// Save login data
  static Future<void> _saveLoginData({
    required String email,
    required String accessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('accessToken', accessToken);
    
    // Temporarily save nickname from email (will be updated when user info API is available)
    final nickname = email.split('@')[0];
    await prefs.setString('userNickname', nickname);
    await prefs.setString('userRealname', nickname);
  }
  
  /// Get headers with auth token
  static Future<Map<String, String>> getAuthHeaders() async {
    // Bypass authentication if flag is enabled - return headers without token
    if (BYPASS_AUTH) {
      return ApiConfig.headers; // Headers without Authorization
    }
    
    final token = await getAccessToken();
    if (token == null) {
      throw ApiException('Access token not found. Please login again.');
    }
    return ApiConfig.headersWithAuth(token);
  }
}

