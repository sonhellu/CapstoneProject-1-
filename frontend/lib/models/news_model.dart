
class NewsModel {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String nationality; // 'international' hoặc quốc tịch cụ thể
  final DateTime publishDate;
  final String author;
  final int views;
  final int likes;
  final int comments;
  final List<String> tags;
  final bool isPinned;
  final String category;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.nationality,
    required this.publishDate,
    required this.author,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.tags = const [],
    this.isPinned = false,
    this.category = 'General',
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      nationality: json['nationality'],
      publishDate: DateTime.parse(json['publishDate']),
      author: json['author'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isPinned: json['isPinned'] ?? false,
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'nationality': nationality,
      'publishDate': publishDate.toIso8601String(),
      'author': author,
      'views': views,
      'likes': likes,
      'comments': comments,
      'tags': tags,
      'isPinned': isPinned,
      'category': category,
    };
  }

  // Sample data for demonstration
  static List<NewsModel> getSampleNews() {
    return [
      NewsModel(
        id: '1',
        title: 'Keimyung University Welcomes International Students',
        content: 'Keimyung University is excited to announce the arrival of new international students for the upcoming semester. A series of orientation events are planned to help them settle in.',
        imageUrl: 'https://picsum.photos/400/300?random=1',
        nationality: 'international',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        author: 'KMU Admin',
        views: 1200,
        likes: 45,
        comments: 12,
        tags: ['University', 'International', 'Students'],
        isPinned: true,
        category: 'University News',
      ),
      NewsModel(
        id: '2',
        title: 'Scholarship Opportunities for Korean Students',
        content: 'New scholarship programs are now available for eligible Korean students. Apply before the deadline to secure your funding for the next academic year.',
        imageUrl: 'https://picsum.photos/400/300?random=2',
        nationality: 'korea',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        author: 'Scholarship Office',
        views: 850,
        likes: 32,
        comments: 8,
        tags: ['Scholarship', 'Korean', 'Academics'],
        category: 'Scholarship',
      ),
      NewsModel(
        id: '3',
        title: 'Vietnamese Student Association Hosts Cultural Festival',
        content: 'The Vietnamese Student Association at Keimyung University is organizing a vibrant cultural festival showcasing traditional music, dance, and cuisine. All students are invited!',
        imageUrl: 'https://picsum.photos/400/300?random=3',
        nationality: 'vietnam',
        publishDate: DateTime.now().subtract(const Duration(days: 1)),
        author: 'VSA',
        views: 2300,
        likes: 78,
        comments: 25,
        tags: ['Culture', 'Vietnamese', 'Event'],
        isPinned: true,
        category: 'Cultural Event',
      ),
      NewsModel(
        id: '4',
        title: 'Global Exchange Program Applications Open',
        content: 'Students interested in studying abroad can now apply for the Global Exchange Program. Explore new cultures and gain international experience.',
        imageUrl: 'https://picsum.photos/400/300?random=4',
        nationality: 'international',
        publishDate: DateTime.now().subtract(const Duration(days: 10)),
        author: 'International Office',
        views: 1500,
        likes: 56,
        comments: 18,
        tags: ['Exchange', 'Global', 'Study Abroad'],
        category: 'Exchange Program',
      ),
      NewsModel(
        id: '5',
        title: 'New Research Grants for Science and Engineering',
        content: 'The university has announced new research grants for students and faculty in the fields of science and engineering. Submit your proposals by next month.',
        imageUrl: 'https://picsum.photos/400/300?random=5',
        nationality: 'korea',
        publishDate: DateTime.now().subtract(const Duration(hours: 12)),
        author: 'Research Dept.',
        views: 600,
        likes: 23,
        comments: 5,
        tags: ['Research', 'Science', 'Engineering'],
        category: 'Research',
      ),
      NewsModel(
        id: '6',
        title: 'Campus Facilities Upgrade Project Underway',
        content: 'Several campus buildings are undergoing renovations to provide better facilities for students. Expect some temporary disruptions.',
        imageUrl: 'https://picsum.photos/400/300?random=6',
        nationality: 'international',
        publishDate: DateTime.now().subtract(const Duration(days: 3)),
        author: 'Facilities Management',
        views: 900,
        likes: 34,
        comments: 9,
        tags: ['Campus', 'Facilities', 'Upgrade'],
        category: 'Campus News',
      ),
      NewsModel(
        id: '7',
        title: 'Chinese Student Association Spring Festival',
        content: 'Join the Chinese Student Association for our annual Spring Festival celebration with traditional performances and delicious food.',
        imageUrl: 'https://picsum.photos/400/300?random=7',
        nationality: 'china',
        publishDate: DateTime.now().subtract(const Duration(days: 4)),
        author: 'CSA',
        views: 1100,
        likes: 41,
        comments: 14,
        tags: ['Culture', 'Chinese', 'Festival'],
        category: 'Cultural Event',
      ),
      NewsModel(
        id: '8',
        title: 'International Job Fair 2024',
        content: 'Don\'t miss the International Job Fair featuring companies from around the world. Perfect opportunity for international students.',
        imageUrl: 'https://picsum.photos/400/300?random=8',
        nationality: 'international',
        publishDate: DateTime.now().subtract(const Duration(days: 7)),
        author: 'Career Center',
        views: 1800,
        likes: 67,
        comments: 22,
        tags: ['Career', 'Job Fair', 'International'],
        isPinned: true,
        category: 'Career',
      ),
    ];
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishDate);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${publishDate.day}/${publishDate.month}/${publishDate.year}';
    }
  }

  String get formattedViews {
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}k';
    }
    return views.toString();
  }
}
