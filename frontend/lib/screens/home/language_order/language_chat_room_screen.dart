import 'package:flutter/material.dart';
import '../../../services/matching_service.dart';
import '../../../l10n/app_localizations.dart';

/// 언어교류용 1:1 채팅방 (서버 API 연동) - Improved with avatars, better design, and performance
class LanguageChatRoomScreen extends StatefulWidget {
  final int conversationId;
  final String partnerName;
  final String targetLanguageLabel;

  const LanguageChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.partnerName,
    required this.targetLanguageLabel,
  });

  @override
  State<LanguageChatRoomScreen> createState() =>
      _LanguageChatRoomScreenState();
}

class _LanguageChatRoomScreenState extends State<LanguageChatRoomScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _matchStatus;
  bool _showAcceptedNotification = true;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startMessageRefresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Load messages from API
  Future<void> _loadMessages() async {
    if (_isSending) return; // Don't reload while sending
    
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await MatchingService.getMessages(
        conversationId: widget.conversationId,
        useCache: false,
      );

      if (mounted) {
        final messages = response['messages'] as List<dynamic>? ?? [];
        final matchStatus = response['match_status'] as String?;
        
        final List<_ChatMessage> loadedMessages = [];
        
        for (var msgData in messages) {
          if (msgData is Map<String, dynamic>) {
            final isSentByMe = msgData['is_sent_by_me'] as bool? ?? false;
            final content = msgData['content']?.toString() ?? '';
            
            if (content.isEmpty) continue;
            
            final createdAt = msgData['created_at']?.toString();
            DateTime? time;
            if (createdAt != null) {
              try {
                time = DateTime.parse(createdAt).toLocal();
              } catch (e) {
                time = DateTime.now();
              }
            } else {
              time = DateTime.now();
            }

            loadedMessages.add(
              _ChatMessage(
                messageId: msgData['id'] as int?,
                text: content,
                isMine: isSentByMe,
                time: time,
                senderName: msgData['sender_nickname'] as String?,
              ),
            );
          }
        }
        
        setState(() {
          _messages.clear();
          _messages.addAll(loadedMessages);
          _matchStatus = matchStatus;
          
          if (matchStatus == 'active' && _showAcceptedNotification) {
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  _showAcceptedNotification = false;
                });
              }
            });
          }
          
          _isLoading = false;
          _isInitialLoad = false;
        });
        
        if (_messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).cannotLoadMessages}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Start auto-refresh messages
  void _startMessageRefresh() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isSending && !_isLoading) {
        _loadMessages();
        _startMessageRefresh();
      }
    });
  }

  /// Send message via API
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    final tempMessage = _ChatMessage(
      messageId: null,
      text: text,
      isMine: true,
      time: DateTime.now(),
    );
    
    final tempMessageIndex = _messages.length;
    
    setState(() {
      _isSending = true;
      _messages.add(tempMessage);
    });

    _controller.clear();
    
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }

    try {
      await MatchingService.sendMessage(
        conversationId: widget.conversationId,
        content: text,
      );

      await _loadMessages();
      
      setState(() {
        _isSending = false;
      });
      
      if (_scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _isSending = false;
        if (tempMessageIndex < _messages.length && 
            _messages[tempMessageIndex].text == text &&
            _messages[tempMessageIndex].isMine) {
          _messages.removeAt(tempMessageIndex);
        }
      });
      
      _controller.text = text;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).sendMessageFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Delete message
  Future<void> _deleteMessage(_ChatMessage message) async {
    if (message.messageId == null || !message.isMine) return;

    try {
      await MatchingService.deleteMessage(
        conversationId: widget.conversationId,
        messageId: message.messageId!,
      );
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).cannotDeleteMessage}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    
    if (messageDate == today) {
      // Today: show time only
      return '$h:$m';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return '${l10n.yesterday} $h:$m';
    } else {
      // Older: show date and time
      final d = time.day.toString().padLeft(2, '0');
      final month = time.month.toString().padLeft(2, '0');
      return '$d/$month $h:$m';
    }
  }

  /// Get avatar color based on name (consistent color for same name)
  Color _getAvatarColor(String? name, bool isMine) {
    if (name == null || name.isEmpty) {
      return isMine 
          ? Theme.of(context).colorScheme.primary
          : Colors.grey[600]!;
    }
    
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

  /// Build avatar widget
  Widget _buildAvatar(String? name, bool isMine) {
    // Always use initials with consistent color (no external URLs to avoid CORS)
    return CircleAvatar(
      radius: 18,
      backgroundColor: _getAvatarColor(name, isMine),
      child: Text(
        (name?.isNotEmpty ?? false) ? name![0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Build message bubble with improved design
  Widget _buildMessageBubble(_ChatMessage msg, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Check if previous message is from same sender
    final isSameSender = index > 0 && _messages[index - 1].isMine == msg.isMine;
    final showAvatar = !isSameSender;
    
    final bubbleColor = msg.isMine
        ? theme.colorScheme.primary
        : (isDark ? Colors.grey[800] : Colors.grey[200]);
    final textColor = msg.isMine 
        ? Colors.white 
        : (isDark ? Colors.white : Colors.black87);

    final messageWidget = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      margin: EdgeInsets.only(
        top: showAvatar ? 8 : 2,
        bottom: 4,
        left: msg.isMine ? 50 : 0,
        right: msg.isMine ? 0 : 50,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.isMine ? 18 : 4),
          bottomRight: Radius.circular(msg.isMine ? 4 : 18),
        ),
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
        children: [
          Text(
            msg.text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(msg.time),
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              if (msg.isMine) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 14,
                  color: textColor.withOpacity(0.7),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (msg.isMine && msg.messageId != null) {
      return Dismissible(
        key: Key('message_${msg.messageId}_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        confirmDismiss: (direction) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return AlertDialog(
                title: Text(l10n.deleteMessage),
                content: Text(l10n.deleteMessageConfirm),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(l10n.deleteMessage.split(' ').first),
                  ),
                ],
              );
            },
          );
          return confirmed ?? false;
        },
        onDismissed: (direction) => _deleteMessage(msg),
        child: Row(
          mainAxisAlignment: msg.isMine 
              ? MainAxisAlignment.end 
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!msg.isMine && showAvatar) ...[
              _buildAvatar(msg.senderName, false),
              const SizedBox(width: 8),
            ],
            Flexible(child: messageWidget),
            if (msg.isMine && showAvatar) ...[
              const SizedBox(width: 8),
              _buildAvatar(msg.senderName, true),
            ],
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: msg.isMine 
          ? MainAxisAlignment.end 
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!msg.isMine && showAvatar) ...[
          _buildAvatar(msg.senderName, false),
          const SizedBox(width: 8),
        ],
        Flexible(child: messageWidget),
        if (msg.isMine && showAvatar) ...[
          const SizedBox(width: 8),
          _buildAvatar(msg.senderName, true),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = '${widget.partnerName} · ${widget.targetLanguageLabel}';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _getAvatarColor(widget.partnerName, false),
              child: Text(
                widget.partnerName.isNotEmpty 
                    ? widget.partnerName[0].toUpperCase() 
                    : '?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.partnerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.targetLanguageLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 1,
      ),
      body: Column(
        children: [
          if (_showAcceptedNotification && _matchStatus == 'active')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).matchAccepted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showAcceptedNotification = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).noMessagesYet,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).startConversation,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMessages,
                        color: theme.colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index], index);
                          },
                        ),
                      ),
          ),
          
          // Input area with improved design
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).typeMessage,
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                          enabled: !_isSending,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSending ? null : _sendMessage,
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            width: 56,
                            height: 56,
                            padding: const EdgeInsets.all(16),
                            child: _isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final int? messageId;
  final String text;
  final bool isMine;
  final DateTime time;
  final String? senderName;

  _ChatMessage({
    this.messageId,
    required this.text,
    required this.isMine,
    required this.time,
    this.senderName,
  });
}
