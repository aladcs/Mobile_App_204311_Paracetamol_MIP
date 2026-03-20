/*
 * File: notification_bell.dart
 * Feature : Core Feature
 * Description: A notification bell widget displaying the unread history badge.
 *
 * Responsibilities:
 * - Display notification count badge
 * - Navigate to notification history screen
 * - Update badge count dynamically
 * - Handle notification history state changes
 *
 * Dependencies:
 * - NotificationHistoryService
 * - NotificationHistoryScreen
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import '../services/notification_history_service.dart';
import '../screens/notification_history_screen.dart';

/// The [NotificationBell] class represents an action button that indicates unread notifications and navigates to history.
///
/// Fields:
/// - None (uses internal state management)
///
/// Usage:
/// - Display notification count badge
/// - Navigate to notification history screen
/// - Update badge count dynamically
/// - Handle notification history state changes
class NotificationBell extends StatefulWidget {
  /// Creates a [NotificationBell] widget with default configuration.
  ///
  /// This constructor initializes the notification bell with standard settings
  /// for displaying notification count badges and handling navigation to the
  /// notification history screen.
  const NotificationBell({Key? key}) : super(key: key);

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  // The local reference to the global notification history service.
  final NotificationHistoryService _historyService = NotificationHistoryService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationHistoryScreen(),
              ),
            ).then((_) {
              // Refreshes the unread badge upon returning from history screen.
              if (mounted) {
                setState(() {});
              }
            });
          },
        ),
        if (_historyService.history.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  '${_historyService.history.length > 9 ? '9+' : _historyService.history.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
