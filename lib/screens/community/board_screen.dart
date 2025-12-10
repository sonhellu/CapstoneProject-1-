// lib/screens/community/board_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/board_post.dart';
import '../../services/community_service.dart';
import '../../services/api_service.dart';
import 'board_detail_screen.dart';
import 'board_write_screen.dart';

// 4개 게시판 종류
enum BoardCategory { notice, free, info, promo }

const Map<BoardCategory, String> _categoryLabels = {
  BoardCategory.notice: '공지게시판',
  BoardCategory.free: '자유게시판',
  BoardCategory.info: '정보게시판',
  BoardCategory.promo: '홍보게시판',
};

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

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCategory;
    _loadPosts();
  }

  /// Load posts from API
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final boardId = _categoryToBoardId[_selected] ?? 1;
      final postsData = await CommunityService.getPosts(
        boardId: boardId,
        limit: 20,
      );

      final posts = postsData.map((postData) {
        return BoardPost.fromJson(postData as Map<String, dynamic>);
      }).toList();

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Refresh posts
  Future<void> _refreshPosts() async {
    await _loadPosts();
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
          _categoryLabels[_selected]!,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoardDetailScreen(post: result),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoardWriteScreen(category: _selected),
                ),
              );
              
              // Reload posts if post was created successfully
              if (result == true && mounted) {
                _loadPosts();
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
                    child: _buildPostsList(isDark, posts),
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
                setState(() => _selected = cat);
                _loadPosts(); // Reload posts khi chuyển category
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFF1E88E5)],
                        )
                      : null,
                  color: selected ? null : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  _categoryLabels[cat]!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
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
    // Loading state
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
              label: const Text('Retry'),
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
              'Chưa có bài viết nào',
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
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (_, i) => _BoardCard(post: posts[i]),
    );
  }
}

// 카드 UI
class _BoardCard extends StatelessWidget {
  final BoardPost post;
  const _BoardCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          _formatTime(post.createdAt),
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
                          child: const Text(
                            '게시글',
                            style: TextStyle(
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
    );
  }
}

String _formatTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  return '${diff.inDays}일 전';
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
      return const Center(child: Text('검색 결과가 없습니다.'));
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
