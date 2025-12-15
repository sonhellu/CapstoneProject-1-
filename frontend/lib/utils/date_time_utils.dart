import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Utility class for formatting dates and times with localization
class DateTimeUtils {
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static String _formatDateDMY(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  /// Format time ago (e.g., "5 minutes ago", "2 hours ago")
  /// Supports both short (m/h/d) and full formats
  static String formatTimeAgo(
    BuildContext context,
    DateTime dateTime, {
    bool shortFormat = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // 기기 시간/서버 시간 오차 등으로 미래 시간이 들어오면 음수 차이가 날 수 있음.
    // 이 경우에는 방어적으로 'just now' 처리.
    if (difference.isNegative) {
      return shortFormat ? '0${l10n.minutesShort}' : l10n.justNow;
    }

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      if (shortFormat) {
        return '${difference.inMinutes}${l10n.minutesShort}';
      }
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      if (shortFormat) {
        return '${difference.inHours}${l10n.hoursShort}';
      }
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      if (shortFormat) {
        return '${difference.inDays}${l10n.daysShort}';
      }
      return l10n.daysAgo(difference.inDays);
    } else {
      // Format as date: dd/mm/yyyy
      return _formatDateDMY(dateTime);
    }
  }

  /// Format date with "Today", "Yesterday", or date
  static String formatDate(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // difference는 '날짜'가 아니라 '시각' 기준이라 6.x days 처럼 애매할 수 있음.
    // UI 목적상은 day 단위면 충분해서 date 기준 비교를 우선.
    final difference = now.difference(dateTime);

    if (date == today) {
      return l10n.today;
    } else if (date == yesterday) {
      return l10n.yesterday;
    } else if (!difference.isNegative && difference.inDays < 7) {
      return l10n.daysAgoShort(difference.inDays);
    } else {
      // Format as date: dd/mm/yyyy
      return _formatDateDMY(dateTime);
    }
  }

  /// Format time for chat messages (short format: m, h, d)
  static String formatChatTime(BuildContext context, DateTime dateTime) {
    return formatTimeAgo(context, dateTime, shortFormat: true);
  }

  /// Format date and time
  static String formatDateTime(BuildContext context, DateTime dateTime) {
    final dateStr = formatDate(context, dateTime);
    final timeStr = '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
    return '$dateStr $timeStr';
  }
}
