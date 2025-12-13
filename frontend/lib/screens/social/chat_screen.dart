import 'package:flutter/material.dart';
import '../home/language_order/language_chat_room_screen.dart';
import '../../models/language_chat_room.dart';
import '../../models/language_chat_history.dart';
import '../../services/matching_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  /// Load conversations from API
  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final conversationsData = await MatchingService.getConversations();
      
      setState(() {
        _conversations = conversationsData.map((conv) {
          final otherUser = conv['other_user'] as Map<String, dynamic>?;
          final lastMessage = conv['last_message'] as Map<String, dynamic>?;
          
          // Get target language from match if available, or use default
          String targetLanguageLabel = '언어교류'; // Default
          // TODO: Get target language from match data if available
          
          return Conversation(
            id: conv['id'] as int,
            partnerName: otherUser?['nickname'] as String? ?? 'Unknown',
            avatarUrl: 'https://i.pravatar.cc/150?img=${conv['id']}',
            lastMessage: lastMessage?['content'] as String? ?? '',
            lastMessageTime: lastMessage?['created_at'] != null
                ? DateTime.parse(lastMessage!['created_at'] as String)
                : DateTime.now(),
            unreadCount: conv['unread_count'] as int? ?? 0,
            targetLanguageLabel: targetLanguageLabel,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _conversations = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
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
      child: SafeArea(
        child: Column(
          children: [
            // Conversations list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _conversations.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = _conversations[index];
                            return _buildConversationItem(context, conversation, isDark);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, Conversation conversation, bool isDark) {
    return InkWell(
      onTap: () {
        // Mark conversation as read when opening
        MatchingService.markConversationRead(conversationId: conversation.id);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LanguageChatRoomScreen(
              conversationId: conversation.id,
              partnerName: conversation.partnerName,
              targetLanguageLabel: conversation.targetLanguageLabel,
            ),
          ),
        ).then((_) {
          // Reload conversations when returning to update unread count
          _loadConversations();
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.transparent : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(conversation.avatarUrl),
                  onBackgroundImageError: (_, __) {},
                  child: const Icon(Icons.person, size: 28),
                ),
                if (conversation.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Name and last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.partnerName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark 
                                ? (conversation.unreadCount > 0
                                    ? Colors.white
                                    : Colors.white70)
                                : (conversation.unreadCount > 0
                                    ? Colors.black87
                                    : Colors.grey[600]),
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with someone!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class Conversation {
  final int id;
  final String partnerName;
  final String avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String targetLanguageLabel;

  Conversation({
    required this.id,
    required this.partnerName,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.targetLanguageLabel,
  });
}
