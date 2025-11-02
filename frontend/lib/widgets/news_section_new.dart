import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../providers/news_provider.dart';
import '../constants/app_constants.dart';
import '../screens/news/news_detail_screen.dart';
import '../screens/news/news_list_screen.dart';

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
          'Tin tức',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXL,
            fontWeight: AppConstants.fontWeightBold,
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingS,
          ),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.newspaper,
                color: AppConstants.primaryColor,
                size: 16,
              ),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                'Cập nhật',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeS,
                  fontWeight: AppConstants.fontWeightMedium,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppConstants.darkCardColor : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: widget.isDark ? Colors.white60 : Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: AppConstants.fontWeightSemiBold,
          fontSize: AppConstants.fontSizeM,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: AppConstants.fontWeightMedium,
          fontSize: AppConstants.fontSizeM,
        ),
        tabs: const [
          Tab(text: 'Quốc tế'),
          Tab(text: 'Trong nước'),
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

        // Chỉ hiển thị 10 mẩu tin đầu tiên
        final limitedNewsList = newsList.take(10).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              // Danh sách tin tức đơn giản
              ...limitedNewsList.asMap().entries.map((entry) {
                final index = entry.key;
                final news = entry.value;
                return _buildSimpleNewsItem(news, index);
              }),
              
              // Nút "Xem tất cả"
              if (newsList.length > 10) ...[
                const SizedBox(height: AppConstants.spacingM),
                _buildViewAllButton(type),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleNewsItem(NewsModel news, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
              decoration: BoxDecoration(
                color: widget.isDark ? AppConstants.darkCardColor : Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark 
                      ? Colors.black.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
                    child: Row(
                      children: [
                        // Icon tin tức
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Icon(
                            Icons.article_outlined,
                            color: AppConstants.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingM),
                        
                        // Nội dung tin tức
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.title,
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeM,
                                  fontWeight: AppConstants.fontWeightMedium,
                                  color: widget.isDark ? Colors.white : Colors.black87,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    news.timeAgo,
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeS,
                                      color: widget.isDark ? Colors.white60 : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: widget.isDark ? Colors.white60 : Colors.grey[400],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    news.category,
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeS,
                                      color: widget.isDark ? Colors.white60 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Icon mũi tên
                        Icon(
                          Icons.arrow_forward_ios,
                          color: widget.isDark ? Colors.white60 : Colors.grey[400],
                          size: 16,
                        ),
                      ],
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

  Widget _buildViewAllButton(String type) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsListScreen(
                  type: type,
                  isDark: widget.isDark,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingM,
              horizontal: AppConstants.spacingL,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Xem tất cả tin tức',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeL,
                    fontWeight: AppConstants.fontWeightSemiBold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingS),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

