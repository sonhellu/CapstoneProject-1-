import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// Profile Service - Handle user profile operations
class ProfileService {
  /// Get current user's profile
  static Future<Map<String, dynamic>> getMyProfile() async {
    final token = await AuthService.getAccessToken();
    if (token == null) {
      throw ApiException('Not authenticated. Please login first.');
    }
    
    final response = await ApiService.get(
      ApiConfig.myProfileEndpoint,
      headers: ApiConfig.headersWithAuth(token),
    );
    
    return response;
  }
  
  /// Get another user's profile (public)
  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final response = await ApiService.get(
      ApiConfig.userProfileEndpoint(userId),
    );
    
    return response;
  }
  
  /// Update current user's profile
  static Future<Map<String, dynamic>> updateMyProfile({
    String? nickname,
    String? realname,
    String? studentId,
    int? enrollmentYear,
    int? schoolId,
    int? departmentId,
    String? nationalityIso2,
    String? mainLanguage,
    String? gender,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null) {
      throw ApiException('Not authenticated. Please login first.');
    }
    
    // Build request body with only provided fields
    final body = <String, dynamic>{};
    if (nickname != null) body['nickname'] = nickname;
    if (realname != null) body['realname'] = realname;
    if (studentId != null) body['student_id'] = studentId;
    if (enrollmentYear != null) body['enrollment_year'] = enrollmentYear;
    if (schoolId != null) body['school_id'] = schoolId;
    if (departmentId != null) body['department_id'] = departmentId;
    if (nationalityIso2 != null) body['nationality_iso2'] = nationalityIso2;
    if (mainLanguage != null) body['main_language'] = mainLanguage;
    if (gender != null) body['gender'] = gender;
    
    final response = await ApiService.put(
      ApiConfig.myProfileEndpoint,
      body: body,
      headers: ApiConfig.headersWithAuth(token),
    );
    
    // Update local SharedPreferences after successful update
    if (response['nickname'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userNickname', response['nickname']);
    }
    if (response['realname'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRealname', response['realname']);
    }
    
    return response;
  }
}

