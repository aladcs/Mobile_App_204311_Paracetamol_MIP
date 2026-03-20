/*
 * File: notification_history_service.dart
 * Feature : Core Feature
 * Description: Service for tracking user stretch notifications history.
 *
 * Responsibilities:
 * - Track and store notification history
 * - Manage history list size and memory usage
 * - Provide access to past notification events
 * - Handle history clearing operations
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import '../models/notification_history.dart';

/// The [NotificationHistoryService] class represents a service that tracks the history of displayed stretch notifications.
///
/// Usage:
/// - Track and store notification history
/// - Manage history list size and memory usage
/// - Provide access to past notification events
/// - Handle history clearing operations
class NotificationHistoryService {
  static final NotificationHistoryService _instance = NotificationHistoryService._internal();

  /// Creates a singleton [NotificationHistoryService] instance.
  ///
  /// This factory constructor implements the singleton pattern to ensure consistent
  /// history tracking throughout the application lifecycle, providing centralized
  /// access to notification history data and preventing data inconsistencies.
  factory NotificationHistoryService() => _instance;
  NotificationHistoryService._internal();
  final List<NotificationHistory> _history = [];
  /// The list of recorded notification events.
  List<NotificationHistory> get history => List.unmodifiable(_history);
  /// Adds a new notification record to the beginning of the history list.
  ///
  /// Side effects:
  /// - Inserts new NotificationHistory entry at the head of internal list
  /// - Automatically trims history to maximum 50 entries if exceeded
  /// - Removes oldest entries when history size limit is reached
  void addNotification({
    required String mode,
    required String emoji,
    required String message,
    required List<String> exercises,
  }) {
    _history.insert(0, NotificationHistory(
      mode: mode,
      emoji: emoji,
      message: message,
      timestamp: DateTime.now(),
      exercises: exercises,
    ));
    if (_history.length > 50) {
      _history.removeRange(50, _history.length);
    }
  }
  /// Clears all recorded notification history from memory.
  ///
  /// Side effects:
  /// - Removes all notification records from internal history list
  /// - Resets history to empty state
  void clearHistory() {
    _history.clear();
  }
}
