// lib/models/language_chat_history.dart
import 'language_chat_room.dart';

/// 앱이 켜져 있는 동안만 유지되는
/// 간단한 인메모리(in-memory) 히스토리 매니저
///
/// 나중에 백엔드 / 로컬 DB 연결하면 이 부분만 갈아끼우면 됨.
class LanguageChatHistory {
  static final List<LanguageChatRoom> _rooms = [];

  /// 최신순으로 정렬된 리스트 반환
  static List<LanguageChatRoom> getRooms() {
    final copy = List<LanguageChatRoom>.from(_rooms);
    copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy;
  }

  /// 방을 새로 추가하거나, 이미 있으면 정보 업데이트
  static void addOrUpdateRoom(LanguageChatRoom room) {
    final index = _rooms.indexWhere((r) => r.roomId == room.roomId);
    if (index == -1) {
      _rooms.add(room);
    } else {
      _rooms[index] = room;
    }
  }

  /// 마지막 메시지 / 시간 / 안 읽은 개수 갱신
  static void updateLastMessage(
    String roomId,
    String lastMessage,
    DateTime updatedAt, {
    bool increaseUnread = false,
  }) {
    final index = _rooms.indexWhere((r) => r.roomId == roomId);
    if (index == -1) {
      // 아직 목록에 없는 방이면 일단 기본 정보로 추가
      _rooms.add(
        LanguageChatRoom(
          roomId: roomId,
          partnerName: 'Unknown',
          targetLanguageLabel: '',
          updatedAt: updatedAt,
          lastMessage: lastMessage,
          unreadCount: increaseUnread ? 1 : 0,
        ),
      );
      return;
    }

    final old = _rooms[index];
    _rooms[index] = old.copyWith(
      lastMessage: lastMessage,
      updatedAt: updatedAt,
      unreadCount:
          increaseUnread ? old.unreadCount + 1 : old.unreadCount,
    );
  }

  /// 방 하나 제거하고 싶을 때 (필요하면 사용)
  static void removeRoom(String roomId) {
    _rooms.removeWhere((r) => r.roomId == roomId);
  }

  /// 전체 초기화 (디버깅용)
  static void clear() {
    _rooms.clear();
  }
}
