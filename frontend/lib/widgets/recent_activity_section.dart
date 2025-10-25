import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Optimized RecentActivitySection with performance improvements

class RecentActivitySection extends StatelessWidget {
  final bool isDark;

  const RecentActivitySection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        duration: AppConstants.animationNormal, // Reduced duration
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)), // Reduced offset
            child: Opacity(
              opacity: value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(),
                  const SizedBox(height: AppConstants.spacingM),
                  _buildActivityCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Text(
      'Recent Activity',
      style: TextStyle(
        fontSize: AppConstants.fontSizeXXL,
        fontWeight: AppConstants.fontWeightBold,
        color: isDark ? Colors.white : AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildActivityCard() {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkSurfaceColor : AppConstants.lightSurfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(),
            const SizedBox(height: AppConstants.spacingM),
            _buildActivityContent(),
            const SizedBox(height: AppConstants.spacingS),
            _buildActivityTime(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingS),
          decoration: BoxDecoration(
            color: AppConstants.primaryLightColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Icon(
            AppConstants.iconNotifications,
            color: AppConstants.primaryColor,
            size: AppConstants.fontSizeXXL,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Text(
            'Welcome to Hello Campus!',
            style: TextStyle(
              fontWeight: AppConstants.fontWeightBold,
              color: isDark ? Colors.white : AppConstants.primaryColor,
              fontSize: AppConstants.fontSizeL,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityContent() {
    return Text(
      'Your account has been created successfully. Start exploring your campus!',
      style: TextStyle(
        color: isDark ? Colors.white70 : Colors.grey[600],
        fontSize: AppConstants.fontSizeM,
      ),
    );
  }

  Widget _buildActivityTime() {
    return Text(
      '2 hours ago',
      style: TextStyle(
        fontSize: AppConstants.fontSizeS,
        color: isDark ? Colors.white54 : Colors.grey[500],
      ),
    );
  }
}
