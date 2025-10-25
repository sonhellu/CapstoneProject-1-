import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../providers/news_provider.dart';
import '../constants/app_constants.dart';
import '../screens/news/news_detail_screen.dart';

class NewsSection extends StatefulWidget {
  final bool isDark;

  const NewsSection({
    super.key,
    required this.isDark,
  });

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppConstants.defaultCurve,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: AppConstants.spacingM),
            _buildTabBar(),
            const SizedBox(height: AppConstants.spacingM),
            _buildTabBarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bảng tin',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXXL,
            fontWeight: AppConstants.fontWeightBold,
            color: widget.isDark ? Colors.white : AppConstants.primaryColor,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to full news screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng xem tất cả tin tức sẽ sớm có mặt!')),
            );
          },
          child: Row(
            children: [
              Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: widget.isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: widget.isDark ? Colors.white70 : Colors.grey[600],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: widget.isDark ? AppConstants.darkCardColor : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: widget.isDark ? Colors.white70 : Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: AppConstants.fontWeightSemiBold,
          fontSize: AppConstants.fontSizeM,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: AppConstants.fontWeightNormal,
          fontSize: AppConstants.fontSizeM,
        ),
        tabs: const [
          Tab(text: 'Quốc tế'),
          Tab(text: 'Quốc tịch'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 400, // Fixed height for the news list
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildNewsList('international'),
          _buildNewsList('national'),
        ],
      ),
    );
  }

  Widget _buildNewsList(String type) {
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

        final newsList = type == 'international' 
            ? newsProvider.internationalNews 
            : newsProvider.nationalNews;

        if (newsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  color: widget.isDark ? Colors.white54 : Colors.grey[400],
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có tin tức nào',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white54 : Colors.grey[600],
                    fontSize: AppConstants.fontSizeL,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];
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
        if (news.isPinned) ...[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(
              Icons.push_pin,
              color: AppConstants.primaryColor,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
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
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryColor.withValues(alpha: 0.1),
                AppConstants.primaryColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: AppConstants.primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            news.category,
            style: TextStyle(
              fontSize: AppConstants.fontSizeXS,
              color: AppConstants.primaryColor,
              fontWeight: AppConstants.fontWeightSemiBold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsContent(NewsModel news) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (news.imageUrl.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: Image.network(
                news.imageUrl,
                width: 90,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[300]!,
                          Colors.grey[200]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
        ],
        Expanded(
          child: Text(
            news.content,
            style: TextStyle(
              fontSize: AppConstants.fontSizeM,
              color: widget.isDark ? Colors.white70 : Colors.grey[600],
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsFooter(NewsModel news) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: widget.isDark 
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        children: [
          _buildFooterItem(
            Icons.person,
            news.author,
            widget.isDark ? Colors.white60 : Colors.grey[600]!,
          ),
          const SizedBox(width: AppConstants.spacingM),
          _buildFooterItem(
            Icons.access_time,
            news.timeAgo,
            widget.isDark ? Colors.white60 : Colors.grey[600]!,
          ),
          const Spacer(),
          _buildFooterItem(
            Icons.visibility,
            news.formattedViews,
            widget.isDark ? Colors.white60 : Colors.grey[600]!,
          ),
          const SizedBox(width: AppConstants.spacingM),
          _buildFooterItem(
            Icons.favorite,
            '${news.likes}',
            Colors.red[400]!,
          ),
          const SizedBox(width: AppConstants.spacingM),
          _buildFooterItem(
            Icons.comment,
            '${news.comments}',
            widget.isDark ? Colors.white60 : Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            color: color,
            fontWeight: AppConstants.fontWeightMedium,
          ),
        ),
      ],
    );
  }
}
