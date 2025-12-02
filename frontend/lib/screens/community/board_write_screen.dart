// lib/screens/community/board_write_screen.dart
import 'package:flutter/material.dart';
import 'board_screen.dart'; // BoardCategory 쓰려고 import

class BoardWriteScreen extends StatefulWidget {
  final BoardCategory category;

  const BoardWriteScreen({super.key, required this.category});

  @override
  State<BoardWriteScreen> createState() => _BoardWriteScreenState();
}

class _BoardWriteScreenState extends State<BoardWriteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: '내용',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: 임시 저장 로직
                      Navigator.pop(context);
                    },
                    child: const Text('저장하기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      // TODO: 게시하기 로직 (서버/리스트에 추가)
                      Navigator.pop(context);
                    },
                    child: const Text('게시하기'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
