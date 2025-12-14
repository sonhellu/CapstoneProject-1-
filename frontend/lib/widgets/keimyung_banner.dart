import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/school_service.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';

class KeimyungBanner extends StatefulWidget {
  const KeimyungBanner({super.key});

  @override
  State<KeimyungBanner> createState() => _KeimyungBannerState();
}

class _KeimyungBannerState extends State<KeimyungBanner> with WidgetsBindingObserver {
  String _schoolName = 'Keimyung University';
  String _schoolUrl = 'kmu.ac.kr';
  String? _translatedUrl;
  bool _isLoading = true;
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentLanguage();
    _loadSchoolInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if language changed
    final locale = Localizations.localeOf(context);
    final newLanguage = locale.languageCode;
    if (newLanguage != _currentLanguage) {
      _currentLanguage = newLanguage;
      // Reload school info with new language
      _loadSchoolInfo(forceRefresh: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload school info when app resumes (user might have changed school or language)
    if (state == AppLifecycleState.resumed) {
      _loadCurrentLanguage();
      _loadSchoolInfo(forceRefresh: true);
    }
  }

  Future<void> _loadCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('mainLanguage') ?? 
                  prefs.getString('language') ?? 
                  'en';
      _currentLanguage = lang;
    } catch (e) {
      _currentLanguage = 'en';
    }
  }

  Future<void> _loadSchoolInfo({bool forceRefresh = false}) async {
    try {
      // Clear cache nếu force refresh hoặc language đã đổi
      if (forceRefresh) {
        ApiService.clearCacheEntry(ApiConfig.schoolTranslationEndpoint);
      }
      
      // Load current language để đảm bảo có ngôn ngữ mới nhất
      await _loadCurrentLanguage();
      
      final schoolInfo = await SchoolService.getMySchoolTranslation(useCache: !forceRefresh);
      
      if (mounted) {
        setState(() {
          _schoolName = schoolInfo['school_name'] ?? 'Keimyung University';
          final originalUrl = schoolInfo['original_url'] as String? ?? '';
          _translatedUrl = schoolInfo['translated_url'] as String?;
          
          // Extract domain from URL
          if (originalUrl.isNotEmpty) {
            try {
              final uri = Uri.parse(originalUrl);
              _schoolUrl = uri.host.replaceAll('www.', '');
            } catch (e) {
              _schoolUrl = 'kmu.ac.kr';
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      // If API fails or any error, keep default values
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Public method to reload school info (can be called from outside)
  void reloadSchoolInfo() {
    _loadSchoolInfo(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      // Thay đổi dòng 15 trong keimyung_banner.dart
      margin: const EdgeInsets.only(
        top: 8,
        bottom: 8,
      ), // Chỉ giữ margin vertical
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey[300]!,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => _launchSchoolWebsite(),
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/kmubanner.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1E3A8A),
                                Color(0xFF3B82F6),
                                Color(0xFF60A5FA),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.black.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Background pattern
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // University Logo/Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Color(0xFF1E3A8A),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // University Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _schoolName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context).visitOfficialWebsite,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Arrow icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Click indicator
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.open_in_new,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _schoolUrl,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchSchoolWebsite() async {
    // Đảm bảo có translated URL mới nhất trước khi mở
    // Nếu đang loading hoặc không có translated URL, reload trước
    if (_isLoading || _translatedUrl == null || _translatedUrl!.isEmpty) {
      // Force reload để lấy translated URL mới nhất
      await _loadSchoolInfo(forceRefresh: true);
      
      // Nếu vẫn không có sau khi reload, dùng fallback
      if (_translatedUrl == null || _translatedUrl!.isEmpty) {
        _loadTranslatedUrlFallback();
        return;
      }
    }
    
    String urlString = _translatedUrl!;
    final Uri url = Uri.parse(urlString);

    try {
      // Simple approach - try platformDefault first
      await launchUrl(url, mode: LaunchMode.platformDefault);
    } catch (e) {
      // If platformDefault fails, try externalApplication
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e2) {
        // If both fail, try inAppWebView as last resort
        try {
          await launchUrl(url, mode: LaunchMode.inAppWebView);
        } catch (e3) {
          // All methods failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppLocalizations.of(context).cannotOpenWebsite}: ${e3.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }
  
  /// Fallback: Tạo link dịch Google Translate với ngôn ngữ hiện tại
  void _loadTranslatedUrlFallback() async {
    try {
      await _loadCurrentLanguage();
      final userLang = _currentLanguage;
      final urlString = 'https://translate.google.com/translate?hl=$userLang&sl=auto&tl=$userLang&u=https://www.$_schoolUrl/';
      final Uri url = Uri.parse(urlString);
      
      await launchUrl(url, mode: LaunchMode.platformDefault);
    } catch (e) {
      // If fallback also fails, show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).cannotOpenWebsite}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
