import 'package:flutter/material.dart';
import '../models/news_model.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsModel> _allNews = [];
  List<NewsModel> _internationalNews = [];
  List<NewsModel> _nationalNews = [];
  String _userNationality = 'vietnam'; // Default nationality
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NewsModel> get allNews => _allNews;
  List<NewsModel> get internationalNews => _internationalNews;
  List<NewsModel> get nationalNews => _nationalNews;
  String get userNationality => _userNationality;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NewsProvider() {
    _loadNews();
  }

  Future<void> _loadNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Get sample data
      final fetchedNews = NewsModel.getSampleNews();
      
      // Filter news based on nationality
      _allNews = fetchedNews;
      _internationalNews = fetchedNews.where((news) => news.nationality == 'international').toList();
      _nationalNews = fetchedNews.where((news) => news.nationality == _userNationality).toList();
      
      // Sort by publish date (newest first)
      _internationalNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      _nationalNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      
    } catch (e) {
      _error = 'Failed to load news: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUserNationality(String nationality) {
    if (_userNationality != nationality) {
      _userNationality = nationality;
      _filterNews();
      notifyListeners();
    }
  }

  void _filterNews() {
    _nationalNews = _allNews.where((news) => news.nationality == _userNationality).toList();
    _nationalNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));
  }

  Future<void> refreshNews() async {
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
      _filterNews();
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
      _filterNews();
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
