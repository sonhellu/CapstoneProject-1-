// lib/screens/home/language_order/chat_room_screen.dart
import 'package:flutter/material.dart';
import '../../../models/language_chat_room.dart';
import '../../../models/language_chat_history.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String partnerName;
  final String targetLanguageLabel;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.partnerName,
    required this.targetLanguageLabel,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    // 채팅방에 들어오는 순간, 히스토리 목록에 방을 등록 (또는 갱신)
    LanguageChatHistory.addOrUpdateRoom(
      LanguageChatRoom(
        roomId: widget.roomId,
        partnerName: widget.partnerName,
        targetLanguageLabel: widget.targetLanguageLabel,
        updatedAt: DateTime.now(),
        lastMessage: '',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isMine: true,
          time: now,
        ),
      );
    });

    // 히스토리의 "마지막 메시지" 업데이트
    LanguageChatHistory.updateLastMessage(
      widget.roomId,
      text,
      now,
    );

    _controller.clear();
  }

  String _formatTime(DateTime time) {
    // 24시간 기준 HH:mm
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.partnerName),
            Text(
              widget.targetLanguageLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final align =
                    msg.isMine ? Alignment.centerRight : Alignment.centerLeft;
                final bubbleColor = msg.isMine
                    ? theme.colorScheme.primary
                    : Colors.grey.shade200;
                final textColor =
                    msg.isMine ? Colors.white : Colors.black87;

                return Align(
                  alignment: align,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: msg.isMine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(msg.time),
                          style: TextStyle(
                            fontSize: 11,
                            color: textColor.withOpacity(0.8),
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
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
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
