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
        _buildViewAllButton('all'),
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
      height: 300, // Chiều cao vừa khít với 6 mẩu tin (6 items x ~50px/item)
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

        // Chỉ hiển thị 6 mẩu tin để vừa khít với ô chứa
        final limitedNewsList = newsList.take(6).toList();

        return Column(
          children: [
            // Danh sách tin tức đơn giản
            ...limitedNewsList.asMap().entries.map((entry) {
              final index = entry.key;
              final news = entry.value;
              return _buildSimpleNewsItem(news, index);
            }),
          ],
        );
      },
    );
  }

  Widget _buildSimpleNewsItem(NewsModel news, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isDark 
                    ? [
                        AppConstants.darkCardColor,
                        AppConstants.darkCardColor.withValues(alpha: 0.95),
                      ]
                    : [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isDark 
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark 
                      ? Colors.black.withValues(alpha: 0.2)
                      : AppConstants.primaryColor.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: widget.isDark 
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.white.withValues(alpha: 0.8),
                    blurRadius: 4,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  splashColor: AppConstants.primaryColor.withValues(alpha: 0.15),
                  highlightColor: AppConstants.primaryColor.withValues(alpha: 0.08),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        // Icon tin tức với gradient
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppConstants.primaryColor.withValues(alpha: 0.2),
                                AppConstants.primaryColor.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppConstants.primaryColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            news.isPinned ? Icons.push_pin : Icons.article_outlined,
                            color: AppConstants.primaryColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Nội dung tin tức
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark ? Colors.white : Colors.black87,
                                  height: 1.3,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 11,
                                    color: AppConstants.primaryColor.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    news.timeAgo,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: widget.isDark 
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      news.category,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppConstants.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Icon mũi tên với hiệu ứng
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppConstants.primaryColor,
                            size: 12,
                          ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: AppConstants.fontWeightMedium,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                color: AppConstants.primaryColor,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
