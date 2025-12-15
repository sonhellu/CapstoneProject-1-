// lib/screens/community/board_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/board_post.dart';
import '../../services/community_service.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/date_time_utils.dart';
import 'board_detail_screen.dart';
import 'board_write_screen.dart';

// 4개 게시판 종류
enum BoardCategory { notice, free, info, promo }

String _getCategoryLabel(BuildContext context, BoardCategory category) {
  final l10n = AppLocalizations.of(context);
  switch (category) {
    case BoardCategory.notice:
      return l10n.noticeBoard;
    case BoardCategory.free:
      return l10n.freeBoard;
    case BoardCategory.info:
      return l10n.infoBoard;
    case BoardCategory.promo:
      return l10n.promoBoard;
  }
}

// Map BoardCategory to board_id (backend)
const Map<BoardCategory, int> _categoryToBoardId = {
  BoardCategory.notice: 1,
  BoardCategory.free: 2,
  BoardCategory.info: 3,
  BoardCategory.promo: 4,
};

class BoardScreen extends StatefulWidget {
  final BoardCategory initialCategory;

  const BoardScreen({
    Key? key,
    this.initialCategory = BoardCategory.notice,
  }) : super(key: key);

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late BoardCategory _selected;
  List<BoardPost> _posts = [];
  bool _isLoading = false;
  String? _error;
  
  // Cache posts cho mỗi category để chuyển đổi mượt mà hơn
  final Map<BoardCategory, List<BoardPost>> _postsCache = {};
  final Map<BoardCategory, String?> _errorCache = {};

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCategory;
    _loadPosts();
  }

  /// Load posts from API
  Future<void> _loadPosts({bool forceRefresh = false}) async {
    if (!mounted) return;
    
    // Nếu đã có cache và không force refresh, dùng cache ngay
    if (!forceRefresh && _postsCache.containsKey(_selected)) {
      setState(() {
        _posts = _postsCache[_selected]!;
        _error = _errorCache[_selected];
        _isLoading = false;
      });
      // Load trong background để cập nhật
      _loadPostsInBackground();
      return;
    }
    
    setState(() {
      _isLoading = true;
      // Giữ lại posts cũ khi đang load để transition mượt hơn
      if (!_postsCache.containsKey(_selected)) {
        _error = null;
      } else {
        _error = _errorCache[_selected];
      }
    });

    try {
      final boardId = _categoryToBoardId[_selected] ?? 1;
      
      // Use refreshPosts if forceRefresh is true (after creating new post)
      final postsData = forceRefresh
          ? await CommunityService.refreshPosts(boardId: boardId, limit: 20)
          : await CommunityService.getPosts(boardId: boardId, limit: 20);

      final posts = postsData.map((postData) {
        return BoardPost.fromJson(postData as Map<String, dynamic>);
      }).toList();

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
          _error = null;
        });
        // Cache posts
        _postsCache[_selected] = posts;
        _errorCache[_selected] = null;
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
        _errorCache[_selected] = e.message;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '${AppLocalizations.of(context).errorLoadingData}: ${e.toString()}';
          _isLoading = false;
        });
        _errorCache[_selected] = _error;
      }
    }
  }
  
  /// Load posts trong background để cập nhật cache
  Future<void> _loadPostsInBackground() async {
    try {
      final boardId = _categoryToBoardId[_selected] ?? 1;
      final postsData = await CommunityService.getPosts(boardId: boardId, limit: 20);
      final posts = postsData.map((postData) {
        return BoardPost.fromJson(postData as Map<String, dynamic>);
      }).toList();
      
      if (mounted && _selected == _selected) {
        setState(() {
          _postsCache[_selected] = posts;
          _errorCache[_selected] = null;
          if (!_isLoading) {
            _posts = posts;
          }
        });
      }
    } catch (e) {
      // Silent fail for background refresh
    }
  }

  /// Refresh posts
  Future<void> _refreshPosts() async {
    await _loadPosts();
  }

  /// Handle delete post
  Future<void> _handleDeletePost(BoardPost post) async {
    try {
      final postId = int.tryParse(post.id) ?? 0;
      if (postId == 0) {
        throw Exception('Invalid post ID');
      }
      await CommunityService.deletePost(postId: postId);
      if (mounted) {
        // Clear cache và reload posts after deletion
        _postsCache.remove(_selected);
        _errorCache.remove(_selected);
        await _loadPosts(forceRefresh: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorOccurred}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<BoardPost> get _currentPosts => _posts;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final posts = _currentPosts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: Text(
          _getCategoryLabel(context, _selected),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final result = await showSearch<BoardPost?>(
                context: context,
                delegate: _BoardSearchDelegate(posts),
              );
              if (result != null && context.mounted) {
                final deleted = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoardDetailScreen(post: result),
                  ),
                );
                
                // Reload posts if post was deleted
                if (deleted == true && mounted) {
                  await _loadPosts(forceRefresh: true);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      BoardWriteScreen(initialCategory: _selected),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
              
              // Reload posts if post was created successfully
              // result will be the BoardCategory if post was created
              if (result != null && result is BoardCategory && mounted) {
                // Ensure we're on the correct category
                if (result == _selected) {
                  // Reload posts for current category (force refresh to get new post)
                  await _loadPosts(forceRefresh: true);
                } else {
                  // Switch to the category where post was created and reload
                  setState(() {
                    _selected = result;
                  });
                  await _loadPosts(forceRefresh: true);
                }
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppGradients.darkBackgroundGradient
              : AppGradients.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshPosts,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryTabs(isDark),
                  const SizedBox(height: AppConstants.spacingL),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: _buildPostsList(isDark, posts),
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

  Widget _buildCategoryTabs(bool isDark) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: BoardCategory.values.map((cat) {
          final selected = _selected == cat;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selected != cat) {
                  setState(() => _selected = cat);
                  _loadPosts();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: selected
                      ? AppConstants.primaryColor
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getCategoryLabel(context, cat),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// Build posts list với loading và error states
  Widget _buildPostsList(bool isDark, List<BoardPost> posts) {
    // Loading state - hiển thị overlay nếu đã có posts (để transition mượt hơn)
    if (_isLoading && posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Error state
    if (_error != null && posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPosts,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    // Empty state
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noPostsYet,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    // Posts list
    return Opacity(
      opacity: _isLoading && posts.isNotEmpty ? 0.6 : 1.0,
      child: IgnorePointer(
        ignoring: _isLoading && posts.isNotEmpty,
        child: ListView.builder(
          key: ValueKey(_selected),
          itemCount: posts.length,
          itemBuilder: (_, i) => _BoardCard(
            post: posts[i],
            boardCategory: _selected,
            onDelete: () => _handleDeletePost(posts[i]),
          ),
        ),
      ),
    );
  }
}

// 카드 UI
class _BoardCard extends StatelessWidget {
  final BoardPost post;
  final BoardCategory boardCategory;
  final VoidCallback? onDelete;
  const _BoardCard({
    required this.post,
    required this.boardCategory,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Dismissible(
      key: Key(post.id),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              l10n.delete.split(' ').first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (onDelete == null) return false;
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
        return confirmed ?? false;
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 5),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BoardDetailScreen(post: post),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.article_outlined,
                    color: Colors.redAccent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(context, post.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _getCategoryLabel(context, boardCategory),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.redAccent),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatTime(BuildContext context, DateTime t) {
  return DateTimeUtils.formatChatTime(context, t);
}

class _BoardSearchDelegate extends SearchDelegate<BoardPost?> {
  final List<BoardPost> posts;
  _BoardSearchDelegate(this.posts);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final q = query.toLowerCase();
    final filtered = posts.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.content.toLowerCase().contains(q);
    }).toList();

    if (filtered.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).noSearchResults));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final post = filtered[i];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.author),
          onTap: () => close(context, post),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
