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
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _matchStatus; // 'active', 'completed', 'cancelled'
  bool _showAcceptedNotification = true; // Show notification when match is accepted
  bool _isInitialLoad = true; // Track first load to scroll to bottom

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
    _scrollController.dispose();
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
        
        // Debug: Log số lượng messages nhận được
        print('Loaded ${messages.length} messages for conversation ${widget.conversationId}');
        
        final List<_ChatMessage> loadedMessages = [];
        
        for (var msgData in messages) {
          if (msgData is Map<String, dynamic>) {
            final isSentByMe = msgData['is_sent_by_me'] as bool? ?? false;
            final content = msgData['content']?.toString() ?? '';
            
            // Skip empty messages
            if (content.isEmpty) {
              continue;
            }
            
            final createdAt = msgData['created_at']?.toString();
            
            DateTime? time;
            if (createdAt != null) {
              try {
                time = DateTime.parse(createdAt).toLocal();
              } catch (e) {
                print('Error parsing date: $createdAt, error: $e');
                time = DateTime.now();
              }
            } else {
              time = DateTime.now();
            }

            loadedMessages.add(
              _ChatMessage(
                text: content,
                isMine: isSentByMe,
                time: time,
              ),
            );
          } else {
            print('Warning: Message data is not a Map: $msgData');
          }
        }
        
        setState(() {
          _messages.clear();
          _messages.addAll(loadedMessages);
          
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
          _isInitialLoad = false;
        });
        
        // Scroll to bottom after loading messages
        // Always scroll to bottom when messages are loaded (not just first time)
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
      print('Error loading messages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải tin nhắn: ${e.toString()}'),
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

    // Optimistic update: Add message to UI immediately
    final tempMessage = _ChatMessage(
      text: text,
      isMine: true,
      time: DateTime.now(),
    );
    
    final tempMessageIndex = _messages.length; // Save index for potential removal
    
    setState(() {
      _isSending = true;
      _messages.add(tempMessage);
    });

    // Clear input immediately
    _controller.clear();
    
    // Scroll to bottom immediately to show the new message
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
      // Send message to server
      await MatchingService.sendMessage(
        conversationId: widget.conversationId,
        content: text,
      );

      // Reload messages to get the latest from server (with proper IDs and timestamps)
      await _loadMessages();
      
      setState(() {
        _isSending = false;
      });
      
      // Scroll to bottom after reload
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
      // Remove the optimistic message on error
      setState(() {
        _isSending = false;
        // Remove by index if still exists and at expected position
        if (tempMessageIndex < _messages.length && 
            _messages[tempMessageIndex].text == text &&
            _messages[tempMessageIndex].isMine) {
          _messages.removeAt(tempMessageIndex);
        }
      });
      
      // Restore the text to input field
      _controller.text = text;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi tin nhắn thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
                    : RefreshIndicator(
                        onRefresh: _loadMessages,
                        child: ListView.builder(
                          controller: _scrollController,
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
