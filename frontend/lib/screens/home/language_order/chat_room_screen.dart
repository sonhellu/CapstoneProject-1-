import 'package:flutter/material.dart';
import '../../../services/matching_service.dart';
import '../../../services/api_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final int conversationId; // Thay roomId bằng conversationId từ backend
  final String partnerName;
  final String targetLanguageLabel;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.partnerName,
    required this.targetLanguageLabel,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _controller = TextEditingController();
  final List<_Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Load messages từ API
  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final messagesData = await MatchingService.getMessages(
        conversationId: widget.conversationId,
      );

      final messages = messagesData.map((msgData) {
        return _Message(
          id: msgData['id']?.toString() ?? '',
          content: msgData['content'] ?? '',
          senderId: msgData['sender_user_id'] ?? 0,
          createdAt: DateTime.tryParse(msgData['created_at'] ?? '') ?? DateTime.now(),
        );
      }).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(messages);
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải tin nhắn: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Gửi tin nhắn
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await MatchingService.sendMessage(
        conversationId: widget.conversationId,
        content: text,
      );

      _controller.clear();
      
      // Reload messages
      await _loadMessages();
      
      setState(() {
        _isSending = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _isSending = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi tin nhắn: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.partnerName} · ${widget.targetLanguageLabel}'),
            Text(
              'Conversation ID: ${widget.conversationId}',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading indicator
          if (_isLoading && _messages.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null && _messages.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadMessages,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final msg = _messages[i];
                  // TODO: So sánh với current user ID để xác định left/right
                  final isMe = i.isEven; // Tạm thời dùng logic này
                  
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.content),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(msg.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Input field
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  
  /// Format time
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} giờ trước';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

/// Message model
class _Message {
  final String id;
  final String content;
  final int senderId;
  final DateTime createdAt;

  _Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });
}
