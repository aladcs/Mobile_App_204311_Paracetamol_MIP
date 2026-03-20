/*
 * File: timer_completion_dialog.dart
 * Feature : Core Feature
 * Description: Modal bottom sheet widget displayed when timer completes.
 *
 * Responsibilities:
 * - Display timer completion notification as modal bottom sheet
 * - Show recommended stretch exercises with visual indicators
 * - Provide navigation to Analysis screen with pre-selected exercises
 * - Handle user interactions (OK button, Go to Analysis button)
 *
 * Dependencies:
 * - StretchModeExercise
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/stretch_mode_data.dart';

/// The [TimerCompletionDialog] class represents a modal bottom sheet displayed when timer completes.
///
/// Fields:
/// - mode: The mode that was used (e.g., "Study Mode", "Work Mode")
/// - emoji: The emoji associated with the mode
/// - message: The main notification message
/// - exercises: The list of recommended stretch exercises
/// - dialogColor: The background color of the dialog
/// - isSilent: Silent mode flag (Meeting Mode)
/// - onClose: Callback when dialog is closed
/// - recommendedExercises: Full exercise objects for Analysis navigation
/// - onGoToAnalysis: Callback when "Go to Analysis" button is pressed
///
/// Usage:
/// - Display timer completion notification as modal bottom sheet
/// - Show recommended stretch exercises with visual indicators
/// - Provide navigation to Analysis screen with pre-selected exercises
/// - Handle user interactions (OK button, Go to Analysis button)
class TimerCompletionDialog extends StatelessWidget {
  final String mode;
  final String emoji;
  final String message;
  final List<String> exercises;
  final Color dialogColor;
  final bool isSilent;
  final VoidCallback? onClose;
  final List<StretchModeExercise>? recommendedExercises;
  final void Function(List<StretchModeExercise>)? onGoToAnalysis;
  /// Creates a [TimerCompletionDialog] with the specified completion information.
  ///
  /// The [mode] indicates the timer mode that completed, [emoji] provides the
  /// visual indicator, [message] contains the notification text, [exercises]
  /// lists recommended stretches, [dialogColor] sets the background color,
  /// [isSilent] determines styling for silent modes, [onClose] handles dialog
  /// dismissal, [recommendedExercises] provides full exercise objects, and
  /// [onGoToAnalysis] handles navigation to the analysis screen.
  const TimerCompletionDialog({
    Key? key,
    required this.mode,
    required this.emoji,
    required this.message,
    required this.exercises,
    required this.dialogColor,
    required this.isSilent,
    this.onClose,
    this.recommendedExercises,
    this.onGoToAnalysis,
  }) : super(key: key);

  /// Displays the timer completion dialog as a modal bottom sheet.
  ///
  /// Side effects:
  /// - Triggers haptic feedback for user awareness
  /// - Shows modal bottom sheet overlay on current screen
  /// - Blocks user interaction with background content until dismissed
  static void show(
    BuildContext context, {
    required String mode,
    required String emoji,
    required String message,
    required List<String> exercises,
    required Color dialogColor,
    required bool isSilent,
    VoidCallback? onClose,
    List<StretchModeExercise>? recommendedExercises,
    void Function(List<StretchModeExercise>)? onGoToAnalysis,
  }) {
    // Trigger device vibration
    HapticFeedback.heavyImpact();

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) => TimerCompletionDialog(
        mode: mode,
        emoji: emoji,
        message: message,
        exercises: exercises,
        dialogColor: dialogColor,
        isSilent: isSilent,
        onClose: onClose,
        recommendedExercises: recommendedExercises,
        onGoToAnalysis: onGoToAnalysis,
      ),
    );
  }

  /// Builds the widget tree for the timer completion dialog.
  ///
  /// Creates a container with rounded corners containing header, message, exercise list,
  /// and action buttons. Applies mode-specific styling and handles both regular and silent
  /// mode appearances. Returns a complete modal bottom sheet layout with proper spacing
  /// and interactive elements.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: dialogColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with emoji and title
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Time to Move!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSilent ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isSilent ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 16),
          
          // Recommended exercises label
          Text(
            'Recommended:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSilent ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8),
          
          // Exercise list
          ...exercises.map((exercise) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: isSilent ? Colors.white70 : Colors.green,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exercise,
                        style: TextStyle(
                          color: isSilent ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 20),
          
          // Go to Analysis button 
          if (onGoToAnalysis != null &&
              recommendedExercises != null &&
              recommendedExercises!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onGoToAnalysis!(recommendedExercises!);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isSilent ? Colors.white : Colors.black,
                    side: BorderSide(
                      color: isSilent ? Colors.white70 : Colors.black54,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Go to Analysis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          
          // OK button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (onClose != null) onClose!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSilent ? Colors.white : Colors.black,
                foregroundColor: isSilent ? Colors.black : Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
