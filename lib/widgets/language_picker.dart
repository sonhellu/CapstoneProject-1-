import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class LanguagePicker extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  
  const LanguagePicker({super.key, this.onLanguageChanged});

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  String _currentLanguage = 'en';
  String _selectedLanguage = 'en'; // For modal selection

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
      _selectedLanguage = _currentLanguage; // Initialize selected language
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    
    // Call the callback to change language immediately
    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!(languageCode);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Language changed to ${_getLanguageName(languageCode)}'),
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
    _selectedLanguage = _currentLanguage;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.all(24),
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
                      // Header with animation
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value,
                              child: Row(
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
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Scrollable language options
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildAnimatedLanguageOption(
                                context,
                                code: 'en',
                                flag: '🇺🇸',
                                name: AppLocalizations.of(context).english,
                                nativeName: 'English',
                                delay: 0,
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedLanguageOption(
                                context,
                                code: 'ko',
                                flag: '🇰🇷',
                                name: AppLocalizations.of(context).korean,
                                nativeName: '한국어',
                                delay: 100,
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedLanguageOption(
                                context,
                                code: 'vi',
                                flag: '🇻🇳',
                                name: AppLocalizations.of(context).vietnamese,
                                nativeName: 'Tiếng Việt',
                                delay: 200,
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedLanguageOption(
                                context,
                                code: 'zh',
                                flag: '🇨🇳',
                                name: AppLocalizations.of(context).chinese,
                                nativeName: '中文',
                                delay: 300,
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedLanguageOption(
                                context,
                                code: 'ja',
                                flag: '🇯🇵',
                                name: AppLocalizations.of(context).japanese,
                                nativeName: '日本語',
                                delay: 400,
                                setDialogState: setDialogState,
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedLanguageOption(
                                context,
                                code: 'my',
                                flag: '🇲🇲',
                                name: AppLocalizations.of(context).myanmar,
                                nativeName: 'မြန်မာ',
                                delay: 500,
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedLanguageOption(
    BuildContext context, {
    required String code,
    required String flag,
    required String name,
    required String nativeName,
    required int delay,
    required StateSetter setDialogState,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedLanguage == code;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () {
                setDialogState(() {
                  _selectedLanguage = code;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? (isDark ? Colors.red[900] : Colors.red[50])
                    : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                      ? Colors.red[300]! 
                      : isDark 
                          ? Colors.grey[600]! 
                          : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Flag with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? (isDark ? Colors.red[800] : Colors.red[100])
                          : (isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        flag,
                        style: const TextStyle(fontSize: 24),
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
                    
                    // Selection indicator with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      padding: const EdgeInsets.all(6),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton(BuildContext context, bool isDark, StateSetter setDialogState) {
    final hasChanged = _selectedLanguage != _currentLanguage;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                // Cancel button
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasChanged ? () {
                      if (_selectedLanguage != _currentLanguage) {
                        _changeLanguage(_selectedLanguage);
                      }
                      Navigator.pop(context);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasChanged ? Colors.red[600] : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: hasChanged ? 4 : 0,
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hasChanged ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showLanguageDialog,
      icon: Container(
        padding: const EdgeInsets.all(8),
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