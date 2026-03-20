/*
 * File: session_screen.dart
 * Feature : Individual Feature
 * Description: Displays the active timer and controls for a running session.
 *
 * Responsibilities:
 * - Manage active timer session controls
 * - Handle timer start, pause, resume, and stop operations
 * - Display circular timer with remaining time
 * - Generate completion notifications with exercise recommendations
 *
 * Dependencies:
 * - CircularTimer
 * - BottomNavBar
 * - TimerBadge
 * - NotificationBell
 * - TimerCompletionDialog
 * - AppColors
 * - TimerService
 * - NotificationService
 * - StretchModeService
 * - AnalysisScreen
 * - StretchLibraryScreen
 * - HomeScreen
 *
 * Author: <Chaiwet Ketmuangmul / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/circular_timer.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/timer_badge.dart';
import '../widgets/notification_bell.dart';
import '../widgets/timer_completion_dialog.dart';
import '../utils/colors.dart';
import '../services/timer_service.dart';
import '../services/notification_service.dart';
import '../services/stretch_mode_service.dart';
import 'analysis_screen.dart';
import 'stretch_library_screen.dart';
import 'home_screen.dart';

/// The [SessionScreen] class represents a screen displaying the active timer and controls for a running session.
///
/// Fields:
/// - mode: The selected timer mode string
/// - emoji: The emoji representing the current mode
/// - defaultMinutes: The initial default duration for the timer
/// - dialogColor: The color of the completion dialog
/// - notificationMessage: The message displayed upon completion
/// - exercises: The default recommended exercises for the mode
/// - hasSound: Whether the notification should play a sound
/// - hasVibration: Whether the device should vibrate
/// - isSilent: Whether the session should complete silently
/// - timerService: The global timer service instance
///
/// Usage:
/// - Manage active timer session controls
/// - Handle timer start, pause, resume, and stop operations
/// - Display circular timer with remaining time
/// - Generate completion notifications with exercise recommendations
class SessionScreen extends StatefulWidget {
  final String mode;
  final String emoji;
  final int defaultMinutes;
  final Color dialogColor;
  final String notificationMessage;
  final List<String> exercises;
  final bool hasSound;
  final bool hasVibration;
  final bool isSilent;
  final TimerService timerService;

  /// Creates a [SessionScreen] with the specified timer configuration.
  ///
  /// The [mode] specifies the timer mode name, [emoji] provides the visual
  /// indicator, [defaultMinutes] sets the initial duration, [dialogColor]
  /// determines completion dialog styling, [notificationMessage] contains
  /// the completion text, [exercises] lists default recommended activities,
  /// [hasSound] controls audio notifications, [hasVibration] enables haptic
  /// feedback, [isSilent] configures silent mode behavior, and [timerService]
  /// provides access to the global timer management system.
  const SessionScreen({
    required this.mode,
    required this.emoji,
    this.defaultMinutes = 30,
    this.dialogColor = const Color(0xFFC8E6C9),
    this.notificationMessage = 'เวลายืดเหยียดแล้ว!',
    this.exercises = const ['Stretch'],
    this.hasSound = true,
    this.hasVibration = false,
    this.isSilent = false,
    required this.timerService,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  // The currently selected duration in minutes.
  late int _selectedMinutes;
  bool _isCurrentMode = false;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.defaultMinutes;

    _notificationService.initialize();
    if (widget.timerService.isRunning &&
        widget.timerService.currentMode == widget.mode) {
      _isCurrentMode = true;
    }
    widget.timerService.addListener(_onTimerUpdate);
  }

  @override
  void dispose() {
    // ไม่ต้องเรียก clearContext อีกต่อไป
    widget.timerService.removeListener(_onTimerUpdate);
    super.dispose();
  }
  void _onTimerUpdate() {
    if (mounted) {
      _isCurrentMode = widget.timerService.isRunning &&
          widget.timerService.currentMode == widget.mode;
      setState(() {});
    }
  }

  void _startTimer() {
    if (widget.timerService.isRunning &&
        widget.timerService.currentMode != widget.mode) {
      _showSwitchModeConfirm();
    } else {
      _performStartTimer();
    }
  }

  void _showSwitchModeConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Switch Mode?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to switch to ${widget.mode}? Your current session will end.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performStartTimer();
            },
            child: Text(
              'Switch',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Initiates the global timer with the configured options.
  void _performStartTimer() {
    widget.timerService.stopTimer();
    int seconds = _selectedMinutes == 0 ? 5 : _selectedMinutes * 60;
    widget.timerService.startTimer(
      seconds: seconds,
      mode: widget.mode,
      emoji: widget.emoji,
      exercises: widget.exercises,
      dialogColor: widget.dialogColor,
      isSilent: widget.isSilent,
      onComplete: null, // ไม่ต้องส่ง callback เพราะ main.dart จะจัดการให้
    );
    setState(() {});
  }

  void _adjustTime(int minutes) {
    setState(() {
      _selectedMinutes = minutes;
    });
  }

  void _showChangeTimeConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Confirm Change',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to change the timer to $_selectedMinutes minutes?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performChangeTime();
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performChangeTime() {
    widget.timerService.stopTimer();

    int seconds = _selectedMinutes == 0 ? 5 : _selectedMinutes * 60;

    widget.timerService.startTimer(
      seconds: seconds,
      mode: widget.mode,
      emoji: widget.emoji,
      exercises: widget.exercises,
      dialogColor: widget.dialogColor,
      isSilent: widget.isSilent,
      onComplete: null, 
    );
    setState(() {});
  }

  void _togglePause() {
    if (widget.timerService.isPaused) {
      widget.timerService.resumeTimer();
    } else {
      widget.timerService.pauseTimer();
    }
    setState(() {});
  }

  void _endSession() {
    // Displays confirmation dialog before stopping.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'End Session?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to end this session?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              _performEndSessionManually(); 
            },
            child: Text(
              'End Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Triggers the completion flow intentionally before the timer runs out.
  void _performEndSessionManually() async {
    int elapsedSeconds =
        widget.timerService.totalSeconds - widget.timerService.remainingSeconds;
    int elapsedMinutes = (elapsedSeconds / 60).round();

    String timeMessage;
    if (widget.mode.contains('Study')) {
      timeMessage =
          'Take a break! You\'ve been studying for $elapsedMinutes minutes';
    } else if (widget.mode.contains('Work')) {
      timeMessage =
          'Time to stretch! You\'ve been working for $elapsedMinutes minutes';
    } else if (widget.mode.contains('Meeting')) {
      timeMessage =
          'Time to move! You\'ve been in meetings for $elapsedMinutes minutes';
    } else {
      timeMessage =
          'Time to move! You\'ve been active for $elapsedMinutes minutes';
    }

    final normalizedMode = widget.mode.replaceAll(' Mode', '').trim();
    final modeService = StretchModeService();
    await modeService.loadStretchModes();
    final recommendedExerciseObjects = modeService.getRandomExerciseObjects(
      normalizedMode,
      count: 2,
    );
    List<String> exercises =
        recommendedExerciseObjects.map((e) => e.title).toList();
    if (exercises.isEmpty) {
      exercises = widget.exercises;
    }
    widget.timerService.stopTimer();
    // Displays notification.
    _notificationService.showNotification(
      title: widget.mode,
      body: '$timeMessage\nRecommended: ${exercises.join(", ")}',
      emoji: widget.emoji,
      exercises: exercises,
      isSilent: widget.isSilent,
    );
    if (mounted) {
      TimerCompletionDialog.show(
        context,
        mode: widget.mode,
        emoji: widget.emoji,
        message: timeMessage,
        exercises: exercises,
        dialogColor: widget.dialogColor,
        isSilent: widget.isSilent,
        onClose: null,
        recommendedExercises: recommendedExerciseObjects.isEmpty
            ? null
            : recommendedExerciseObjects,
        onGoToAnalysis: recommendedExerciseObjects.isEmpty
            ? null
            : (recommended) {
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => AnalysisScreen(
                      recommendedExercises: recommended,
                    ),
                  ),
                );
              },
      );
    }
  }
  // Performs cleanup operations when ending a session.
  void _performEndSession() async {
    widget.timerService.stopTimer();
  }
  // Generates the list of available duration options suitable for the mode.
  List<Widget> _getTimeOptions() {
    List<int> options;
    if (widget.mode.contains('Study')) {
      options = [30, 45, 60, 90, 120];
    } else if (widget.mode.contains('Meeting')) {
      options = [15, 30, 45, 60];
    } else {
      options = [30, 45, 60, 90]; // Work 
    }
    return options.map((minutes) => _timeButton(minutes)).toList();
  }
  Widget _timeButton(int minutes) {
    bool isSelected = _selectedMinutes == minutes;
    String label = '${minutes}m';

    return GestureDetector(
      onTap: () => _adjustTime(minutes),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.green : Colors.black12,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(width: 48),
                  // Timer Badge 
                  Expanded(
                    child: Center(
                      child: TimerBadge(
                        timerService: widget.timerService,
                        currentMode: widget.mode,
                      ),
                    ),
                  ),
                  // Notification Button
                  NotificationBell(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Title
                      Text(
                        '${widget.mode}${widget.emoji}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40),
                      // Timer
                      CircularTimer(
                        remainingSeconds: _isCurrentMode
                            ? widget.timerService.remainingSeconds
                            : (_selectedMinutes == 0
                                ? 5
                                : _selectedMinutes * 60),
                        totalSeconds: _isCurrentMode
                            ? widget.timerService.totalSeconds
                            : (_selectedMinutes == 0
                                ? 5
                                : _selectedMinutes * 60),
                      ),
                      SizedBox(height: 30),
                      // Time Adjustment 
                      Text(
                        'Adjust Timer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: _getTimeOptions(),
                      ),
                      SizedBox(height: 20),
                      // Control Buttons
                      if (!_isCurrentMode) ...[
                        GestureDetector(
                          onTap: _startTimer,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                widget.timerService.isRunning
                                    ? 'Switch to ${widget.mode}'
                                    : 'Start Session',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Test Button 
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMinutes = 0;
                            });
                            _startTimer();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                'Test (5 seconds)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else
                        // Pause/Resume, Change Time, and End Buttons
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _togglePause,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                            color: Colors.black12, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          widget.timerService.isPaused
                                              ? 'Resume'
                                              : 'Pause',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _endSession,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'End Session',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            // Change Time Button
                            GestureDetector(
                              onTap: _showChangeTimeConfirm,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF7CB342), 
                                      Color(0xFF9CCC65), 
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF7CB342).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Change Time',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Navigates to home screen.
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomeScreen(timerService: widget.timerService),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0); 
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                      position: offsetAnimation, child: child);
                },
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AnalysisScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); 
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                      position: offsetAnimation, child: child);
                },
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    StretchLibraryScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); 
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                      position: offsetAnimation, child: child);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
