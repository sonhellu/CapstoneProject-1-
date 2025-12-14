import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Utility class for formatting dates and times with localization
class DateTimeUtils {
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
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Format date with "Today", "Yesterday", or date
  static String formatDate(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = now.difference(dateTime);

    if (date == today) {
      return l10n.today;
    } else if (date == yesterday) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgoShort(difference.inDays);
    } else {
      // Format as date: dd/mm/yyyy
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Format time for chat messages (short format: m, h, d)
  static String formatChatTime(BuildContext context, DateTime dateTime) {
    return formatTimeAgo(context, dateTime, shortFormat: true);
  }

  /// Format date and time
  static String formatDateTime(BuildContext context, DateTime dateTime) {
    final dateStr = formatDate(context, dateTime);
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr $timeStr';
  }
}

