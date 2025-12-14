import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';
import '../services/community_service.dart';
import '../services/profile_service.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsModel> _allNews = [];
  List<NewsModel> _internationalNews = [];
  List<NewsModel> _nationalNews = [];
  String _userMainLanguage = 'en'; // Default main language
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NewsModel> get allNews => _allNews;
  List<NewsModel> get internationalNews => _internationalNews;
  List<NewsModel> get nationalNews => _nationalNews;
  String get userMainLanguage => _userMainLanguage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NewsProvider() {
    _loadNews();
  }

  /// Lấy main_language của user từ SharedPreferences hoặc Profile API
  Future<String> _getUserMainLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMainLang = prefs.getString('mainLanguage');
      
      if (savedMainLang != null && savedMainLang.isNotEmpty) {
        return savedMainLang;
      }
      
      // Nếu không có trong SharedPreferences, thử lấy từ Profile API
      try {
        final profile = await ProfileService.getMyProfile();
        if (profile['main_language'] != null) {
          final mainLang = profile['main_language'].toString();
          // Lưu vào SharedPreferences để lần sau không cần gọi API
          await prefs.setString('mainLanguage', mainLang);
          return mainLang;
        }
      } catch (e) {
        // Ignore if profile API fails
      }
      
      // Fallback to default
      return 'en';
    } catch (e) {
      return 'en';
    }
  }

  Future<void> _loadNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Lấy main_language của user
      _userMainLanguage = await _getUserMainLanguage();
      
      // Gọi API để lấy tất cả posts (cho International tab)
      final allPostsData = await CommunityService.getAllPosts(limit: 50);
      
      // Gọi API để lấy posts theo main_language (cho Domestic tab)
      final domesticPostsData = await CommunityService.getAllPosts(
        limit: 50,
        originalLang: _userMainLanguage,
      );
      
      // Convert posts thành NewsModel
      final allNews = allPostsData.map((post) => NewsModel.fromPostData(post)).toList();
      final domesticNews = domesticPostsData.map((post) => NewsModel.fromPostData(post)).toList();
      
      // Assign to lists
      _allNews = allNews;
      _internationalNews = allNews; // Tất cả posts cho International tab
      _nationalNews = domesticNews; // Posts theo main_language cho Domestic tab
      
      // Sort by publish date (newest first)
      _internationalNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      _nationalNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      
    } catch (e) {
      _error = 'Failed to load news: ${e.toString()}';
      // Fallback to sample data nếu API fails
      try {
        final fetchedNews = NewsModel.getSampleNews();
        _allNews = fetchedNews;
        _internationalNews = fetchedNews.where((news) => news.nationality == 'international').toList();
        
        // Map main_language sang nationality để filter
        final langToNationality = {
          'ko': 'korea',
          'vi': 'vietnam',
          'zh': 'china',
          'ja': 'japan',
          'my': 'myanmar',
        };
        final userNationality = langToNationality[_userMainLanguage] ?? 'vietnam';
        _nationalNews = fetchedNews.where((news) => news.nationality == userNationality).toList();
        
        _internationalNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));
        _nationalNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      } catch (fallbackError) {
        // If both fail, leave empty lists
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật main_language và reload news
  Future<void> setUserMainLanguage(String mainLanguage) async {
    if (_userMainLanguage != mainLanguage) {
      _userMainLanguage = mainLanguage;
      
      // Lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mainLanguage', mainLanguage);
      
      // Reload news với language mới
      await _loadNews();
    }
  }

  /// Refresh news (reload từ API)
  Future<void> refreshNews() async {
    // Reload main_language trước khi load news
    _userMainLanguage = await _getUserMainLanguage();
    await _loadNews();
  }

  void likeNews(String newsId) {
    final newsIndex = _allNews.indexWhere((news) => news.id == newsId);
    if (newsIndex != -1) {
      _allNews[newsIndex] = NewsModel(
        id: _allNews[newsIndex].id,
        title: _allNews[newsIndex].title,
        content: _allNews[newsIndex].content,
        imageUrl: _allNews[newsIndex].imageUrl,
        nationality: _allNews[newsIndex].nationality,
        publishDate: _allNews[newsIndex].publishDate,
        author: _allNews[newsIndex].author,
        views: _allNews[newsIndex].views,
        likes: _allNews[newsIndex].likes + 1,
        comments: _allNews[newsIndex].comments,
        tags: _allNews[newsIndex].tags,
        isPinned: _allNews[newsIndex].isPinned,
        category: _allNews[newsIndex].category,
      );
      notifyListeners();
    }
  }

  void viewNews(String newsId) {
    final newsIndex = _allNews.indexWhere((news) => news.id == newsId);
    if (newsIndex != -1) {
      _allNews[newsIndex] = NewsModel(
        id: _allNews[newsIndex].id,
        title: _allNews[newsIndex].title,
        content: _allNews[newsIndex].content,
        imageUrl: _allNews[newsIndex].imageUrl,
        nationality: _allNews[newsIndex].nationality,
        publishDate: _allNews[newsIndex].publishDate,
        author: _allNews[newsIndex].author,
        views: _allNews[newsIndex].views + 1,
        likes: _allNews[newsIndex].likes,
        comments: _allNews[newsIndex].comments,
        tags: _allNews[newsIndex].tags,
        isPinned: _allNews[newsIndex].isPinned,
        category: _allNews[newsIndex].category,
      );
      notifyListeners();
    }
  }

  List<NewsModel> getPinnedNews() {
    return _allNews.where((news) => news.isPinned).toList();
  }

  List<NewsModel> getNewsByCategory(String category) {
    return _allNews.where((news) => news.category == category).toList();
  }

  List<NewsModel> searchNews(String query) {
    if (query.isEmpty) return _allNews;
    
    return _allNews.where((news) => 
      news.title.toLowerCase().contains(query.toLowerCase()) ||
      news.content.toLowerCase().contains(query.toLowerCase()) ||
      news.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }
}

