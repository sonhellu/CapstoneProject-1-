import 'api_service.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// Matching Service - Xử lý kết nối mentor-mentee và chat
class MatchingService {
  /// Tạo yêu cầu tìm helper
  static Future<Map<String, dynamic>> createMatchRequest({
    required String targetLanguage, // Required: Ngôn ngữ muốn học
    int? preferredCollegeId,
    String preferredGender = 'any',
    String? notes,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final body = <String, dynamic>{
      'target_language': targetLanguage, // Required
      'preferred_gender': preferredGender,
    };
    
    if (preferredCollegeId != null) {
      body['preferred_college_id'] = preferredCollegeId;
    }
    
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }
    
    final response = await ApiService.post(
      ApiConfig.matchRequestsEndpoint,
      headers: headers,
      body: body,
    );
    
    return response;
  }
  
  /// Tìm helper phù hợp
  static Future<List<dynamic>> findHelpers({
    required int requestId,
    int limit = 10,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final endpoint = '${ApiConfig.findHelpersEndpoint(requestId)}?limit=$limit';
    final response = await ApiService.get(
      endpoint,
      headers: headers,
      useCache: false, // Don't cache to get latest data
    );
    
    if (response is List) {
      return response;
    }
    
    return [];
  }
  
  /// Đề xuất helper cho request
  static Future<Map<String, dynamic>> offerMatch({
    required int requestId,
    required int mentorUserId,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.post(
      ApiConfig.offerMatchEndpoint(requestId),
      headers: headers,
      body: {
        'mentor_user_id': mentorUserId,
      },
    );
    
    return response;
  }
  
  /// Chấp nhận kết nối
  static Future<Map<String, dynamic>> acceptMatch({
    required int requestId,
    required int mentorUserId,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.post(
      ApiConfig.acceptMatchEndpoint(requestId),
      headers: headers,
      body: {
        'mentor_user_id': mentorUserId,
      },
    );
    
    return response;
  }
  
  /// Poll for new messages (Long Polling)
  static Future<List<dynamic>> pollMessages({
    required int conversationId,
    int? lastMessageId,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    String endpoint = ApiConfig.conversationMessagesPollEndpoint(conversationId);
    if (lastMessageId != null) {
      endpoint += '?last_message_id=$lastMessageId';
    }
    
    final response = await ApiService.get(
      endpoint,
      headers: headers,
      useCache: false, // Never cache polling results
    );
    
    if (response is Map && response.containsKey('messages')) {
      return response['messages'] as List<dynamic>? ?? [];
    }
    
    return [];
  }

  /// Gửi tin nhắn
  static Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.post(
      ApiConfig.conversationMessagesEndpoint(conversationId),
      headers: headers,
      body: {
        'content': content,
      },
    );
    
    // Clear cache to get new messages
    ApiService.clearCacheEntry(
      ApiConfig.conversationMessagesEndpoint(conversationId),
    );
    
    return response;
  }
  
  /// Xóa tin nhắn
  static Future<Map<String, dynamic>> deleteMessage({
    required int conversationId,
    required int messageId,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.delete(
      ApiConfig.deleteMessageEndpoint(conversationId, messageId),
      headers: headers,
    );
    
    // Clear cache to refresh messages list
    ApiService.clearCacheEntry(
      ApiConfig.conversationMessagesEndpoint(conversationId),
    );
    
    return response;
  }
  
  /// Lấy danh sách tin nhắn (trả về Map với messages và match_status)
  static Future<Map<String, dynamic>> getMessages({
    required int conversationId,
    bool useCache = false, // Default no cache to get latest messages
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.get(
      ApiConfig.conversationMessagesEndpoint(conversationId),
      headers: headers,
      useCache: useCache,
    );
    
    if (response is Map<String, dynamic>) {
      return response;
    }
    
    // Fallback for old format (List)
    if (response is List) {
      return {
        'messages': response,
        'match_status': null,
        'match_id': null,
      };
    }
    
    return {
      'messages': [],
      'match_status': null,
      'match_id': null,
    };
  }
  
  /// Refresh messages (force reload)
  static Future<List<dynamic>> refreshMessages({
    required int conversationId,
  }) async {
    final response = await MatchingService.getMessages(
      conversationId: conversationId,
      useCache: false,
    );
    
    if (response is Map<String, dynamic> && response.containsKey('messages')) {
      final messages = response['messages'];
      if (messages is List) {
        return messages;
      }
    }
    
    return [];
  }
  
  /// Lấy danh sách tất cả conversations của user
  static Future<List<dynamic>> getConversations() async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.get(
      ApiConfig.conversationsEndpoint,
      headers: headers,
      useCache: false, // Don't cache to get latest conversations
    );
    
    if (response is List) {
      return response;
    }
    
    return [];
  }
  
  /// Đánh dấu conversation đã đọc
  static Future<Map<String, dynamic>> markConversationRead({
    required int conversationId,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final response = await ApiService.put(
      ApiConfig.markConversationReadEndpoint(conversationId),
      headers: headers,
    );
    
    return response;
  }
  
  /// Xóa conversation (xóa participation của user)
  static Future<Map<String, dynamic>> deleteConversation({
    required int conversationId,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    final endpoint = ApiConfig.conversationEndpoint(conversationId);
    print('Deleting conversation at: ${ApiConfig.getFullUrl(endpoint)}');
    
    try {
      final response = await ApiService.delete(
        endpoint,
        headers: headers,
      );
      
      print('Delete API response type: ${response.runtimeType}');
      print('Delete API response: $response');
      
      // Ensure response is a Map
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      // If response is not a Map (could be empty or other type), return success
      return {
        'message': 'Conversation deleted successfully',
        'conversation_id': conversationId
      };
    } catch (e) {
      print('Error in deleteConversation: $e');
      rethrow;
    }
  }
}
