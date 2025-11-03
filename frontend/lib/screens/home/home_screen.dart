import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/news_section.dart';
import '../../widgets/language_order_section.dart';
import '../../models/banner_model.dart';
import '../../constants/app_constants.dart';
import '../profile/profile_screen.dart';
import '../social/chat_screen.dart';
import '../notifications/notification_screen.dart';
import '../../widgets/keimyung_banner.dart';

class HomeScreen extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  
  const HomeScreen({super.key, this.onLanguageChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // Lazy loading screens for better performance
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens only when needed
    _screens = [
      const HomeTab(),
      const ChatScreen(),
      const NotificationScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: Text(
          AppLocalizations.of(context).appTitle,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: AppConstants.fontWeightBold,
            fontSize: AppConstants.fontSizeXL,
          ),
        ),
        actions: [
          AppBarActions(onLanguageChanged: widget.onLanguageChanged),
        ],
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.isDarkMode ? AppConstants.darkSurfaceColor : AppConstants.lightSurfaceColor,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: const Icon(AppConstants.iconHome),
            label: AppLocalizations.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppConstants.iconChat),
            label: AppLocalizations.of(context).chat,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppConstants.iconNotifications),
            label: AppLocalizations.of(context).notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppConstants.iconProfile),
            label: AppLocalizations.of(context).profile,
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    final isDark = context.isDarkMode;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isDark 
          ? AppGradients.darkBackgroundGradient
          : AppGradients.lightBackgroundGradient,
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Keimyung University Banner with RepaintBoundary
                  RepaintBoundary(
                    child: const KeimyungBanner(),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  
                  // Banner carousel with RepaintBoundary
                  RepaintBoundary(
                    child: BannerCarousel(
                      banners: BannerModel.getSampleBanners(),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // News section with RepaintBoundary
                  RepaintBoundary(
                    child: NewsSection(isDark: isDark),
                  ),
                  const SizedBox(height: 28),
                  
                  // Language Order section with RepaintBoundary
                  RepaintBoundary(
                    child: LanguageOrderSection(isDark: isDark),
                  ),
                  const SizedBox(height: AppConstants.spacingXXL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}
