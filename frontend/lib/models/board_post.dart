// lib/models/board_post.dart
class BoardPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;

  BoardPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
  });
}
