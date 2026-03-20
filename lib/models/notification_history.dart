/*
 * File: notification_history.dart
 * Feature : Core Feature
 * Description: Data model for storing and formatting notification history.
 *
 * Responsibilities:
 * - Store notification event data and metadata
 * - Format timestamps for display
 * - Track exercise recommendations per notification
 * - Support notification history management
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

/// The [NotificationHistory] class represents a record of a past notification event.
///
/// Fields:
/// - mode: The mode of the timer when the notification was triggered
/// - emoji: The emoji associated with the mode
/// - message: The notification message content
/// - timestamp: The time when the notification was sent
/// - exercises: The recommended exercises included in the notification
///
/// Usage:
/// - Store notification event data and metadata
/// - Format timestamps for display in history screens
/// - Track exercise recommendations per notification
class NotificationHistory {
  final String mode;
  final String emoji;
  final String message;
  final DateTime timestamp;
  final List<String> exercises;

  /// Creates a [NotificationHistory] with the specified notification details.
  ///
  /// The [mode] represents the timer mode when the notification was triggered,
  /// [emoji] is the visual indicator for the mode, [message] contains the notification
  /// content, [timestamp] records when the notification was sent, and [exercises]
  /// lists the recommended stretch activities included in the notification.
  NotificationHistory({
    required this.mode,
    required this.emoji,
    required this.message,
    required this.timestamp,
    required this.exercises,
  });

  /// Formats the timestamp into a human-readable relative string.
  ///
  /// Calculates the time difference between the notification timestamp and current time.
  /// Returns formatted strings like "Just now", "5m ago", "2h ago", or "3d ago" based on
  /// the elapsed duration. Uses minutes for periods under 1 hour, hours for under 24 hours,
  /// and days for longer periods.
  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
