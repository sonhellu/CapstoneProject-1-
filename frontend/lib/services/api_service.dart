import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Base API Service - Optimized với retry logic và caching
class ApiService {
  // Simple in-memory cache
  static final Map<String, _CacheEntry> _cache = {};
  
  /// GET request với caching
  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    bool useCache = true,
  }) async {
    // Check cache first
    if (useCache && _cache.containsKey(endpoint)) {
      final cacheEntry = _cache[endpoint]!;
      if (!cacheEntry.isExpired) {
        return cacheEntry.data;
      }
    }
    
    final response = await _requestWithRetry(
      () => http.get(
        Uri.parse(ApiConfig.getFullUrl(endpoint)),
        headers: headers ?? ApiConfig.headers,
      ),
    );
    
    final data = _handleResponse(response);
    
    // Cache the result
    if (useCache) {
      _cache[endpoint] = _CacheEntry(data);
    }
    
    return data;
  }

  /// POST request với retry logic
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _requestWithRetry(
      () => http.post(
        Uri.parse(ApiConfig.getFullUrl(endpoint)),
        headers: headers ?? ApiConfig.headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );

    return _handleResponse(response);
  }
  
  /// PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _requestWithRetry(
      () => http.put(
        Uri.parse(ApiConfig.getFullUrl(endpoint)),
        headers: headers ?? ApiConfig.headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );

    return _handleResponse(response);
  }
  
  /// DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final response = await _requestWithRetry(
      () => http.delete(
        Uri.parse(ApiConfig.getFullUrl(endpoint)),
        headers: headers ?? ApiConfig.headers,
      ),
    );

    return _handleResponse(response);
  }

  /// Request với retry logic
  static Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() request,
  ) async {
    int retries = 0;
    
    while (retries < ApiConfig.maxRetries) {
      try {
        final response = await request().timeout(ApiConfig.connectTimeout);
        
        // If success or client error (4xx), return immediately
        if (response.statusCode < 500) {
          return response;
        }
        
        // If server error (5xx), retry
        if (retries < ApiConfig.maxRetries - 1) {
          await Future.delayed(ApiConfig.retryDelay * (retries + 1));
          retries++;
          continue;
        }
        
        return response;
      } on SocketException catch (e) {
        if (retries < ApiConfig.maxRetries - 1) {
          await Future.delayed(ApiConfig.retryDelay * (retries + 1));
          retries++;
          continue;
        }
        throw ApiException(
          'Cannot connect to server.\n'
          'Please check your network connection.\n'
          'Environment: ${ApiConfig.environment}\n'
          'Error: ${e.message}'
        );
      } on TimeoutException {
        if (retries < ApiConfig.maxRetries - 1) {
          await Future.delayed(ApiConfig.retryDelay * (retries + 1));
          retries++;
          continue;
        }
        throw ApiException(
          'Connection timeout after ${ApiConfig.maxRetries} attempts.\n'
          'Server may be starting up (Render cold start).\n'
          'Please try again in a few minutes.'
        );
      } catch (e) {
        if (retries < ApiConfig.maxRetries - 1) {
          await Future.delayed(ApiConfig.retryDelay * (retries + 1));
          retries++;
          continue;
        }
        throw ApiException('Error: ${e.toString()}');
      }
    }
    
    throw ApiException('Failed after ${ApiConfig.maxRetries} attempts');
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
      throw ApiException(
        responseBody['error'] ?? 
        responseBody['detail'] ?? 
        'Invalid email or password'
      );
    } else if (statusCode == 409) {
      throw ApiException(
        responseBody['error'] ?? 
        responseBody['detail'] ?? 
        'Email already exists'
      );
    } else if (statusCode == 500) {
      throw ApiException(
        responseBody['error'] ?? 
        responseBody['detail'] ?? 
        'Server error. Please try again later.'
      );
    } else {
      throw ApiException(
        responseBody['error'] ?? 
        responseBody['detail'] ?? 
        'Unknown error (Status: $statusCode)'
      );
    }
  }
  
  /// Clear cache
  static void clearCache() {
    _cache.clear();
  }
  
  /// Clear specific cache entry
  static void clearCacheEntry(String endpoint) {
    _cache.remove(endpoint);
  }
}

/// Cache entry
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  
  _CacheEntry(this.data) : timestamp = DateTime.now();
  
  bool get isExpired {
    return DateTime.now().difference(timestamp) > ApiConfig.cacheTimeout;
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

