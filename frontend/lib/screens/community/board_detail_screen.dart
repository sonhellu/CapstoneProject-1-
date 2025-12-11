// lib/screens/community/board_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/board_post.dart';

class BoardDetailScreen extends StatelessWidget {
  final BoardPost post;
  const BoardDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${post.author} · ${post.createdAt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(post.content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
