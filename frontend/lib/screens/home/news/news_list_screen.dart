import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/news_model.dart';
import '../../../providers/news_provider.dart';
import '../../../constants/app_constants.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  final String type; // 'international' or 'national'
  final bool isDark;

  const NewsListScreen({
    super.key,
    required this.type,
    required this.isDark,
  });

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppConstants.defaultCurve,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppConstants.slideCurve,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? AppConstants.darkBackgroundColor : AppConstants.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        title: Text(
          widget.type == 'international' ? 'Tin tức quốc tế' : 'Tin tức trong nước',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: AppConstants.fontWeightSemiBold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Search bar
              if (_searchQuery.isNotEmpty) _buildSearchBar(),
              
              // News list
              Expanded(
                child: _buildNewsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: widget.isDark ? AppConstants.darkSurfaceColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: widget.isDark 
              ? Colors.black.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tin tức...',
                hintStyle: TextStyle(
                  color: widget.isDark ? Colors.white60 : Colors.grey[600],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: widget.isDark ? Colors.white60 : Colors.grey[600],
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: widget.isDark ? Colors.white60 : Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: widget.isDark ? AppConstants.darkCardColor : Colors.grey[100],
              ),
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        if (newsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          );
        }

        if (newsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  newsProvider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => newsProvider.refreshNews(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final newsList = widget.type == 'international' 
            ? newsProvider.internationalNews 
            : newsProvider.nationalNews;

        // Filter by search query
        final filteredNewsList = _searchQuery.isEmpty 
            ? newsList 
            : newsProvider.searchNews(_searchQuery).where((news) => 
                newsList.any((n) => n.id == news.id)).toList();

        if (filteredNewsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.article_outlined : Icons.search_off,
                  color: widget.isDark ? Colors.white54 : Colors.grey[400],
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'Chưa có tin tức nào' : 'Không tìm thấy kết quả',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white54 : Colors.grey[600],
                    fontSize: AppConstants.fontSizeL,
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Thử tìm kiếm với từ khóa khác',
                    style: TextStyle(
                      color: widget.isDark ? Colors.white38 : Colors.grey[500],
                      fontSize: AppConstants.fontSizeM,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          itemCount: filteredNewsList.length,
          itemBuilder: (context, index) {
            final news = filteredNewsList[index];
            return _buildNewsCard(news, index);
          },
        );
      },
    );
  }

  Widget _buildNewsCard(NewsModel news, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 150)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: Opacity(
              opacity: value,
              child: RepaintBoundary(
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppConstants.darkCardColor : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDark 
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: widget.isDark 
                          ? Colors.black.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      splashColor: AppConstants.primaryColor.withValues(alpha: 0.1),
                      highlightColor: AppConstants.primaryColor.withValues(alpha: 0.05),
                      onTap: () {
                        context.read<NewsProvider>().viewNews(news.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailScreen(news: news),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNewsHeader(news),
                            const SizedBox(height: AppConstants.spacingS),
                            _buildNewsContent(news),
                            const SizedBox(height: AppConstants.spacingS),
                            _buildNewsFooter(news),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsHeader(NewsModel news) {
    return Row(
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingS,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Text(
            news.category,
            style: TextStyle(
              fontSize: AppConstants.fontSizeS,
              fontWeight: AppConstants.fontWeightMedium,
              color: AppConstants.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        
        // Pinned indicator
        if (news.isPinned) ...[
          Icon(
            Icons.push_pin,
            size: 16,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 4),
        ],
        
        const Spacer(),
        
        // Time ago
        Text(
          news.timeAgo,
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            color: widget.isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsContent(NewsModel news) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          news.title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeL,
            fontWeight: AppConstants.fontWeightSemiBold,
            color: widget.isDark ? Colors.white : Colors.black87,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppConstants.spacingS),
        
        // Content preview
        Text(
          news.content,
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            color: widget.isDark ? Colors.white70 : Colors.grey[700],
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildNewsFooter(NewsModel news) {
    return Row(
      children: [
        // Author
        Icon(
          Icons.person_outline,
          size: 16,
          color: widget.isDark ? Colors.white60 : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          news.author,
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            color: widget.isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const Spacer(),
        
        // Stats
        _buildStatItem(Icons.visibility, news.formattedViews),
        const SizedBox(width: AppConstants.spacingM),
        _buildStatItem(Icons.favorite, '${news.likes}'),
        const SizedBox(width: AppConstants.spacingM),
        _buildStatItem(Icons.comment, '${news.comments}'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: widget.isDark ? Colors.white60 : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            color: widget.isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tìm kiếm tin tức'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa tìm kiếm...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Tìm kiếm'),
          ),
        ],
      ),
    );
  }
}

