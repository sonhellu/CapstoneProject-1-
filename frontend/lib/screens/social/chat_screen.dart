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
      
      // Filter to remove duplicates and conversations without messages
      final seenIds = <int>{};
      final filteredConversations = <Map<String, dynamic>>[];
      
      for (var conv in conversationsData) {
        final convId = conv['id'] as int?;
        final lastMessage = conv['last_message'] as Map<String, dynamic>?;
        
        // Skip if duplicate or no message
        if (convId == null || seenIds.contains(convId) || lastMessage == null) {
          continue;
        }
        
        seenIds.add(convId);
        filteredConversations.add(conv);
      }
      
      setState(() {
        _conversations = filteredConversations.map((conv) {
          final otherUser = conv['other_user'] as Map<String, dynamic>?;
          final lastMessage = conv['last_message'] as Map<String, dynamic>?;
          final otherUserId = otherUser?['id'] as int?;
          
          // Get target language from match if available, or use default
          String targetLanguageLabel = '언어교류'; // Default
          // TODO: Get target language from match data if available
          
          final partnerName = otherUser?['nickname'] as String? ?? 'Unknown';
          
          return Conversation(
            id: conv['id'] as int,
            partnerName: partnerName,
            avatarUrl: '', // Will use initials instead of external URL
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
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          itemCount: _conversations.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 4),
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

  /// Delete conversation from database
  Future<void> _deleteConversation(int conversationId) async {
    try {
      print('Deleting conversation: $conversationId');
      
      // Remove from local list immediately (optimistic update)
      final conversationToDelete = _conversations.firstWhere(
        (conv) => conv.id == conversationId,
        orElse: () => throw Exception('Conversation not found'),
      );
      
      setState(() {
        _conversations.removeWhere((conv) => conv.id == conversationId);
      });
      
      // Call API to delete from database
      final response = await MatchingService.deleteConversation(conversationId: conversationId);
      print('Delete response: $response');
      
      // Check for error in response
      if (response is Map<String, dynamic> && response.containsKey('error')) {
        // Restore conversation if delete failed
        setState(() {
          _conversations.add(conversationToDelete);
          _conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        });
        throw Exception(response['error']);
      }
      
      // Success - show notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa cuộc trò chuyện'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error deleting conversation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xóa cuộc trò chuyện: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildConversationItem(BuildContext context, Conversation conversation, bool isDark) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key('conversation_${conversation.id}'),
      direction: DismissDirection.endToStart, // Swipe left to delete
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Xóa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.delete,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa cuộc trò chuyện'),
            content: Text(
              'Bạn có chắc chắn muốn xóa cuộc trò chuyện với ${conversation.partnerName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
        );
        
        if (confirmed == true) {
          // Delete conversation if confirmed
          await _deleteConversation(conversation.id);
          return true;
        }
        
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
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
              _loadConversations();
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF1E1E1E) 
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with improved design
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: conversation.unreadCount > 0
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: _getAvatarColor(conversation.partnerName),
                      child: Text(
                        conversation.partnerName.isNotEmpty
                            ? conversation.partnerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (conversation.unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Name and last message with improved spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.partnerName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(conversation.lastMessageTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey[500],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage.isNotEmpty
                                ? conversation.lastMessage
                                : 'Tin nhắn mới',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.3,
                              color: isDark 
                                  ? (conversation.unreadCount > 0
                                      ? Colors.white
                                      : Colors.white60)
                                  : (conversation.unreadCount > 0
                                      ? Colors.black87
                                      : Colors.grey[600]),
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 2,
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
        ),
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

  /// Get avatar color based on name (consistent color for same name)
  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.grey;
    
    // Generate consistent color from name hash
    int hash = name.hashCode;
    final colors = [
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.red[600]!,
      Colors.teal[600]!,
      Colors.pink[600]!,
      Colors.indigo[600]!,
      Colors.cyan[600]!,
      Colors.amber[600]!,
    ];
    return colors[hash.abs() % colors.length];
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
