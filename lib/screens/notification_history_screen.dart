/*
 * File: notification_history_screen.dart
 * Feature : Individual Feature
 * Description: Displays a history of notifications sent to the user.
 *
 * Responsibilities:
 * - Display chronological list of past notifications
 * - Navigate to recommended exercises from history
 * - Manage notification history clearing
 * - Format notification timestamps and content
 *
 * Dependencies:
 * - NotificationHistoryService
 * - StretchModeService
 * - StretchModeExercise
 * - NotificationHistory
 * - AppColors
 * - AnalysisScreen
 *
 * Author: <Chaiwet Ketmuangmul / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import '../services/notification_history_service.dart';
import '../services/stretch_mode_service.dart';
import '../models/stretch_mode_data.dart';
import '../models/notification_history.dart';
import '../utils/colors.dart';
import 'analysis_screen.dart';

/// The [NotificationHistoryScreen] class represents a screen that displays the history of completed stretches and notifications.
///
/// Usage:
/// - Display chronological list of past notifications
/// - Navigate to recommended exercises from history
/// - Manage notification history clearing
/// - Format notification timestamps and content
class NotificationHistoryScreen extends StatefulWidget {
  /// Creates a [NotificationHistoryScreen] with default configuration.
  ///
  /// This constructor initializes the screen with standard settings for displaying
  /// notification history, managing history clearing operations, and handling
  /// navigation to recommended exercises.
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final NotificationHistoryService _historyService = NotificationHistoryService();
  final StretchModeService _stretchModeService = StretchModeService();

  Color _getColorForMode(String mode) {
    if (mode.contains('Work')) {
      return Color(0xFFC8E6C9); // Light green.
    } else if (mode.contains('Study')) {
      return Color(0xFFE1BEE7); // Light purple.
    } else if (mode.contains('Meeting')) {
      return Color(0xFF424242); // Dark gray.
    }
    return AppColors.green; // Default color.
  }

  Color _getChipColorForMode(String mode) {
    if (mode.contains('Work')) {
      return Color(0xFF66BB6A); // Green.
    } else if (mode.contains('Study')) {
      return Color(0xFFAB47BC); // Purple.
    } else if (mode.contains('Meeting')) {
      return Color(0xFF757575); // Gray.
    }
    return AppColors.green; 
  }

  // Navigates to the exercises recommended in the given notification.
  void _navigateToExercises(NotificationHistory notification) async {
    // Normalizes the mode name.
    final normalizedMode = notification.mode.replaceAll(' Mode', '').trim();
    
    // Loads the stretching modes data.
    await _stretchModeService.loadStretchModes();
    
    // Retrieves exercises matching the saved names.
    final allExercises = _stretchModeService.getAllExercisesByMode(normalizedMode);
    final recommendedExercises = <StretchModeExercise>[];
    
    for (final exerciseName in notification.exercises) {
      try {
        final exercise = allExercises.firstWhere(
          (e) => e.title == exerciseName,
        );
        if (exercise.videoPath != null && exercise.videoPath!.isNotEmpty) {
          recommendedExercises.add(exercise);
        }
      } catch (e) {
        // Skips if the exercise is not found.
        continue;
      }
    }
    
    if (recommendedExercises.isEmpty) {
      // Navigates to the regular analysis screen if no exercises are found.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(),
        ),
      );
    } else {
      // Navigates to the analysis screen with recommended exercises.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(
            recommendedExercises: recommendedExercises,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = _historyService.history;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Clear History?'),
                    content: Text('Are you sure you want to clear all notification history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _historyService.clearHistory();
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Clear All',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your notification history will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final notification = history[index];
                return GestureDetector(
                  onTap: () => _navigateToExercises(notification),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              notification.emoji,
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.mode,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    notification.getFormattedTime(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (notification.exercises.isNotEmpty) ...[
                          SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: notification.exercises.map((exercise) {
                                    final chipColor = _getChipColorForMode(notification.mode);
                                    return Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: chipColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        exercise,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: chipColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getChipColorForMode(notification.mode),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Start',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
