import 'api_service.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// Community Service - Xử lý boards và posts
class CommunityService {
  /// Lấy danh sách bài viết trong board
  static Future<List<dynamic>> getPosts({
    required int boardId,
    int limit = 20,
    bool useCache = true,
  }) async {
    final endpoint = '${ApiConfig.boardPostsEndpoint(boardId)}?limit=$limit';
    final response = await ApiService.get(endpoint, useCache: useCache);
    
    if (response is List) {
      return response;
    } else if (response is Map && response.containsKey('data')) {
      return response['data'] as List;
    }
    
    return [];
  }
  
  /// Tạo bài viết mới
  static Future<Map<String, dynamic>> createPost({
    required int boardId,
    required String title,
    required String content,
    bool isAnonymous = false,
    String? originalLang,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final body = {
      'title': title,
      'content': content,
      'is_anonymous': isAnonymous,
    };
    
    // Thêm original_lang nếu được cung cấp
    if (originalLang != null) {
      body['original_lang'] = originalLang;
    }
    
    final response = await ApiService.post(
      ApiConfig.createPostEndpoint(boardId),
      headers: headers,
      body: body,
    );
    
    // Clear cache sau khi tạo post mới
    ApiService.clearCacheEntry(ApiConfig.boardPostsEndpoint(boardId));
    
    return response;
  }
  
  /// Refresh posts (force reload từ server)
  static Future<List<dynamic>> refreshPosts({
    required int boardId,
    int limit = 20,
  }) async {
    return await getPosts(
      boardId: boardId,
      limit: limit,
      useCache: false,
    );
  }
  
  /// Xóa bài viết
  static Future<Map<String, dynamic>> deletePost({
    required int postId,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.delete(
      ApiConfig.deletePostEndpoint(postId),
      headers: headers,
    );
    
    // Clear cache sau khi xóa post
    // Cần biết boardId để clear cache, nhưng có thể clear tất cả board caches
    ApiService.clearCache();
    
    return response;
  }
}


