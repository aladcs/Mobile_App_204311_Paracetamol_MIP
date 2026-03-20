/*
 * File: circular_timer.dart
 * Feature : Core Feature
 * Description: A circular progress timer widget used in active sessions.
 *
 * Responsibilities:
 * - Display circular countdown timer with progress visualization
 * - Format and show remaining time
 * - Animate progress arc based on timer state
 * - Provide visual feedback for session duration
 *
 * Dependencies:
 * - AppColors
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/colors.dart';

/// The [CircularTimer] class represents a widget displaying a circular countdown timer with animated progress.
///
/// Fields:
/// - remainingSeconds: The number of seconds left in the timer
/// - totalSeconds: The total initial duration of the timer
///
/// Usage:
/// - Display circular countdown timer with progress visualization
/// - Format and show remaining time
/// - Animate progress arc based on timer state
/// - Provide visual feedback for session duration
class CircularTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  /// Creates a [CircularTimer] with the specified timer tracking properties.
  ///
  /// The [remainingSeconds] indicates the current countdown value, while
  /// [totalSeconds] represents the initial timer duration used for calculating
  /// progress percentage and visual arc completion.
  const CircularTimer({
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (remainingSeconds / totalSeconds);

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(280, 280),
            painter: _CircularProgressPainter(progress: progress),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(remainingSeconds),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Until next stretch',
                style: TextStyle(fontSize: 16, color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Formats the given [seconds] into a MM:SS string representation.
  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

// A custom painter that draws the circular progress track and arc.
class _CircularProgressPainter extends CustomPainter {
  final double progress;

  _CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    // Background
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progress
    final progressPaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}