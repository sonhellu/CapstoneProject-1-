import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/profile_service.dart';
import '../providers/news_provider.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';

class LanguagePicker extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  
  const LanguagePicker({super.key, this.onLanguageChanged});

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  String _currentLanguage = 'en';
  String _selectedLanguage = 'en'; // For modal selection
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      // Try to load from profile API first
      final prefs = await SharedPreferences.getInstance();
      
      // Ưu tiên dùng main_language từ profile, nếu không có thì dùng language
      final mainLang = prefs.getString('mainLanguage');
      final lang = prefs.getString('language');
      final savedLanguage = mainLang ?? lang ?? 'en';
      
      if (mounted) {
        setState(() {
          _currentLanguage = savedLanguage;
          _selectedLanguage = savedLanguage;
        });
      }
    } catch (e) {
      // Fallback to default
      if (mounted) {
        setState(() {
          _currentLanguage = 'en';
          _selectedLanguage = 'en';
        });
      }
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (_isUpdating) return;
    
    // Optimistic update: Update UI ngay lập tức
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    await prefs.setString('mainLanguage', languageCode);
    
    // Update local state ngay
    if (mounted) {
      setState(() {
        _currentLanguage = languageCode;
        _isUpdating = true; // Show loading indicator
      });
    }
    
    // Call the callback to change language immediately (refresh trang ngay)
    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!(languageCode);
    }
    
    // Show success message ngay
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${AppLocalizations.of(context).languageChangedTo} ${_getLanguageName(languageCode)}'),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    
    // Chạy API calls ở background (không blocking UI)
    try {
      // Clear cache cho school translation
      ApiService.clearCacheEntry(ApiConfig.schoolTranslationEndpoint);
      
      // Update profile API ở background (silently fail if not authenticated)
      ProfileService.updateMyProfile(mainLanguage: languageCode).catchError((e) {
        // Ignore if update fails - local preference is already updated
        print('Failed to update profile main_language: $e');
      });
      
      // Reload NewsProvider ở background (không blocking)
      if (mounted) {
        try {
          final newsProvider = context.read<NewsProvider>();
          // Chạy ở background, không await để không block UI
          newsProvider.setUserMainLanguage(languageCode, forceReload: true).catchError((e) {
            print('Failed to reload news: $e');
          });
        } catch (e) {
          // Ignore if NewsProvider is not available
        }
      }
      
      // Hide loading indicator sau khi hoàn thành (không cần chờ API)
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    } catch (e) {
      // Nếu có lỗi, vẫn ẩn loading indicator (UI đã được update rồi)
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
      // Không hiển thị error vì UI đã được update thành công
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ko':
        return '한국어';
      case 'vi':
        return 'Tiếng Việt';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'my':
        return 'မြန်မာ';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Reset selected language to current language when opening dialog
    setState(() {
      _selectedLanguage = _currentLanguage;
    });
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isDark 
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1E1E1E),
                            const Color(0xFF2C2C2C),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red[50]!,
                            Colors.white,
                          ],
                        ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            color: Colors.red[600],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context).selectLanguage,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.red[800],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Scrollable language options
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildLanguageOption(
                                context,
                                code: 'en',
                                flag: '🇺🇸',
                                name: AppLocalizations.of(context).english,
                                nativeName: 'English',
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildLanguageOption(
                                context,
                                code: 'ko',
                                flag: '🇰🇷',
                                name: AppLocalizations.of(context).korean,
                                nativeName: '한국어',
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildLanguageOption(
                                context,
                                code: 'vi',
                                flag: '🇻🇳',
                                name: AppLocalizations.of(context).vietnamese,
                                nativeName: 'Tiếng Việt',
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildLanguageOption(
                                context,
                                code: 'zh',
                                flag: '🇨🇳',
                                name: AppLocalizations.of(context).chinese,
                                nativeName: '中文',
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildLanguageOption(
                                context,
                                code: 'ja',
                                flag: '🇯🇵',
                                name: AppLocalizations.of(context).japanese,
                                nativeName: '日本語',
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildLanguageOption(
                                context,
                                code: 'my',
                                flag: '🇲🇲',
                                name: AppLocalizations.of(context).myanmar,
                                nativeName: 'မြန်မာ',
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      
                      // Confirm button
                      const SizedBox(height: 20),
                      _buildConfirmButton(context, isDark, setDialogState),
                      if (_isUpdating)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).updating,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String code,
    required String flag,
    required String name,
    required String nativeName,
    required StateSetter setDialogState,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedLanguage == code;
    
    return GestureDetector(
      onTap: () {
        setDialogState(() {
          _selectedLanguage = code;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? (isDark ? Colors.red[900] : Colors.red[50])
            : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? Colors.red[400]! 
              : isDark 
                  ? Colors.grey[700]! 
                  : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? (isDark ? Colors.red[800] : Colors.red[100])
                  : (isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                flag,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            
            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.red[600] : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.red[600]! : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, bool isDark, StateSetter setDialogState) {
    final hasChanged = _selectedLanguage != _currentLanguage && !_isUpdating;
    
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: TextButton(
            onPressed: _isUpdating ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: TextStyle(
                color: _isUpdating 
                  ? Colors.grey[400] 
                  : (isDark ? Colors.white70 : Colors.grey[600]),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Confirm button
        Expanded(
          child: ElevatedButton(
            onPressed: hasChanged && !_isUpdating ? () {
              Navigator.pop(context);
              _changeLanguage(_selectedLanguage);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasChanged ? Colors.red[600] : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: hasChanged ? 2 : 0,
            ),
            child: Text(
              AppLocalizations.of(context).confirm,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showLanguageDialog,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.language,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}