/*
 * File: timer_badge.dart
 * Feature : Core Feature
 * Description: A floating badge showing the currently active session timer.
 *
 * Responsibilities:
 * - Display active timer status and remaining time
 * - Provide quick navigation to active session
 * - Handle timer pause/resume controls
 * - Show/hide based on timer state and current screen
 *
 * Dependencies:
 * - TimerService
 * - AppColors
 * - SessionScreen
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import '../services/timer_service.dart';
import '../utils/colors.dart';
import '../screens/session_screen.dart';

/// The [TimerBadge] class represents a persistent badge widget that displays the status of an ongoing timer.
///
/// Fields:
/// - timerService: The active timer tracking service
/// - currentMode: The current operational mode context
///
/// Usage:
/// - Display active timer status and remaining time
/// - Provide quick navigation to active session
/// - Handle timer pause/resume controls
/// - Show/hide based on timer state and current screen
class TimerBadge extends StatelessWidget {
  final TimerService timerService;
  final String? currentMode;

  /// Creates a [TimerBadge] with the specified timer service and mode context.
  ///
  /// The [timerService] provides access to the active timer state and controls,
  /// while [currentMode] optionally specifies the current operational mode
  /// context to determine badge visibility and behavior.
  const TimerBadge({
    required this.timerService,
    this.currentMode,
  });

  // Helper method to retrieve configuration settings for a given [mode].
  Map<String, dynamic> _getModeConfig(String mode) {
    switch (mode) {
      case 'Study Mode':
        return {
          'emoji': '📚',
          'defaultMinutes': 90,
          'dialogColor': Color(0xFFE1BEE7),
          'notificationMessage': 'พักสายตาหน่อย! อ่านหนังสือมา 90 นาทีแล้ว',
          'exercises': ['Eye Rest', 'Neck Stretch'],
          'hasSound': true,
          'hasVibration': true,
          'isSilent': false,
        };
      case 'Work Mode':
        return {
          'emoji': '💼',
          'defaultMinutes': 60,
          'dialogColor': Color(0xFFC8E6C9),
          'notificationMessage': 'เวลาบริหาร! ทำงานมา 60 นาทีแล้ว',
          'exercises': ['Shoulder Relief', 'Wrist Rotation'],
          'hasSound': true,
          'hasVibration': true,
          'isSilent': false,
        };
      case 'Meeting Mode':
        return {
          'emoji': '💻',
          'defaultMinutes': 60,
          'dialogColor': Color(0xFF424242),
          'notificationMessage': 'Quick stretch reminder (Silent)',
          'exercises': ['Shoulder Blade Squeeze', 'Hand Stretch', 'Ankle Rotations'],
          'hasSound': false,
          'hasVibration': true,
          'isSilent': true,
        };
      default:
        return {
          'emoji': '⏱️',
          'defaultMinutes': 30,
          'dialogColor': AppColors.green,
          'notificationMessage': 'เวลายืดเหยียดแล้ว!',
          'exercises': ['Stretch'],
          'hasSound': true,
          'hasVibration': true,
          'isSilent': false,
        };
    }
  }

  // Determines the background color based on the selected [mode].
  Color _getBadgeColor(String mode) {
    switch (mode) {
      case 'Study Mode':
        return Color(0xFFCE93D8); 
      case 'Work Mode':
        return Color(0xFF81C784); 
      case 'Meeting Mode':
        return Color(0xFF90A4AE); 
      default:
        return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: timerService,
      builder: (context, child) {
        // Hides the badge
        if (!timerService.isRunning || 
            (currentMode != null && currentMode == timerService.currentMode)) {
          return SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            // Navigates to the SessionScreen of the currently running mode.
            final config = _getModeConfig(timerService.currentMode);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SessionScreen(
                  mode: timerService.currentMode,
                  emoji: config['emoji'],
                  defaultMinutes: config['defaultMinutes'],
                  dialogColor: config['dialogColor'],
                  notificationMessage: config['notificationMessage'],
                  exercises: config['exercises'],
                  hasSound: config['hasSound'],
                  hasVibration: config['hasVibration'],
                  isSilent: config['isSilent'],
                  timerService: timerService,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getBadgeColor(timerService.currentMode),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timerService.currentEmoji,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    timerService.currentMode,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    timerService.getFormattedTime(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    // Toggles pause and resume states.
                    if (timerService.isPaused) {
                      timerService.resumeTimer();
                    } else {
                      timerService.pauseTimer();
                    }
                  },
                  child: Icon(
                    timerService.isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
