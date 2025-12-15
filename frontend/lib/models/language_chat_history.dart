// lib/models/language_chat_history.dart
import 'language_chat_room.dart';

/// 채팅방 히스토리를 메모리에서 관리하는 클래스
/// (앱 종료 시 초기화됨)
class LanguageChatHistory {
  static final List<LanguageChatRoom> _rooms = [];

  /// 채팅방 목록 반환 (최신 메시지 기준 정렬)
  static List<LanguageChatRoom> getRooms() {
    final sortedRooms = List<LanguageChatRoom>.from(_rooms)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedRooms;
  }

  /// 마지막 메시지 / 시간 / 안 읽은 개수 갱신
  static void updateLastMessage(
    String roomId,
    String lastMessage,
    DateTime updatedAt, {
    bool increaseUnread = false,
  }) {
    final index = _rooms.indexWhere((r) => r.roomId == roomId);

    /// unreadCount 계산용 헬퍼
    /// increaseUnread가 false면 기존 값 유지
    int nextUnread(LanguageChatRoom oldRoom) {
      if (!increaseUnread) return oldRoom.unreadCount;
      // 혹시라도 음수로 내려가는 걸 방지
      return (oldRoom.unreadCount + 1).clamp(0, 1 << 30).toInt();
    }

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

    final oldRoom = _rooms[index];
    _rooms[index] = oldRoom.copyWith(
      lastMessage: lastMessage,
      updatedAt: updatedAt,
      unreadCount: nextUnread(oldRoom),
    );
  }

  /// 특정 방 제거
  static void removeRoom(String roomId) {
    _rooms.removeWhere((r) => r.roomId == roomId);
  }

  /// 전체 초기화 (디버깅용)
  static void clear() {
    _rooms.clear();
  }
}
