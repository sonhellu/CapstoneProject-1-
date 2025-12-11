import 'dart:math';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'language_chat_room_screen.dart';

/// 조건을 선택한 뒤 들어오는 "언어교류 매칭" 화면.
/// 더미 유저 데이터에서 조건에 맞는 상대를 최대 5명까지 골라서 보여준다.
class MatchChatScreen extends StatefulWidget {
  final String targetLanguageCode; // 예: 'ko', 'en' ...
  final String preferredGender; // '여' | '남' | '상관없음'
  final String preferredCollege; // 단과대학명 | '상관없음'

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
  Future<List<_MatchResult>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _simulateMatch();
  }

  /// 실제 서비스에서는 서버/DB 질의로 교체될 부분
  Future<List<_MatchResult>> _simulateMatch() async {
    await Future.delayed(const Duration(milliseconds: 900));

    // 더미 유저 풀
    final users = <_User>[
      _User('Alice', '여', '경영대학', ['en', 'ko']),
      _User('Bob', '남', '공과대학', ['ko', 'ja']),
      _User('Chloe', '여', '간호대학', ['vi', 'ko']),
      _User('Dan', '남', '사회과학대학', ['zh', 'en']),
      _User('Emma', '여', '상관없음', ['ja', 'en']),
      _User('Fred', '남', '경영대학', ['en', 'ko']),
      _User('Gina', '여', '공과대학', ['ko', 'zh']),
    ];

    // 조건 필터
    final filtered = users.where((u) {
      final langOk = u.languages.contains(widget.targetLanguageCode);
      final genderOk =
          widget.preferredGender == '상관없음' || u.gender == widget.preferredGender;
      final collegeOk =
          widget.preferredCollege == '상관없음' || u.college == widget.preferredCollege;
      return langOk && genderOk && collegeOk;
    }).toList();

    if (filtered.isEmpty) return [];

    // 최대 5명까지 랜덤 선택
    final random = Random();
    filtered.shuffle(random);
    final picked = filtered.take(5).toList();

    final now = DateTime.now().millisecondsSinceEpoch;
    return picked
        .asMap()
        .entries
        .map(
          (e) => _MatchResult(
            user: e.value,
            roomId: 'room_${e.value.name}_${now}_${e.key}',
          ),
        )
        .toList();
  }

  String _langLabel(String code) {
    switch (code) {
      case 'ko':
        return '한국어';
      case 'en':
        return '영어';
      case 'ja':
        return '일본어';
      case 'vi':
        return '베트남어';
      case 'zh':
        return '중국어';
      case 'my':
        return '버마어';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetLangLabel = _langLabel(widget.targetLanguageCode);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).languageExchangeMatching)),
      body: FutureBuilder<List<_MatchResult>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            // 조건에 맞는 상대가 1명도 없을 때
            return _NoMatchView(
              targetLang: targetLangLabel,
              onRetry: () {
                setState(() {
                  _future = _simulateMatch();
                });
              },
            );
          }

          // 조건에 맞는 상대가 1명 이상 있을 때 → 최대 5명 리스트
          return _MatchListView(
            results: results,
            targetLang: targetLangLabel,
            onStartChat: (item) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LanguageChatRoomScreen(
                    roomId: item.roomId,
                    partnerName: item.user.name,
                    targetLanguageLabel: targetLangLabel,
                  ),
                ),
              );
            },
            onBack: () => Navigator.pop(context),
          );
        },
      ),
    );
  }
}

/// 여러 명의 매칭 결과를 보여주는 리스트 뷰
class _MatchListView extends StatelessWidget {
  final List<_MatchResult> results;
  final String targetLang;
  final void Function(_MatchResult) onStartChat;
  final VoidCallback onBack;

  const _MatchListView({
    required this.results,
    required this.targetLang,
    required this.onStartChat,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 배너
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).matchFound),
              ],
            ),
          ),

          Text(
            '${AppLocalizations.of(context).targetLanguage}: $targetLang',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          // 프로필 리스트
          Expanded(
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = results[index];
                final user = item.user;

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              child: Text(
                                user.name.substring(0, 1),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('${AppLocalizations.of(context).gender}: ${user.gender}'),
                                Text('${AppLocalizations.of(context).college}: ${user.college}'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text(AppLocalizations.of(context).startChat),
                            onPressed: () => onStartChat(item),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: onBack,
              child: Text(AppLocalizations.of(context).goBack),
            ),
          ),
        ],
      ),
    );
  }
}

/// 조건에 맞는 상대가 없을 때
class _NoMatchView extends StatelessWidget {
  final String targetLang;
  final VoidCallback onRetry;

  const _NoMatchView({
    required this.targetLang,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 70),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).noMatchFound(targetLang),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              height: 44,
              child: FilledButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).tryAgain),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).changeConditions),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 내부용 더미 모델들
// ─────────────────────────────────────────────
class _User {
  final String name;
  final String gender; // '여' / '남'
  final String college;
  final List<String> languages;

  _User(this.name, this.gender, this.college, this.languages);
}

class _MatchResult {
  final _User user;
  final String roomId;

  _MatchResult({
    required this.user,
    required this.roomId,
  });
}
