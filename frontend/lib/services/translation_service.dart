import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_config.dart';

/// Translation Service - Real API integration
class TranslationService {
  // Map language codes
  static const Map<String, String> _languageMap = {
    'en': 'en',
    'ko': 'ko',
    'vi': 'vi',
    'zh': 'zh',
    'ja': 'ja',
    'my': 'my',
  };

  /// Lấy ngôn ngữ hiện tại của người dùng
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'en';
  }

  /// Dịch văn bản - Real API call
  static Future<String> translateText({
    required String text,
    String? targetLanguage,
    String? sourceLanguage,
  }) async {
    if (text.trim().isEmpty) {
      return text;
    }

    try {
      // Lấy ngôn ngữ đích nếu không được chỉ định
      final targetLang = targetLanguage ?? await getCurrentLanguage();
      
      // Validate target language
      if (!_languageMap.containsKey(targetLang)) {
        throw ApiException('Unsupported target language: $targetLang');
      }

      // Prepare request body
      final requestBody = {
        'text': text,
        'target_language': targetLang,
        if (sourceLanguage != null) 'source_language': sourceLanguage,
      };

      // Call backend API
      final response = await ApiService.post(
        ApiConfig.translateEndpoint,
        body: requestBody,
      );

      // Parse response
      if (response is Map<String, dynamic>) {
        final translatedText = response['translated_text'] as String?;
        if (translatedText != null && translatedText.isNotEmpty) {
          return translatedText;
        }
        
        // If translation failed but API returned success, return original
        return response['original_text'] as String? ?? text;
      }

      // Fallback: return original text if response format is unexpected
      return text;
    } on ApiException catch (e) {
      // Re-throw API exceptions
      rethrow;
    } catch (e) {
      // For any other errors, throw ApiException
      throw ApiException('Translation failed: ${e.toString()}');
    }
  }

  /// Batch translate multiple texts
  static Future<List<String>> translateTexts({
    required List<String> texts,
    String? targetLanguage,
  }) async {
    final targetLang = targetLanguage ?? await getCurrentLanguage();
    
    // Translate all texts in parallel
    final futures = texts.map((text) => translateText(
      text: text,
      targetLanguage: targetLang,
    ));
    
    return await Future.wait(futures);
  }
}

