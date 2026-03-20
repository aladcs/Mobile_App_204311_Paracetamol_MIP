/*
 * File: interactive_stretch_card.dart
 * Feature : Individual Feature
 * Description: Interactive card widget displaying a stretch guide and a timer.
 *
 * Responsibilities:
 * - Display stretch instructions with video content
 * - Provide interactive countdown timer for exercises
 * - Handle timer start, stop, and duration parsing
 * - Show stretch details and action buttons
 *
 * Dependencies:
 * - AppColors
 * - VideoPlayerWidget
 *
 * Author: <Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'video_player_widget.dart';

/// The [InteractiveStretchCard] class represents a card displaying a specific stretch with instructions and an interactive timer.
///
/// Fields:
/// - stretch: The map containing stretch details (title, description, duration, etc.)
///
/// Usage:
/// - Display stretch instructions with video content
/// - Provide interactive countdown timer for exercises
/// - Handle timer start, stop, and duration parsing
/// - Show stretch details and action buttons
class InteractiveStretchCard extends StatefulWidget {
  final Map<String, String> stretch;

  /// Creates an [InteractiveStretchCard] with the specified stretch information.
  ///
  /// The [stretch] parameter contains the stretch details including title,
  /// description, duration, and optional video content required for proper
  /// display and timer functionality.
  const InteractiveStretchCard({
    Key? key,
    required this.stretch,
  }) : super(key: key);

  @override
  _InteractiveStretchCardState createState() => _InteractiveStretchCardState();
}

class _InteractiveStretchCardState extends State<InteractiveStretchCard> {
  // The active timer instance for the stretch countdown.
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  bool _isActive = false;

  // Starts the countdown timer for the specified duration.
  void _startTimer(int totalSeconds) {
    setState(() {
      _remainingSeconds = totalSeconds;
      _isActive = true;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isActive = false;
        });
      }
    });
  }

  // Stops and resets the active countdown timer.
  void _stopTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isActive = false;
      _remainingSeconds = 0;
    });
  }

  /// Disposes of timer resources when the widget is removed.
  ///
  /// Cancels any active countdown timer to prevent memory leaks and unwanted callbacks.
  /// Calls the parent dispose method to complete the cleanup process. Essential for
  /// proper resource management in stateful widgets.
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Parses an integer duration in seconds from the raw [durationText].
  int _parseDuration(String durationText) {
    if (durationText.contains("min")) {
      return 60;
    }
    final RegExp regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(durationText);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 15; // default fallback
  }

  String _formatDurationBadge(String text) {
    return text
        .replaceAll(' sec', 's')
        .replaceAll('sec', 's')
        .replaceAll('per side', '/ side')
        .replaceAll('per arm', '/ arm');
  }

  /// Builds the widget tree for the interactive stretch card.
  ///
  /// Creates a card layout with video player, stretch information, and interactive timer controls.
  /// Displays different states based on timer activity including start button and countdown display.
  /// Returns a complete card widget with proper styling, shadows, and user interaction handling.
  @override
  Widget build(BuildContext context) {
    final stretch = widget.stretch;
    final videoPath = stretch['videoPath'] ?? '';
    final videoUrl = stretch['videoUrl'] ?? '';
    final hasVideo = videoPath.isNotEmpty || videoUrl.isNotEmpty;
    final durationText = stretch['duration'] ?? '15 sec';

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Color(0xFF6EE7B7),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player or Placeholder with Badge
          Stack(
            children: [
              hasVideo
                  ? VideoPlayerWidget(
                      videoPath: videoPath.isNotEmpty ? videoPath : null,
                      videoUrl: videoUrl.isNotEmpty ? videoUrl : null,
                    )
                  : Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: Color(0xFF6EE7B7),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Color(0xFF4ADE80).withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_circle_filled,
                                size: 60,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Video not available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              // Duration Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⏱️', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text(
                        _formatDurationBadge(durationText),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Stretch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  stretch['title'] ?? '',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  stretch['description'] ?? '',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24),
                // Action Button Area
                _isActive
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.stop_circle_outlined, size: 36, color: Colors.redAccent),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: _stopTimer,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            int secs = _parseDuration(durationText);
                            _startTimer(secs);
                          },
                          icon: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                          label: Text(
                            'Start Timer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
