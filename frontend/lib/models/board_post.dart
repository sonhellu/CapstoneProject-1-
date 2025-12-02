// lib/models/board_post.dart
class BoardPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isAnonymous;
  final String? preview;

  BoardPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isAnonymous = false,
    this.preview,
  });
  
  /// Factory constructor từ API response
  factory BoardPost.fromJson(Map<String, dynamic> json) {
    return BoardPost(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author']?['nickname'] ?? 'Unknown',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isAnonymous: json['is_anonymous'] ?? false,
      preview: json['preview'],
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': {'nickname': author},
      'created_at': createdAt.toIso8601String(),
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_anonymous': isAnonymous,
      'preview': preview,
    };
  }
}
