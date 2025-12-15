// lib/screens/community/board_write_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/community_service.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_constants.dart';
import '../../providers/news_provider.dart';
import 'board_screen.dart'; // BoardCategory 쓰려고 import

// Map BoardCategory to board_id
const Map<BoardCategory, int> _categoryToBoardId = {
  BoardCategory.notice: 1,
  BoardCategory.free: 2,
  BoardCategory.info: 3,
  BoardCategory.promo: 4,
};

class BoardWriteScreen extends StatefulWidget {
  final BoardCategory? initialCategory; // Optional: default category if provided

  const BoardWriteScreen({super.key, this.initialCategory});

  @override
  State<BoardWriteScreen> createState() => _BoardWriteScreenState();
}

class _BoardWriteScreenState extends State<BoardWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;
  BoardCategory? _selectedCategory; // Selected board category
  String? _selectedLanguage; // Selected language for the post

  // Supported languages for posts
  static const List<Map<String, String>> _languages = [
    {'code': 'ko', 'label': '한국어', 'flag': '🇰🇷'},
    {'code': 'en', 'label': 'English', 'flag': '🇺🇸'},
    {'code': 'vi', 'label': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'zh', 'label': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'label': '日本語', 'flag': '🇯🇵'},
    {'code': 'my', 'label': 'မြန်မာ', 'flag': '🇲🇲'},
  ];

  @override
  void initState() {
    super.initState();
    // Set initial category if provided, otherwise default to notice
    _selectedCategory = widget.initialCategory ?? BoardCategory.notice;
    // Set default language to Korean
    _selectedLanguage = 'ko';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Validate và submit post
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate board category is selected
      if (_selectedCategory == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).pleaseSelectBoard),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final boardId = _categoryToBoardId[_selectedCategory!] ?? 1;
      
      // Validate language is selected
      if (_selectedLanguage == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).selectLanguageToLearnRequired),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final response = await CommunityService.createPost(
        boardId: boardId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        isAnonymous: _isAnonymous,
        originalLang: _selectedLanguage!,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        final l10n = AppLocalizations.of(context);
        
        // Show success notification with better UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.postPublishedSuccessfully,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        // Reload News section để hiển thị bài viết mới
        try {
          final newsProvider = context.read<NewsProvider>();
          await newsProvider.refreshNews();
        } catch (e) {
          // Ignore error if NewsProvider is not available
          print('Could not refresh news: $e');
        }
        
        // Return the category so board screen knows which category to reload
        Navigator.pop(context, _selectedCategory);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorOccurred}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: isDark 
          ? AppConstants.darkBackgroundColor
          : AppConstants.lightBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(l10n.writePost),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppGradients.darkBackgroundGradient
              : AppGradients.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main form card
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppConstants.darkCardColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header section
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE53935), Color(0xFF1E88E5)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit_note,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.writePost,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.shareYourThoughts,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Board selection dropdown
                        DropdownButtonFormField<BoardCategory>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: l10n.selectBoard,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              borderSide: BorderSide(
                                color: isDark 
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              borderSide: const BorderSide(
                                color: AppConstants.primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark 
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[50],
                            prefixIcon: const Icon(
                              Icons.dashboard,
                              color: AppConstants.primaryColor,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          dropdownColor: isDark 
                              ? AppConstants.darkCardColor
                              : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                          items: BoardCategory.values.map((category) {
                            String label;
                            switch (category) {
                              case BoardCategory.notice:
                                label = l10n.noticeBoard;
                                break;
                              case BoardCategory.free:
                                label = l10n.freeBoard;
                                break;
                              case BoardCategory.info:
                                label = l10n.infoBoard;
                                break;
                              case BoardCategory.promo:
                                label = l10n.promoBoard;
                                break;
                            }
                            return DropdownMenuItem<BoardCategory>(
                              value: category,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return l10n.pleaseSelectBoard;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Language selection dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedLanguage,
                          decoration: InputDecoration(
                            labelText: l10n.mainLanguage,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              borderSide: BorderSide(
                                color: isDark 
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              borderSide: const BorderSide(
                                color: AppConstants.primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark 
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[50],
                            prefixIcon: const Icon(
                              Icons.language,
                              color: AppConstants.primaryColor,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          dropdownColor: isDark 
                              ? AppConstants.darkCardColor
                              : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                          items: _languages.map((lang) {
                            return DropdownMenuItem<String>(
                              value: lang['code'],
                              child: Row(
                                children: [
                                  Text(
                                    lang['flag']!,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    lang['label']!,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return l10n.selectLanguageToLearnRequired;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Title field
                        TextFormField(
                          controller: _titleController,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.title,
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              borderSide: BorderSide(
                                color: isDark 
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              borderSide: const BorderSide(
                                color: AppConstants.primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark 
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[50],
                            prefixIcon: Icon(
                              Icons.title,
                              color: AppConstants.primaryColor,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.titleRequired;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Content field
                        Container(
                          constraints: const BoxConstraints(minHeight: 200),
                          child: TextFormField(
                            controller: _contentController,
                            maxLines: null,
                            minLines: 8,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.content,
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey[600],
                              ),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                borderSide: BorderSide(
                                  color: isDark 
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                borderSide: const BorderSide(
                                  color: AppConstants.primaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: isDark 
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey[50],
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 140),
                                child: Icon(
                                  Icons.article,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.contentRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Anonymous checkbox with better styling
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            border: Border.all(
                              color: isDark 
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              l10n.writeAnonymously,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            value: _isAnonymous,
                            onChanged: (value) {
                              setState(() {
                                _isAnonymous = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons with better styling
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: isDark 
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey[400]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: AppConstants.primaryColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.post,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Bottom spacing for safe area
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
