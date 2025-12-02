import 'api_service.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// School Service - Xử lý thông tin trường học
class SchoolService {
  /// Lấy URL dịch trang chủ trường của user
  static Future<Map<String, dynamic>> getMySchoolTranslation({
    bool useCache = true,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.get(
      ApiConfig.schoolTranslationEndpoint,
      headers: headers,
      useCache: useCache,
    );
    
    return response as Map<String, dynamic>;
  }
  
  /// Mở trang chủ trường đã dịch
  /// Trả về URL để mở trong browser hoặc WebView
  static Future<String> getTranslatedSchoolUrl() async {
    final data = await getMySchoolTranslation();
    return data['translated_url'] as String;
  }
  
  /// Lấy thông tin trường
  static Future<Map<String, dynamic>> getSchoolInfo() async {
    final data = await getMySchoolTranslation();
    return {
      'school_id': data['school_id'],
      'school_name': data['school_name'],
      'original_url': data['original_url'],
      'target_language': data['target_language'],
    };
  }
}

