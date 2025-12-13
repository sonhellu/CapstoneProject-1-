import 'dart:math';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/matching_service.dart';
import '../../../services/options_service.dart';

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

  /// Tìm người phù hợp từ API thực tế
  Future<List<_MatchResult>> _simulateMatch() async {
    try {
      // 1. Tạo match request với target_language
      final collegeId = await _getCollegeId(widget.preferredCollege);
      final matchRequest = await MatchingService.createMatchRequest(
        targetLanguage: widget.targetLanguageCode, // Required: Ngôn ngữ muốn học
        preferredGender: _mapGenderToApi(widget.preferredGender),
        preferredCollegeId: collegeId,
        notes: 'Language exchange: Learning ${widget.targetLanguageCode}',
      );
      
      // Check for error in response
      if (matchRequest.containsKey('error')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${matchRequest['error']}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return [];
      }
      
      final requestId = matchRequest['id'] as int?;
      if (requestId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create match request'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return [];
      }
      
      // 2. Tìm helpers phù hợp
      final helpers = await MatchingService.findHelpers(
        requestId: requestId,
        limit: 5,
      );
      
      // Debug: Check response type and content
      if (helpers.isEmpty) {
        // No helpers found - this is normal if no users match the criteria
        return [];
      }
      
      // 3. Convert API response thành _MatchResult
      final now = DateTime.now().millisecondsSinceEpoch;
      try {
        return helpers.asMap().entries.map((entry) {
          final index = entry.key;
          final helperData = entry.value;
          
          // Ensure helperData is a Map
          if (helperData is! Map<String, dynamic>) {
            // Try to convert if it's a different type
            throw FormatException('Helper data is not a Map: ${helperData.runtimeType}');
          }
          
          final helper = helperData as Map<String, dynamic>;
          final helperId = helper['id'];
          if (helperId == null) {
            throw FormatException('Helper data missing id: $helper');
          }
          
          final helperIdInt = helperId is int ? helperId : int.tryParse(helperId.toString());
          if (helperIdInt == null) {
            throw FormatException('Invalid helper id: $helperId');
          }
          
          final nickname = helper['nickname']?.toString() ?? helper['realname']?.toString() ?? 'Unknown';
          final gender = helper['gender']?.toString() ?? 'any';
          
          return _MatchResult(
            user: _User(
              nickname,
              _mapGenderFromApi(gender),
              widget.preferredCollege, // Use selected college for display
              [helper['main_language']?.toString() ?? widget.targetLanguageCode], // Languages they can help with
            ),
            roomId: 'room_${helperIdInt}_${now}_$index',
            helperId: helperIdInt, // Store helper ID for future use
          );
        }).toList();
      } catch (e) {
        // Show detailed error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error parsing helpers: ${e.toString()}\nData: ${helpers.toString()}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return [];
      }
    } catch (e) {
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finding match: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return [];
    }
  }
  
  /// Map gender from UI to API format
  String _mapGenderToApi(String uiGender) {
    switch (uiGender) {
      case '여':
        return 'female';
      case '남':
        return 'male';
      case '상관없음':
      default:
        return 'any';
    }
  }
  
  /// Map gender from API to UI format
  String _mapGenderFromApi(String apiGender) {
    switch (apiGender.toLowerCase()) {
      case 'female':
        return '여';
      case 'male':
        return '남';
      default:
        return '상관없음';
    }
  }
  
  /// Get college ID from college name (if needed)
  Future<int?> _getCollegeId(String collegeName) async {
    if (collegeName == '상관없음') {
      return null;
    }
    // TODO: Map college name to ID if needed
    // For now, return null to search all colleges
    return null;
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
  final int? helperId; // Store helper ID for future API calls

  _MatchResult({
    required this.user,
    required this.roomId,
    this.helperId,
  });
}
