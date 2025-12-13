import 'package:flutter/material.dart';
import '../../../services/matching_service.dart';
import '../../../l10n/app_localizations.dart';

/// 언어교류용 1:1 채팅방 (서버 API 연동)
class LanguageChatRoomScreen extends StatefulWidget {
  final int conversationId; // Conversation ID from backend
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
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _matchStatus; // 'active', 'completed', 'cancelled'
  bool _showAcceptedNotification = true; // Show notification when match is accepted

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Auto-refresh messages every 3 seconds
    _startMessageRefresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Load messages from API
  Future<void> _loadMessages() async {
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
        
        setState(() {
          _messages.clear();
          for (var msgData in messages) {
            if (msgData is Map<String, dynamic>) {
              final isSentByMe = msgData['is_sent_by_me'] as bool? ?? false;
              final content = msgData['content']?.toString() ?? '';
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

              _messages.add(
                _ChatMessage(
                  text: content,
                  isMine: isSentByMe,
                  time: time,
                ),
              );
            }
          }
          
          // Update match status
          _matchStatus = matchStatus;
          
          // Hide notification after first load if match is active
          if (matchStatus == 'active' && _showAcceptedNotification) {
            // Keep showing for a bit, then hide
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  _showAcceptedNotification = false;
                });
              }
            });
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Start auto-refresh messages
  void _startMessageRefresh() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isSending) {
        _loadMessages();
        _startMessageRefresh(); // Schedule next refresh
      }
    });
  }

  /// Send message via API
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await MatchingService.sendMessage(
        conversationId: widget.conversationId,
        content: text,
      );

      _controller.clear();
      
      // Reload messages to get the latest
      await _loadMessages();
      
      setState(() {
        _isSending = false;
      });
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m'; // 24시간 표기
  }

  @override
  Widget build(BuildContext context) {
    final title = '${widget.partnerName} · ${widget.targetLanguageLabel}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          // Match accepted notification
          if (_showAcceptedNotification && _matchStatus == 'active')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).matchAccepted,
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: Colors.green[700],
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
                        child: Text(
                          AppLocalizations.of(context).noMessagesYet,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final alignment =
                              msg.isMine ? Alignment.centerRight : Alignment.centerLeft;
                          final bubbleColor = msg.isMine
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade200;
                          final textColor = msg.isMine ? Colors.white : Colors.black87;

                          return Align(
                            alignment: alignment,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: msg.isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.text,
                                    style: TextStyle(color: textColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(msg.time),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: textColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).typeMessage,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isSending,
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMine;
  final DateTime time;

  _ChatMessage({
    required this.text,
    required this.isMine,
    required this.time,
  });
}
