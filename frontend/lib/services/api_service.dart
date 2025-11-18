import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Base API Service - Xử lý HTTP requests
class ApiService {
  /// POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
      final response = await http.post(
        url,
        headers: headers ?? ApiConfig.headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.connectTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Không thể kết nối đến server. Vui lòng kiểm tra:\n'
          '1. Backend đang chạy chưa?\n'
          '2. URL trong api_config.dart đúng chưa?');
    } on TimeoutException {
      throw ApiException('Kết nối timeout. Vui lòng thử lại.');
    } catch (e) {
      throw ApiException('Lỗi: ${e.toString()}');
    }
  }

  /// Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // Parse response body
    Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      responseBody = {'message': response.body};
    }

    // Handle status codes
    if (statusCode >= 200 && statusCode < 300) {
      // Success (200, 201, etc.)
      return responseBody;
    } else if (statusCode == 401) {
      throw ApiException(responseBody['detail'] ?? 'Email hoặc mật khẩu không đúng');
    } else if (statusCode == 409) {
      throw ApiException(responseBody['detail'] ?? 'Email đã tồn tại');
    } else if (statusCode == 500) {
      throw ApiException(responseBody['detail'] ?? 'Lỗi server');
    } else {
      throw ApiException(
        responseBody['detail'] ?? 'Lỗi không xác định (Status: $statusCode)'
      );
    }
  }
}

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => message;
}

/// Timeout Exception
class TimeoutException implements Exception {
  final String message;
  
  TimeoutException([this.message = 'Connection timeout']);
  
  @override
  String toString() => message;
}

