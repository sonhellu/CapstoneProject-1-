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
  late Future<List<_User>> _future;
  bool _showMoreOptions = false;

  @override
  void initState() {
    super.initState();
    _future = _loadOnlineUsers();
  }

  Future<List<_User>> _loadOnlineUsers() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final allUsers = <_User>[
      _User('alice', '여', '경영대학', ['en', 'ko'], true, 'https://i.pravatar.cc/150?img=1'),
      _User('bob', '남', '공과대학', ['ko', 'ja'], true, 'https://i.pravatar.cc/150?img=2'),
      _User('chloe', '여', '간호대학', ['vi', 'ko'], true, 'https://i.pravatar.cc/150?img=3'),
      _User('dan', '남', '사회과학대학', ['zh', 'en'], true, 'https://i.pravatar.cc/150?img=4'),
      _User('emma', '여', '상관없음', ['ja', 'en'], true, 'https://i.pravatar.cc/150?img=5'),
      _User('frank', '남', '공과대학', ['ko', 'vi'], true, 'https://i.pravatar.cc/150?img=6'),
      _User('grace', '여', '경영대학', ['en', 'zh'], true, 'https://i.pravatar.cc/150?img=7'),
      _User('henry', '남', '사범대학', ['ja', 'ko'], true, 'https://i.pravatar.cc/150?img=8'),
    ];
    
    final filtered = allUsers.where((u) {
      final langOk = u.languages.contains(widget.targetLanguageCode);
      final genderOk = widget.preferredGender == '상관없음' || u.gender == widget.preferredGender;
      final collegeOk = widget.preferredCollege == '상관없음' || u.college == widget.preferredCollege;
      return langOk && genderOk && collegeOk && u.isOnline;
    }).toList();

    // Giới hạn chỉ hiển thị 5 người dùng online
    return filtered.take(5).toList();
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
      appBar: AppBar(
        title: const Text('언어교류 매칭'),
        actions: [
          IconButton(
            icon: Icon(_showMoreOptions ? Icons.close : Icons.more_vert),
            onPressed: () {
              setState(() {
                _showMoreOptions = !_showMoreOptions;
              });
            },
            tooltip: 'More Options',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // More Options Panel
            if (_showMoreOptions) _buildMoreOptionsPanel(),
            
            // Main Content
            Expanded(
              child: FutureBuilder<List<_User>>(
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
                          Text('온라인 사용자 로딩 중...'),
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
                              onPressed: () => setState(() => _future = _loadOnlineUsers()),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              );
            }

                  final users = snap.data ?? [];
                  if (users.isEmpty) {
              return _NoMatchView(
                targetLang: _langLabel(widget.targetLanguageCode),
                      onRetry: () => setState(() => _future = _loadOnlineUsers()),
              );
            }
                  
                  return _OnlineUsersListView(
                    users: users,
              targetLang: _langLabel(widget.targetLanguageCode),
                    targetLanguageCode: widget.targetLanguageCode,
            );
          },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptionsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '필터 옵션',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('전체 보기', () {
                setState(() {
                  _future = _loadOnlineUsers();
                  _showMoreOptions = false;
                });
              }),
              _buildFilterChip('온라인만', () {
                setState(() {
                  _future = _loadOnlineUsers();
                  _showMoreOptions = false;
                });
              }),
              _buildFilterChip('최근 활동', () {
                setState(() {
                  _future = _loadOnlineUsers();
                  _showMoreOptions = false;
                });
              }),
              _buildFilterChip('인기순', () {
                setState(() {
                  _future = _loadOnlineUsers();
                  _showMoreOptions = false;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _OnlineUsersListView extends StatelessWidget {
  final List<_User> users;
  final String targetLang;
  final String targetLanguageCode;

  const _OnlineUsersListView({
    required this.users,
    required this.targetLang,
    required this.targetLanguageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '온라인 사용자 (${users.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
          const Spacer(),
              Text(
                '대상 언어: $targetLang',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        
        // Users List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserCard(
                user: user,
                targetLang: targetLang,
                targetLanguageCode: targetLanguageCode,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final _User user;
  final String targetLang;
  final String targetLanguageCode;

  const _UserCard({
    required this.user,
    required this.targetLang,
    required this.targetLanguageCode,
  });

  @override
  Widget build(BuildContext context) {
    final roomId = 'room_${user.name}_${DateTime.now().millisecondsSinceEpoch}';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(
                conversationId: int.tryParse(roomId) ?? 1,
                partnerName: user.name,
                targetLanguageLabel: targetLang,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.avatarUrl),
                    onBackgroundImageError: (_, __) {},
                    child: user.avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '온라인',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.college} · ${user.gender}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: user.languages.map((lang) {
                        return Chip(
                          label: Text(
                            _getLanguageLabel(lang),
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              // Chat Button
              IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
                color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomScreen(
                        conversationId: int.tryParse(roomId) ?? 1,
                        partnerName: user.name,
                      targetLanguageLabel: targetLang,
                    ),
                  ),
                );
              },
            ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageLabel(String code) {
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
  final bool isOnline;
  final String avatarUrl;
  
  _User(
    this.name,
    this.gender,
    this.college,
    this.languages,
    this.isOnline,
    this.avatarUrl,
  );
}
