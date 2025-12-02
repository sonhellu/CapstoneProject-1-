import 'dart:math';
import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class MatchChatScreen extends StatefulWidget {
  final String targetLanguageCode;  // 'ko','en',...
  final String preferredGender;     // '여' | '남' | '상관없음'
  final String preferredCollege;    // 단과대학명 | '상관없음'

  const MatchChatScreen({
    super.key,
    required this.targetLanguageCode,
    required this.preferredGender,
    required this.preferredCollege,
  });

  @override
  State<MatchChatScreen> createState() => _MatchChatScreenState();
}

class _MatchChatScreenState extends State<MatchChatScreen> {
  late Future<_MatchResult?> _future;

  @override
  void initState() {
    super.initState();
    _future = _simulateMatch();
  }

  Future<_MatchResult?> _simulateMatch() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final users = <_User>[
      _User('alice', '여', '경영대학', ['en', 'ko']),
      _User('bob', '남', '공과대학', ['ko', 'ja']),
      _User('chloe', '여', '간호대학', ['vi', 'ko']),
      _User('dan', '남', '사회과학대학', ['zh', 'en']),
      _User('emma', '여', '상관없음', ['ja', 'en']),
    ];
    final filtered = users.where((u) {
      final langOk = u.languages.contains(widget.targetLanguageCode);
      final genderOk = widget.preferredGender == '상관없음' || u.gender == widget.preferredGender;
      final collegeOk = widget.preferredCollege == '상관없음' || u.college == widget.preferredCollege;
      return langOk && genderOk && collegeOk;
    }).toList();

    if (filtered.isEmpty) return null;
    final pick = filtered[Random().nextInt(filtered.length)];
    final roomId = 'room_${pick.name}_${DateTime.now().millisecondsSinceEpoch}';
    return _MatchResult(user: pick, roomId: roomId);
  }

  String _langLabel(String code) {
    switch (code) {
      case 'ko': return '한국어';
      case 'en': return '영어';
      case 'ja': return '일본어';
      case 'vi': return '베트남어';
      case 'zh': return '중국어';
      case 'my': return '버마어';
      default: return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('언어교류 매칭')),
      body: SafeArea(
        child: FutureBuilder<_MatchResult?>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting ||
                snap.connectionState == ConnectionState.active) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('매칭 중...'),
                  ],
                ),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text('문제가 발생했어요:\n${snap.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => setState(() => _future = _simulateMatch()),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final result = snap.data;
            if (result == null) {
              return _NoMatchView(
                targetLang: _langLabel(widget.targetLanguageCode),
                onRetry: () => setState(() => _future = _simulateMatch()),
              );
            }
            return _MatchFoundView(
              result: result,
              targetLang: _langLabel(widget.targetLanguageCode),
            );
          },
        ),
      ),
    );
  }
}

class _MatchFoundView extends StatelessWidget {
  final _MatchResult result;
  final String targetLang;
  const _MatchFoundView({required this.result, required this.targetLang});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 1,
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('${result.user.name} 님을 찾았어요!'),
              subtitle: Text('단과대학: ${result.user.college} · 성별: ${result.user.gender}'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 12),
          Text('대상 언어: $targetLang'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('채팅 시작'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomScreen(
                      conversationId: int.tryParse(result.roomId) ?? 1, // Convert roomId to conversationId
                      partnerName: result.user.name,
                      targetLanguageLabel: targetLang,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMatchView extends StatelessWidget {
  final String targetLang;
  final VoidCallback onRetry;
  const _NoMatchView({required this.targetLang, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 56),
          const SizedBox(height: 12),
          Text('조건에 맞는 상대를 찾지 못했어요.\n(대상 언어: $targetLang)', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('조건 변경하기'),
          ),
        ],
      ),
    );
  }
}

class _User {
  final String name;
  final String gender;
  final String college;
  final List<String> languages;
  _User(this.name, this.gender, this.college, this.languages);
}

class _MatchResult {
  final _User user;
  final String roomId;
  _MatchResult({required this.user, required this.roomId});
}
