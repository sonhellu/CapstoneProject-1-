import 'package:flutter/material.dart';

/// 언어교류용 1:1 채팅방 (서버 연동 없이 로컬 상태만 사용)
class LanguageChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String partnerName;
  final String targetLanguageLabel;

  const LanguageChatRoomScreen({
    super.key,
    required this.roomId,
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

    _controller.clear();
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final alignment =
                    msg.isMine ? Alignment.centerRight : Alignment.centerLeft;
                final bubbleColor = msg.isMine
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.15)
                    : Colors.grey.shade200;

                return Align(
                  alignment: alignment,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: msg.isMine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(msg.text),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(msg.time),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
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
