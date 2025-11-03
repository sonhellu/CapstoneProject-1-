import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../providers/news_provider.dart';
import '../constants/app_constants.dart';
import '../screens/home/news/news_detail_screen.dart';
import '../screens/home/news/news_list_screen.dart';

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
            const SizedBox(height: AppConstants.spacingM),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDark 
            ? [
                AppConstants.darkCardColor,
                AppConstants.darkCardColor.withValues(alpha: 0.8),
              ]
            : [
                Colors.grey[100]!,
                Colors.grey[50]!,
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: widget.isDark 
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: widget.isDark 
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppConstants.primaryColor,
              Color(0xFF0052A5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusL - 2),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: widget.isDark ? Colors.white54 : Colors.grey[700],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: AppConstants.fontSizeM,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: AppConstants.fontWeightMedium,
          fontSize: AppConstants.fontSizeM,
          letterSpacing: 0.2,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(
          AppConstants.primaryColor.withValues(alpha: 0.1),
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.public,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text('Quốc tế'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text('Trong nước'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 340, // Chiều cao vừa khít với 5 mẩu tin (5 items x ~56px/item)
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

        // Chỉ hiển thị 5 mẩu tin để vừa khít với ô chứa
        final limitedNewsList = newsList.take(5).toList();

        return ListView.builder(
          itemCount: limitedNewsList.length,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return _buildSimpleNewsItem(limitedNewsList[index], index);
          },
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
              margin: EdgeInsets.only(bottom: index < 4 ? 8 : 0),
              decoration: BoxDecoration(
                color: widget.isDark 
                  ? AppConstants.darkCardColor
                  : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isDark 
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.2),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark 
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
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
                        // Icon tin tức
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
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
