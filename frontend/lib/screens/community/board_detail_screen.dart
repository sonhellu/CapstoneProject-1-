// lib/screens/community/board_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/board_post.dart';
import '../../services/translation_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/community_service.dart';
import '../../constants/app_constants.dart';
import '../../providers/news_provider.dart';

class BoardDetailScreen extends StatefulWidget {
  final BoardPost post;
  const BoardDetailScreen({super.key, required this.post});

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  String _translatedTitle = '';
  String _translatedContent = '';
  bool _isTranslating = false;
  bool _isTranslated = false;
  String? _errorMessage;
  bool _isDeleting = false;

  Future<void> _translatePost() async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
      _errorMessage = null;
    });

    try {
      // Sử dụng API mới: tự động lấy original_lang từ post và main_language từ user
      final postId = int.tryParse(widget.post.id) ?? 0;
      if (postId == 0) {
        throw Exception('Invalid post ID');
      }
      
      final translationResult = await CommunityService.translatePost(postId: postId);

      if (mounted) {
        // Đảm bảo cả title và content đều được dịch
        final translatedTitle = translationResult['title']?.toString() ?? '';
        final translatedContent = translationResult['content']?.toString() ?? '';
        
        setState(() {
          // Sử dụng translated text nếu có, nếu không thì dùng original
          _translatedTitle = translatedTitle.isNotEmpty 
              ? translatedTitle.trim() 
              : widget.post.title;
          _translatedContent = translatedContent.isNotEmpty 
              ? translatedContent.trim() 
              : widget.post.content;
          _isTranslated = true;
          _isTranslating = false;
          _errorMessage = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _errorMessage = e.message;
        });
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${l10n.translationFailed}: ${e.message}'),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _translatePost,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _errorMessage = e.toString();
        });
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${l10n.translationFailed}: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showOriginal() {
    setState(() {
      _isTranslated = false;
    });
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgoShort(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgoShort(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  /// Xóa bài viết
  Future<void> _handleDeletePost() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePost),
        content: Text(l10n.deletePostConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete.split(' ').first),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await CommunityService.deletePost(postId: int.parse(widget.post.id));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.postDeleted),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Reload News section để cập nhật danh sách
        try {
          final newsProvider = context.read<NewsProvider>();
          await newsProvider.refreshNews();
        } catch (e) {
          // Ignore error if NewsProvider is not available
          print('Could not refresh news: $e');
        }
        
        // Quay lại màn hình trước
        Navigator.pop(context, true); // Return true để board_screen biết cần reload
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.cannotDeletePost}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppConstants.primaryColor,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isTranslated ? _translatedTitle : widget.post.title,
            key: ValueKey(_isTranslated ? 'translated' : 'original'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          // Translation toggle button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isTranslating
                ? Container(
                    key: const ValueKey('loading'),
                    padding: const EdgeInsets.all(12),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : IconButton(
                    key: ValueKey(_isTranslated ? 'translated' : 'original'),
                    icon: Icon(
                      _isTranslated ? Icons.language : Icons.translate,
                      color: _isTranslated ? Colors.amber[300] : Colors.white,
                    ),
                    onPressed: _isTranslated ? _showOriginal : _translatePost,
                    tooltip: _isTranslated ? l10n.showOriginal : l10n.translateText,
                  ),
          ),
          // Delete button
          if (_isDeleting)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: _handleDeletePost,
              tooltip: l10n.deletePost,
            ),
        ],
      ),
      body: _isTranslating && !_isTranslated
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translating,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content card
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section with author info
                          Row(
                            children: [
                              // Avatar circle
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE53935), Color(0xFF1E88E5)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    widget.post.author.isNotEmpty 
                                        ? widget.post.author[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Author and date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.post.author,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: isDark 
                                              ? Colors.white60 
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(widget.post.createdAt),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark 
                                                ? Colors.white60 
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Translation badge
                              if (_isTranslated)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10, 
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppConstants.primaryColor,
                                        AppConstants.primaryColor.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.translate,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.translated,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Title with animation
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _isTranslated ? _translatedTitle : widget.post.title,
                              key: ValueKey(_isTranslated ? 'translated-title' : 'original-title'),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                                color: _isTranslated 
                                    ? AppConstants.primaryColor 
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Stats row (like count, comment count)
                          Row(
                            children: [
                              _buildStatChip(
                                icon: Icons.favorite_outline,
                                count: widget.post.likeCount,
                                color: Colors.red,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 12),
                              _buildStatChip(
                                icon: Icons.comment_outlined,
                                count: widget.post.commentCount,
                                color: Colors.blue,
                                isDark: isDark,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Divider
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Content with animation
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _isTranslated ? _translatedContent : widget.post.content,
                              key: ValueKey(_isTranslated ? 'translated-content' : 'original-content'),
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.8,
                                color: isDark 
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.black87,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          
                          // Error message if any
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red[700], 
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom spacing
                  const SizedBox(height: 80),
                ],
              ),
            ),
      // Floating action buttons
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                // Share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.shareFunctionalityComingSoon),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: AppConstants.primaryColor,
              icon: const Icon(Icons.share, color: Colors.white),
              label: Text(
                l10n.shareFunctionalityComingSoon.contains('chia sẻ') 
                    ? 'Chia sẻ' 
                    : 'Share',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              onPressed: () {
                // Like functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.bookmarkFunctionalityComingSoon),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: Icon(
                Icons.favorite_border,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatChip({
    required IconData icon,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withOpacity(0.05)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
