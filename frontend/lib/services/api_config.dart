/// API Configuration - Optimized
class ApiConfig {
  // Environment-based URLs
  static const String _prodUrl = 'https://hicampus.onrender.com';
  static const String _devUrl = 'http://127.0.0.1:5000';
  
  // Toggle between production and development
  static const bool _isProduction = true; // Set to true for production deployment
  
  static String get baseUrl => _isProduction ? _prodUrl : _devUrl;
  
  // Auth endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  
  // Community endpoints
  static String boardPostsEndpoint(int boardId) => '/api/board/$boardId/posts';
  static String createPostEndpoint(int boardId) => '/api/board/$boardId/posts';
  static String deletePostEndpoint(int postId) => '/api/posts/$postId';
  static String translatePostEndpoint(int postId) => '/api/posts/$postId/translate';
  static String allPostsEndpoint = '/api/posts/all';
  
  // School endpoints
  static const String schoolTranslationEndpoint = '/api/school/my-homepage-translation';
  
  // Matching endpoints
  static const String matchRequestsEndpoint = '/api/match_requests';
  static String findHelpersEndpoint(int requestId) => '/api/match_requests/$requestId/find_helpers';
  static String offerMatchEndpoint(int requestId) => '/api/match_requests/$requestId/offer';
  static String acceptMatchEndpoint(int requestId) => '/api/match_requests/$requestId/accept';
  static const String conversationsEndpoint = '/api/conversations';
  static String conversationEndpoint(int convId) => '/api/conversations/$convId';
  static String conversationMessagesEndpoint(int convId) => '/api/conversations/$convId/messages';
  static String conversationMessagesPollEndpoint(int convId) => '/api/conversations/$convId/messages/poll';
  static String deleteMessageEndpoint(int convId, int messageId) => '/api/conversations/$convId/messages/$messageId';
  static String markConversationReadEndpoint(int convId) => '/api/conversations/$convId/read';
  
  // Translation endpoints
  static const String translateEndpoint = '/api/translate';
  
  // Options endpoints (for registration dropdowns)
  static const String schoolsEndpoint = '/api/options/schools';
  static const String languagesEndpoint = '/api/options/languages';
  static const String countriesEndpoint = '/api/options/countries';
  static String departmentsEndpoint(int schoolId) => '/api/options/departments?school_id=$schoolId';
  static String collegesEndpoint(int schoolId) => '/api/options/colleges?school_id=$schoolId';
  
  // Profile endpoints
  static const String myProfileEndpoint = '/api/profile/me';
  static String userProfileEndpoint(int userId) => '/api/profile/$userId';
  
  // Timeout settings - Optimized for Render (cold start)
  static const Duration connectTimeout = Duration(seconds: 30); // Increased for Render cold start
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Retry settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Cache settings
  static const Duration cacheTimeout = Duration(minutes: 5);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers with auth token
  static Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  // Helper methods
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  // Environment info
  static String get environment => _isProduction ? 'Production' : 'Development';
}

