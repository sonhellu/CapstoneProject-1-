/// API Configuration
class ApiConfig {
  // TODO: Thay đổi URL này theo môi trường của bạn
  // Android Emulator: 'http://10.0.2.2:8000'
  // iOS Simulator: 'http://localhost:8000' hoặc 'http://127.0.0.1:8000'
  // Real Device: 'http://YOUR_IP:8000'
  // macOS: 'http://127.0.0.1:8000' hoặc 'http://localhost:8000'
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // Auth endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  
  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Helper methods
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}

