import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';
import '../services/community_service.dart';
import '../services/profile_service.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';

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

  /// (KR) SharedPreferences 또는 Profile API에서 user의 main_language 가져오기
  /// Lấy main_language của user từ SharedPreferences hoặc Profile API
  Future<String> _getUserMainLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMainLang = prefs.getString('mainLanguage');

      if (savedMainLang != null && savedMainLang.isNotEmpty) {
        return savedMainLang;
      }

      // (KR) SharedPreferences에 없으면 Profile API에서 가져오기 시도
      // Nếu không có trong SharedPreferences, thử lấy từ Profile API
      try {
        final profile = await ProfileService.getMyProfile();
        if (profile['main_language'] != null) {
          final mainLang = profile['main_language'].toString();
          // (KR) 다음 번엔 API를 다시 안 부르도록 SharedPreferences에 저장
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

  /// (KR) main_language 업데이트 후 뉴스 다시 불러오기
  /// Cập nhật main_language và reload news
  Future<void> setUserMainLanguage(
    String mainLanguage, {
    bool forceReload = false,
  }) async {
    // (KR) 언어가 같고 강제 리로드가 아니면 아무 것도 안 함
    // Nếu ngôn ngữ giống nhau và không force reload, không làm gì
    if (_userMainLanguage == mainLanguage && !forceReload) {
      return;
    }

    final oldLanguage = _userMainLanguage;

    // (KR) main_language 업데이트
    // Cập nhật main_language
    _userMainLanguage = mainLanguage;

    // (KR) SharedPreferences에 저장
    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mainLanguage', mainLanguage);

    // (KR) allPosts endpoint의 다양한 query 조합 캐시 삭제
    // Clear cache cho tất cả các variations của API posts endpoint
    // (KR) 언어 변경 즉시 새로운 언어로 데이터를 받아오도록 보장
    // Để đảm bảo lấy data mới với ngôn ngữ mới
    _clearAllPostsCache(mainLanguage);
    if (oldLanguage.isNotEmpty && oldLanguage != mainLanguage) {
      _clearAllPostsCache(oldLanguage);
    }

    // (KR) 새 언어로 뉴스 다시 로딩 (항상 강제 리로드)
    // Reload news với language mới (force reload để đảm bảo data mới nhất)
    await _loadNews(forceReload: true);
  }

  /// (KR) allPosts endpoint의 캐시(여러 variation) 정리
  /// Clear cache cho tất cả các variations của allPosts endpoint
  void _clearAllPostsCache(String? language) {
    // Clear base endpoint
    ApiService.clearCacheEntry(ApiConfig.allPostsEndpoint);
    ApiService.clearCacheEntry('${ApiConfig.allPostsEndpoint}?limit=50');

    if (language != null && language.isNotEmpty) {
      // Clear với original_lang
      ApiService.clearCacheEntry(
        '${ApiConfig.allPostsEndpoint}?limit=50&original_lang=$language',
      );
      // Clear với các variations khác
      ApiService.clearCacheEntry(
        '${ApiConfig.allPostsEndpoint}?limit=50&original_lang=${language.toLowerCase()}',
      );
      ApiService.clearCacheEntry(
        '${ApiConfig.allPostsEndpoint}?original_lang=$language',
      );
    }
  }

  /// (KR) 새로고침: 캐시 지우고 API에서 다시 로드
  /// Refresh news (reload từ API)
  Future<void> refreshNews() async {
    // Clear tất cả cache liên quan đến posts
    _clearAllPostsCache(_userMainLanguage);

    // Reload main_language trước khi load news
    _userMainLanguage = await _getUserMainLanguage();
    // Force reload khi user manually refresh
    await _loadNews(forceReload: true);
  }

  Future<void> _loadNews({bool forceReload = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // (KR) user main_language 가져오기
      // Lấy main_language của user
      _userMainLanguage = await _getUserMainLanguage();

      // (KR) 성능 위해 병렬 호출 (동시에 2개 요청)
      // Gọi API parallel để tối ưu performance (gọi đồng thời thay vì tuần tự)
      final results = await Future.wait([
        // Gọi API để lấy tất cả posts (cho International tab)
        CommunityService.getAllPosts(
          limit: 50,
          useCache: !forceReload,
        ),
        // Gọi API để lấy posts theo main_language (cho Domestic tab)
        CommunityService.getAllPosts(
          limit: 50,
          originalLang: _userMainLanguage,
          useCache: !forceReload,
        ),
      ]);

      final allPostsData = results[0];
      final domesticPostsData = results[1];

      // Convert posts thành NewsModel (sử dụng toList() để eager evaluation)
      final allNews =
          allPostsData.map((post) => NewsModel.fromPostData(post)).toList();
      final domesticNews =
          domesticPostsData.map((post) => NewsModel.fromPostData(post)).toList();

      // Assign to lists
      _allNews = allNews;
      _internationalNews = allNews; // Tất cả posts cho International tab
      _nationalNews = domesticNews; // Posts theo main_language cho Domestic tab

      // Sort by publish date (newest first) - chỉ sort 1 lần
      _internationalNews.sort(
        (a, b) => b.publishDate.compareTo(a.publishDate),
      );
      _nationalNews.sort(
        (a, b) => b.publishDate.compareTo(a.publishDate),
      );
    } catch (e) {
      // Store error key instead of hardcoded message
      _error = 'failedToLoadNews:${e.toString()}';
      // Fallback to sample data nếu API fails
      try {
        final fetchedNews = NewsModel.getSampleNews();
        _allNews = fetchedNews;
        _internationalNews = fetchedNews
            .where((news) => news.nationality == 'international')
            .toList();

        // Map main_language sang nationality để filter
        final langToNationality = {
          'ko': 'korea',
          'vi': 'vietnam',
          'zh': 'china',
          'ja': 'japan',
          'my': 'myanmar',
        };
        final userNationality =
            langToNationality[_userMainLanguage] ?? 'vietnam';
        _nationalNews =
            fetchedNews.where((news) => news.nationality == userNationality).toList();

        _internationalNews.sort(
          (a, b) => b.publishDate.compareTo(a.publishDate),
        );
        _nationalNews.sort(
          (a, b) => b.publishDate.compareTo(a.publishDate),
        );
      } catch (fallbackError) {
        // If both fail, leave empty lists
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void likeNews(String newsId) {
    // Tìm trong cả 3 lists để update
    _updateNewsInList(_allNews, newsId,
        (news) => news.copyWith(likes: news.likes + 1));
    _updateNewsInList(_internationalNews, newsId,
        (news) => news.copyWith(likes: news.likes + 1));
    _updateNewsInList(_nationalNews, newsId,
        (news) => news.copyWith(likes: news.likes + 1));
    notifyListeners();
  }

  void viewNews(String newsId) {
    // Tìm trong cả 3 lists để update
    _updateNewsInList(_allNews, newsId,
        (news) => news.copyWith(views: news.views + 1));
    _updateNewsInList(_internationalNews, newsId,
        (news) => news.copyWith(views: news.views + 1));
    _updateNewsInList(_nationalNews, newsId,
        (news) => news.copyWith(views: news.views + 1));
    notifyListeners();
  }

  /// Helper method để update news trong list (tránh code duplicate)
  void _updateNewsInList(
    List<NewsModel> list,
    String newsId,
    NewsModel Function(NewsModel) updater,
  ) {
    final index = list.indexWhere((news) => news.id == newsId);
    if (index != -1) {
      list[index] = updater(list[index]);
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

    final q = query.toLowerCase();
    return _allNews
        .where(
          (news) =>
              news.title.toLowerCase().contains(q) ||
              news.content.toLowerCase().contains(q) ||
              news.tags.any((tag) => tag.toLowerCase().contains(q)),
        )
        .toList();
  }
}
