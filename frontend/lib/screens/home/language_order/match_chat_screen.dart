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
    if (!mounted) return [];
    final context = this.context;
    try {
      // 1. Tạo match request với target_language
      final collegeId = await _getCollegeId(widget.preferredCollege, context);
      final matchRequest = await MatchingService.createMatchRequest(
        targetLanguage: widget.targetLanguageCode, // Required: Ngôn ngữ muốn học
        preferredGender: _mapGenderToApi(widget.preferredGender, context),
        preferredCollegeId: collegeId,
        notes: 'Language exchange: Learning ${widget.targetLanguageCode}',
      );
      
      // Check for error in response
      if (matchRequest.containsKey('error')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context).error}: ${matchRequest['error']}'),
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
            SnackBar(
              content: Text(AppLocalizations.of(context).failedToCreateMatchRequest),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
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
      if (!mounted) return [];
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
              _mapGenderFromApi(gender, context),
              widget.preferredCollege, // Use selected college for display
              [helper['main_language']?.toString() ?? widget.targetLanguageCode], // Languages they can help with
            ),
            roomId: 'room_${helperIdInt}_${now}_$index', // Temporary roomId, will be replaced with conversation_id
            helperId: helperIdInt, // Store helper ID for accept match
            requestId: requestId, // Store request ID for accept match
          );
        }).toList();
      } catch (e) {
        // Show detailed error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context).errorParsingHelpers}: ${e.toString()}\nData: ${helpers.toString()}'),
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
            content: Text('${AppLocalizations.of(context).errorFindingMatch}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return [];
    }
  }
  
  /// Map gender from UI to API format (so sánh với localized text)
  String _mapGenderToApi(String uiGender, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (uiGender == l10n.female) {
      return 'female';
    } else if (uiGender == l10n.male) {
      return 'male';
    } else {
      return 'any';
    }
  }
  
  /// Map gender from API to UI format (trả về localized text)
  String _mapGenderFromApi(String apiGender, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (apiGender.toLowerCase()) {
      case 'female':
        return l10n.female;
      case 'male':
        return l10n.male;
      default:
        return l10n.noPreference;
    }
  }
  
  /// Get college ID from college name (if needed)
  Future<int?> _getCollegeId(String collegeName, BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    // Check if it's noPreference in current language or any other language
    const noPreferenceTexts = [
      'No Preference',
      '상관없음',
      'Không quan trọng',
      '无偏好',
      '指定なし',
      'အကြိုက်မရွေး',
    ];
    if (collegeName == l10n.noPreference || noPreferenceTexts.contains(collegeName)) {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final targetLangLabel = _langLabel(widget.targetLanguageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).languageExchangeMatching),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF121212),
                ]
              : [
                  Colors.red[50]!,
                  Colors.white,
                ],
          ),
        ),
        child: FutureBuilder<List<_MatchResult>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).searching,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final results = snapshot.data ?? [];

            if (results.isEmpty) {
              // 조건에 맞는 상대가 1명도 없을 때
              return _NoMatchView(
                targetLang: targetLangLabel,
                isDark: isDark,
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
            isDark: isDark,
            onStartChat: (item) async {
              // Accept match và tạo conversation trước khi vào chat room
              if (item.requestId == null || item.helperId == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).missingMatchInformation),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              // Show loading dialog
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              try {
                // Step 1: Offer match trước (chuyển status từ pending sang offered)
                final offerResult = await MatchingService.offerMatch(
                  requestId: item.requestId!,
                  mentorUserId: item.helperId!,
                );

                if (offerResult.containsKey('error')) {
                  if (mounted) {
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppLocalizations.of(context).errorOfferingMatch}: ${offerResult['error']}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                // Step 2: Accept match để tạo conversation (chuyển từ offered sang accepted)
                final acceptResult = await MatchingService.acceptMatch(
                  requestId: item.requestId!,
                  mentorUserId: item.helperId!,
                );

                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                }

                if (acceptResult.containsKey('error')) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppLocalizations.of(context).errorAcceptingMatch}: ${acceptResult['error']}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                final conversationId = acceptResult['conversation_id'] as int?;
                if (conversationId == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).failedToCreateConversation),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                // Navigate to chat room với conversation_id
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LanguageChatRoomScreen(
                        conversationId: conversationId,
                        partnerName: item.user.name,
                        targetLanguageLabel: targetLangLabel,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog if still open
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${AppLocalizations.of(context).error}: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            onBack: () => Navigator.pop(context),
          );
          },
        ),
      ),
    );
  }
}

/// 여러 명의 매칭 결과를 보여주는 리스트 뷰
class _MatchListView extends StatelessWidget {
  final List<_MatchResult> results;
  final String targetLang;
  final bool isDark;
  final void Function(_MatchResult) onStartChat;
  final VoidCallback onBack;

  const _MatchListView({
    required this.results,
    required this.targetLang,
    required this.isDark,
    required this.onStartChat,
    required this.onBack,
  });
  
  /// Check if college name is "noPreference" in any language
  bool _isNoPreference(String collegeName, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // List of all possible "noPreference" texts in different languages
    const noPreferenceTexts = [
      'No Preference',
      '상관없음',
      'Không quan trọng',
      '无偏好',
      '指定なし',
      'အကြိုက်မရွေး',
    ];
    // Check if it matches current language's noPreference or any other language's
    return collegeName == l10n.noPreference || noPreferenceTexts.contains(collegeName);
  }
  
  /// Get localized college text (if it's noPreference, return current language's noPreference)
  String _getLocalizedCollegeText(String collegeName, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isNoPreference(collegeName, context)) {
      return l10n.noPreference;
    }
    return collegeName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 배너 - Improved design
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${AppLocalizations.of(context).matchFound} (${results.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Target language info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${AppLocalizations.of(context).targetLanguage}: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  Text(
                    targetLang,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // 프로필 리스트 - Improved design
            Expanded(
              child: ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = results[index];
                  final user = item.user;
                  final colors = [
                    [Colors.blue, Colors.purple],
                    [Colors.pink, Colors.red],
                    [Colors.orange, Colors.deepOrange],
                    [Colors.teal, Colors.cyan],
                    [Colors.indigo, Colors.blue],
                  ];
                  final colorPair = colors[index % colors.length];

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Improved Avatar with gradient
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: colorPair,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorPair[0].withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    user.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: isDark ? Colors.white60 : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          user.gender,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: isDark ? Colors.white60 : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.school_outlined,
                                          size: 16,
                                          color: isDark ? Colors.white60 : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _getLocalizedCollegeText(user.college, context),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: isDark ? Colors.white60 : Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              icon: const Icon(Icons.chat_bubble_outline, size: 20),
                              label: Text(
                                AppLocalizations.of(context).startChat,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
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

            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: Text(
                  AppLocalizations.of(context).goBack,
                  style: const TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onBack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 조건에 맞는 상대가 없을 때
class _NoMatchView extends StatelessWidget {
  final String targetLang;
  final bool isDark;
  final VoidCallback onRetry;

  const _NoMatchView({
    required this.targetLang,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 80,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context).noMatchFound(targetLang),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).tryAgainLater,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(
                  AppLocalizations.of(context).tryAgain,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onRetry,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: Text(AppLocalizations.of(context).changeConditions),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
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
  final int? helperId; // Store helper ID for accept match
  final int? requestId; // Store request ID for accept match

  _MatchResult({
    required this.user,
    required this.roomId,
    this.helperId,
    this.requestId,
  });
}
