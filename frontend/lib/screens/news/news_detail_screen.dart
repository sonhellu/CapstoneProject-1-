import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/news_model.dart';
import '../../providers/news_provider.dart';
import '../../constants/app_constants.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsModel news;

  const NewsDetailScreen({
    super.key,
    required this.news,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBackgroundColor : AppConstants.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        title: Text(
          'Chi tiết tin tức',
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
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng chia sẻ sẽ sớm có mặt!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu vào danh sách yêu thích!')),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(isDark),
                _buildContent(isDark),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildHeroImage(bool isDark) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.radiusXL),
          bottomRight: Radius.circular(AppConstants.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppConstants.radiusXL),
              bottomRight: Radius.circular(AppConstants.radiusXL),
            ),
            child: Image.network(
              widget.news.imageUrl,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppConstants.radiusXL),
                      bottomRight: Radius.circular(AppConstants.radiusXL),
                    ),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.white,
                    size: 64,
                  ),
                );
              },
            ),
          ),
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.radiusXL),
                bottomRight: Radius.circular(AppConstants.radiusXL),
              ),
            ),
          ),
          if (widget.news.isPinned)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.push_pin,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Ghim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppConstants.fontSizeS,
                        fontWeight: AppConstants.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(isDark),
          const SizedBox(height: AppConstants.spacingM),
          _buildMetaInfo(isDark),
          const SizedBox(height: AppConstants.spacingL),
          _buildContentText(isDark),
          const SizedBox(height: AppConstants.spacingL),
          _buildTags(isDark),
          const SizedBox(height: AppConstants.spacingXL),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      widget.news.title,
      style: TextStyle(
        fontSize: AppConstants.fontSizeTitle,
        fontWeight: AppConstants.fontWeightBold,
        color: isDark ? Colors.white : Colors.black87,
        height: 1.3,
      ),
    );
  }

  Widget _buildMetaInfo(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Text(
            widget.news.category,
            style: TextStyle(
              fontSize: AppConstants.fontSizeS,
              color: AppConstants.primaryColor,
              fontWeight: AppConstants.fontWeightMedium,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Icon(
          Icons.person,
          size: 16,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          widget.news.author,
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Icon(
          Icons.access_time,
          size: 16,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          widget.news.timeAgo,
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContentText(bool isDark) {
    return Text(
      widget.news.content,
      style: TextStyle(
        fontSize: AppConstants.fontSizeL,
        color: isDark ? Colors.white : Colors.black87,
        height: 1.6,
      ),
    );
  }

  Widget _buildTags(bool isDark) {
    if (widget.news.tags.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags:',
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: AppConstants.fontWeightSemiBold,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.news.tags.map((tag) => Chip(
            label: Text(tag),
            backgroundColor: isDark ? AppConstants.darkCardColor : Colors.grey[200],
            labelStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: AppConstants.fontSizeS,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurfaceColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isDark 
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: Row(
                children: [
                  _buildBottomBarItem(
                    Icons.visibility,
                    widget.news.formattedViews,
                    isDark ? Colors.white70 : Colors.grey[600]!,
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  _buildBottomBarItem(
                    Icons.favorite,
                    '${widget.news.likes}',
                    Colors.red[400]!,
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  _buildBottomBarItem(
                    Icons.comment,
                    '${widget.news.comments}',
                    isDark ? Colors.white70 : Colors.grey[600]!,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Container(
            decoration: BoxDecoration(
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
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<NewsProvider>().likeNews(widget.news.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thích bài viết!')),
                );
              },
              icon: const Icon(Icons.favorite_border),
              label: const Text('Thích'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            color: color,
            fontWeight: AppConstants.fontWeightMedium,
          ),
        ),
      ],
    );
  }
}
