// lib/models/language_chat_room.dart
import 'package:flutter/foundation.dart';

/// 언어 교류 채팅방(한 사람과의 대화 1줄)을 나타내는 모델
@immutable
class LanguageChatRoom {
  /// 방을 구분하는 ID
  /// 예: 'room_Alice_1733812345678'
  final String roomId;

  /// 상대 이름 (Chloe, Dan 등)
  final String partnerName;

  /// 대상 언어 라벨 (예: '영어', '한국어', '베트남어')
  final String targetLanguageLabel;

  /// 마지막으로 메시지가 온/간 시간
  final DateTime updatedAt;

  /// 리스트에 보여줄 마지막 메시지 내용
  final String lastMessage;

  /// 안 읽은 메시지 개수 (프론트에서만 사용, 지금은 0으로 둬도 됨)
  final int unreadCount;

  const LanguageChatRoom({
    required this.roomId,
    required this.partnerName,
    required this.targetLanguageLabel,
    required this.updatedAt,
    required this.lastMessage,
    this.unreadCount = 0,
  }) : assert(unreadCount >= 0);

  /// JSON(Map) -> Model
  /// (나중에 백엔드/로컬DB 연결 시 편하게 쓰기 위한 헬퍼)
  factory LanguageChatRoom.fromJson(Map<String, dynamic> json) {
    final updatedAtRaw = json['updatedAt'];
    DateTime parsedUpdatedAt;

    if (updatedAtRaw is DateTime) {
      parsedUpdatedAt = updatedAtRaw;
    } else if (updatedAtRaw is String && updatedAtRaw.isNotEmpty) {
      parsedUpdatedAt = DateTime.tryParse(updatedAtRaw) ?? DateTime.now();
    } else {
      parsedUpdatedAt = DateTime.now();
    }

    return LanguageChatRoom(
      roomId: (json['roomId'] as String?) ?? '',
      partnerName: (json['partnerName'] as String?) ?? 'Unknown',
      targetLanguageLabel: (json['targetLanguageLabel'] as String?) ?? '',
      updatedAt: parsedUpdatedAt,
      lastMessage: (json['lastMessage'] as String?) ?? '',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Model -> JSON(Map)
  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'partnerName': partnerName,
        'targetLanguageLabel': targetLanguageLabel,
        'updatedAt': updatedAt.toIso8601String(),
        'lastMessage': lastMessage,
        'unreadCount': unreadCount,
      };

  LanguageChatRoom copyWith({
    String? roomId,
    String? partnerName,
    String? targetLanguageLabel,
    DateTime? updatedAt,
    String? lastMessage,
    int? unreadCount,
  }) {
    return LanguageChatRoom(
      roomId: roomId ?? this.roomId,
      partnerName: partnerName ?? this.partnerName,
      targetLanguageLabel: targetLanguageLabel ?? this.targetLanguageLabel,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  String toString() {
    return 'LanguageChatRoom(roomId: $roomId, partner: $partnerName, lastMessage: $lastMessage, updatedAt: $updatedAt, unread: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageChatRoom && other.roomId == roomId;
  }

  @override
  int get hashCode => roomId.hashCode;
}
