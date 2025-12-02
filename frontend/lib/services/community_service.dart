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
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.post(
      ApiConfig.createPostEndpoint(boardId),
      headers: headers,
      body: {
        'title': title,
        'content': content,
        'is_anonymous': isAnonymous,
      },
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
}

