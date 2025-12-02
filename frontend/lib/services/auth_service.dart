import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_config.dart';

/// Authentication Service - Optimized
class AuthService {
  /// Login với backend Render
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

    // Backend trả về: {access_token, token_type}
    final accessToken = response['access_token'] as String?;
    
    if (accessToken == null) {
      throw ApiException('Không nhận được access token từ server');
    }

    // Lưu thông tin đăng nhập
    await _saveLoginData(
      email: email,
      accessToken: accessToken,
    );

    return {
      'message': 'Đăng nhập thành công!',
      'access_token': accessToken,
    };
  }

  /// Register với backend Render
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nickname,
    required String realname,
    required String gender,
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
        'gender': gender,
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
    
    // Clear API cache
    ApiService.clearCache();
  }

  /// Check login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('accessToken');
    
    // Kiểm tra cả flag và token
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
    
    // Tạm thời lưu nickname từ email (sẽ được cập nhật khi có API get user info)
    final nickname = email.split('@')[0];
    await prefs.setString('userNickname', nickname);
    await prefs.setString('userRealname', nickname);
  }
  
  /// Get headers with auth token
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    if (token == null) {
      throw ApiException('Không tìm thấy access token. Vui lòng đăng nhập lại.');
    }
    return ApiConfig.headersWithAuth(token);
  }
}

