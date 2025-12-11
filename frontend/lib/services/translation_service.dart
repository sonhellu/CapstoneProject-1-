import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Translation Service với fake API (mock data)
/// TODO: Thay thế bằng real API khi backend sẵn sàng
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

  /// Dịch văn bản (Fake API - Mock data)
  /// Simulate API call với delay và fake translation
  static Future<String> translateText({
    required String text,
    String? targetLanguage,
    String? sourceLanguage,
  }) async {
    // Simulate API delay (1-2 seconds)
    await Future.delayed(Duration(milliseconds: 800 + (text.length % 1000)));

    // Lấy ngôn ngữ đích nếu không được chỉ định
    final targetLang = targetLanguage ?? await getCurrentLanguage();

    // Fake translation - thêm prefix để show đã dịch
    // TODO: Thay thế bằng real API call
    return _fakeTranslate(text, targetLang);
  }

  /// Fake translation function
  /// Trong thực tế, đây sẽ là API call đến backend
  static String _fakeTranslate(String text, String targetLang) {
    // Mock translations based on target language
    // Trong production, đây sẽ là response từ API
    final prefix = _getTranslationPrefix(targetLang);
    return '$prefix$text';
  }

  /// Get translation prefix based on language (for demo)
  static String _getTranslationPrefix(String lang) {
    switch (lang) {
      case 'ko':
        return '[한국어] ';
      case 'vi':
        return '[Tiếng Việt] ';
      case 'zh':
        return '[中文] ';
      case 'ja':
        return '[日本語] ';
      case 'my':
        return '[မြန်မာ] ';
      case 'en':
      default:
        return '[English] ';
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

