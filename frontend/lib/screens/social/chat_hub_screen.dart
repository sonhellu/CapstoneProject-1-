// lib/screens/social/chat_hub_screen.dart
/* import 'package:flutter/material.dart';

import '../../models/language_chat_history.dart';
import '../../models/language_chat_room.dart';
import 'chat_screen.dart';
import '../home/language_order/chat_room_screen.dart';

class ChatHubScreen extends StatelessWidget {
  const ChatHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rooms = LanguageChatHistory.getRooms();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Chat',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          /// 1) AI 챗봇 카드
          _ChatHubCard(
            leadingIcon: Icons.smart_toy_outlined,
            title: '캠퍼스 AI 챗봇',
            subtitle: '학교 생활 · 행정 · 시설 관련 질문을 도와줘요.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.red,
                      title: Text(AppLocalizations.of(context).appTitle),
                    ),
                    body: const ChatScreen(),   
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          /// 2) 언어교류 채팅 기록 섹션
          Text(
            '언어교류 채팅',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          if (rooms.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '아직 언어교류 채팅 기록이 없어요.\n홈 화면에서 매칭을 시작해보세요!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            )
          else
            Column(
              children: rooms
                  .map(
                    (room) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LanguageChatCard(room: room),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

/// 공통 카드 UI (AI 챗봇용)
class _ChatHubCard extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChatHubCard({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFF1E88E5)],
                  ),
                ),
                child: Icon(leadingIcon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// 언어교류 채팅방 카드
class _LanguageChatCard extends StatelessWidget {
  final LanguageChatRoom room;

  const _LanguageChatCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(
                roomId: room.roomId,
                partnerName: room.partnerName,
                targetLanguageLabel: room.targetLanguageLabel,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                child: Text(
                  room.partnerName.substring(0, 1),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.partnerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      room.targetLanguageLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.lastMessage.isEmpty
                          ? '아직 남긴 메시지가 없어요.'
                          : room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}*/
