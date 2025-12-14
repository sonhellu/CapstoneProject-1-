// lib/screens/home/home_screen.dart

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
import '../../widgets/keimyung_banner.dart';
import '../../widgets/board_section.dart';

class HomeScreen extends StatefulWidget {
  final Function(String)? onLanguageChanged;

  const HomeScreen({super.key, this.onLanguageChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _profileKey = 0; // Key to force rebuild ProfileScreen when tab is selected
  late AnimationController _tabAnimationController;
  late Animation<double> _tabAnimation;

  // Get screens - ProfileScreen will rebuild when key changes
  List<Widget> get _screens => [
    const HomeTab(),
    const ChatScreen(),
    ProfileScreen(key: ValueKey(_profileKey), onLanguageChanged: widget.onLanguageChanged),
  ];
  
  @override
  void initState() {
    super.initState();
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabAnimation = CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOut,
    );
    _tabAnimationController.forward();
  }

  @override
  void dispose() {
    _tabAnimationController.dispose();
    super.dispose();
  }
  
  // Method to reload profile screen (can be called from ProfileScreen)
  void reloadProfileScreen() {
    setState(() {
      _profileKey++; // Force rebuild ProfileScreen
    });
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        // Force rebuild ProfileScreen when profile tab is selected to trigger API call
        if (index == 2) {
          _profileKey++;
        }
      });
      // Animate tab change
      _tabAnimationController.reset();
      _tabAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            AppLocalizations.of(context).appTitle,
            key: ValueKey(_currentIndex),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: AppConstants.fontWeightBold,
              fontSize: AppConstants.fontSizeXL,
            ),
          ),
        ),
        actions: [
          AppBarActions(onLanguageChanged: widget.onLanguageChanged),
        ],
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _tabAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark
              ? AppConstants.darkSurfaceColor
              : AppConstants.lightSurfaceColor,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor:
              isDark ? Colors.grey[400] : Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0
                      ? AppConstants.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppConstants.iconHome,
                  size: _currentIndex == 0 ? 26 : 24,
                ),
              ),
              label: AppLocalizations.of(context).home,
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? AppConstants.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppConstants.iconChat,
                  size: _currentIndex == 1 ? 26 : 24,
                ),
              ),
              label: AppLocalizations.of(context).chat,
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2
                      ? AppConstants.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppConstants.iconProfile,
                  size: _currentIndex == 2 ? 26 : 24,
                ),
              ),
              label: AppLocalizations.of(context).profile,
            ),
          ],
        ),
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
  late List<AnimationController> _staggerControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Staggered animations for each section
    _staggerControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _fadeAnimations = _staggerControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );
    }).toList();

    _slideAnimations = _staggerControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );
    }).toList();

    // Start animations with stagger
    _animationController.forward();
    for (int i = 0; i < _staggerControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _staggerControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _staggerControllers) {
      controller.dispose();
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Keimyung University Banner with staggered animation
              FadeTransition(
                opacity: _fadeAnimations[0],
                child: SlideTransition(
                  position: _slideAnimations[0],
                  child: const RepaintBoundary(
                    child: KeimyungBanner(),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Banner carousel with staggered animation
              FadeTransition(
                opacity: _fadeAnimations[1],
                child: SlideTransition(
                  position: _slideAnimations[1],
                  child: RepaintBoundary(
                    child: BannerCarousel(
                      banners: BannerModel.getSampleBanners(),
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // News section with staggered animation
              FadeTransition(
                opacity: _fadeAnimations[2],
                child: SlideTransition(
                  position: _slideAnimations[2],
                  child: RepaintBoundary(
                    child: NewsSection(isDark: isDark),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Board section with staggered animation
              FadeTransition(
                opacity: _fadeAnimations[3],
                child: SlideTransition(
                  position: _slideAnimations[3],
                  child: RepaintBoundary(
                    child: BoardSection(isDark: isDark),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Language Order section with staggered animation
              FadeTransition(
                opacity: _fadeAnimations[4],
                child: SlideTransition(
                  position: _slideAnimations[4],
                  child: RepaintBoundary(
                    child: LanguageOrderSection(isDark: isDark),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }
}

