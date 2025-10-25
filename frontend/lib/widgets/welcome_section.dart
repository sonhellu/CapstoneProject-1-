import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';

class WelcomeSection extends StatelessWidget {
  final bool isDark;

  const WelcomeSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: AppConstants.animationVerySlow,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAnimatedIcon(value),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: _buildWelcomeText(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon(double animationValue) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 0.1,
          child: Icon(
            AppConstants.iconSchool,
            size: AppConstants.fontSizeXXL,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).welcome,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeTitle,
            fontWeight: AppConstants.fontWeightBold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          AppLocalizations.of(context).welcomeMessage,
          style: TextStyle(
            fontSize: AppConstants.fontSizeL,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
