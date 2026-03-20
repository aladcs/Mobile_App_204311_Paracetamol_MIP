/*
 * File: timer_service.dart
 * Feature : Core Feature
 * Description: Manages the core timer logic for different activity modes.
 *
 * Responsibilities:
 * - Control timer start, pause, resume, and stop operations
 * - Track timer state and remaining time
 * - Handle background/foreground timer synchronization
 * - Manage timer notifications and completion callbacks
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_service.dart';

/// The [TimerService] class represents a state manager that controls the overall application timer.
///
/// Fields:
/// - totalSeconds: The total duration of the current session in seconds
/// - remainingSeconds: The remaining duration of the current session in seconds
/// - isRunning: Whether the timer is currently running
/// - isPaused: Whether the timer is currently paused
/// - currentMode: The identifier for the current mode
/// - currentEmoji: The emoji representing the current mode
/// - exercises: The list of exercises assigned for the session
/// - dialogColor: The color used for mode dialogs
/// - isSilent: Whether the timer notifications should be silent
///
/// Usage:
/// - Control timer start, pause, resume, and stop operations
/// - Track timer state and remaining time across the app
/// - Handle background/foreground timer synchronization
/// - Manage timer notifications and completion callbacks
class TimerService extends ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  
  /// Creates a singleton [TimerService] instance.
  ///
  /// This factory constructor implements the singleton pattern to ensure only one
  /// timer service exists throughout the application lifecycle, providing consistent
  /// timer state management and preventing conflicts between multiple instances.
  factory TimerService() => _instance;
  
  TimerService._internal();

  Timer? _timer;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  String _currentMode = '';
  String _currentEmoji = '';
  List<String> _exercises = [];
  Color _dialogColor = const Color(0xFFC8E6C9);
  bool _isSilent = false;
  
  DateTime? _startTime;
  DateTime? _pauseTime;
  final NotificationService _notificationService = NotificationService();
  Function()? onTimerComplete;

  /// The total duration of the current session in seconds.
  int get totalSeconds => _totalSeconds;
  /// The remaining duration of the current session in seconds.
  int get remainingSeconds => _remainingSeconds;
  /// Whether the timer is currently running.
  bool get isRunning => _isRunning;
  /// Whether the timer is currently paused.
  bool get isPaused => _isPaused;
  /// The identifier for the current mode.
  String get currentMode => _currentMode;
  /// The emoji representing the current mode.
  String get currentEmoji => _currentEmoji;
  /// The list of exercises assigned for the session.
  List<String> get exercises => List.unmodifiable(_exercises);
  /// The color used for mode dialogs.
  Color get dialogColor => _dialogColor;
  /// Whether the timer notifications should be silent.
  bool get isSilent => _isSilent;
  /// Starts the timer with the specified parameters and configuration.
  ///
  /// Side effects:
  /// - Cancels any existing timer and resets internal state
  /// - Schedules system notifications for timer completion
  /// - Notifies all registered listeners of state changes
  /// - Begins countdown process with one-second intervals
  void startTimer({
    required int seconds,
    required String mode,
    required String emoji,
    List<String> exercises = const [],
    Color dialogColor = const Color(0xFFC8E6C9),
    bool isSilent = false,
    Function()? onComplete,
  }) {
    _totalSeconds = seconds;
    _remainingSeconds = seconds;
    _currentMode = mode;
    _currentEmoji = emoji;
    _exercises = List.from(exercises);
    _dialogColor = dialogColor;
    _isSilent = isSilent;
    _isRunning = true;
    _isPaused = false;
    _startTime = DateTime.now(); 
    _pauseTime = null;
    onTimerComplete = onComplete;

    _notificationService.scheduleTimerCompletion(
      duration: Duration(seconds: seconds),
      title: mode,
      body: 'Time to stretch! Your $mode session is complete.',
      emoji: emoji,
      exercises: exercises,
      isSilent: isSilent,
    );
    // Show initial timer notification
    _updateTimerNotification();

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused && _remainingSeconds > 0) {
        _remainingSeconds--;
        _updateTimerNotification();
        notifyListeners();
      } else if (_remainingSeconds == 0) {
        timer.cancel();
        _isRunning = false;
        _isPaused = false;
        _notificationService.cancelTimerNotification();
        // Cancels scheduled notification.
        _notificationService.cancelScheduledTimerCompletion();
        notifyListeners();
        onTimerComplete?.call();
      }
    });
    notifyListeners();
  }
  void _updateTimerNotification() {
    _notificationService.showTimerNotification(
      modeName: _currentMode,
      emoji: _currentEmoji,
      timeRemaining: getFormattedTime(),
    );
  }

  /// Pauses the currently running timer and saves the pause timestamp.
  ///
  /// Side effects:
  /// - Sets internal pause state to true
  /// - Records current timestamp for resume calculations
  /// - Cancels scheduled completion notifications
  /// - Cancels ongoing timer notification display
  /// - Notifies all registered listeners of pause state change
  void pauseTimer() {
    _isPaused = true;
    _pauseTime = DateTime.now(); // Saves pause time.
    
    // Cancels existing scheduled notification.
    _notificationService.cancelScheduledTimerCompletion();
    _notificationService.cancelTimerNotification();
    notifyListeners();
  }

  /// Resumes the paused timer and adjusts for elapsed pause duration.
  ///
  /// Side effects:
  /// - Sets internal pause state to false
  /// - Adjusts start time to compensate for pause duration
  /// - Reschedules completion notifications with remaining time
  /// - Updates timer notification display
  /// - Notifies all registered listeners of resume state change
  void resumeTimer() {
    _isPaused = false;
    if (_pauseTime != null && _startTime != null) {
      // Adjusts start time to compensate for paused duration.
      final pauseDuration = DateTime.now().difference(_pauseTime!);
      _startTime = _startTime!.add(pauseDuration);
      _pauseTime = null;
      
      _notificationService.scheduleTimerCompletion(
        duration: Duration(seconds: _remainingSeconds),
        title: _currentMode,
        body: 'Time to stretch! Your $_currentMode session is complete.',
        emoji: _currentEmoji,
        exercises: _exercises,
        isSilent: _isSilent,
      );
    }
    _updateTimerNotification();
    notifyListeners();
  }

  /// Stops the running timer and resets all session state to defaults.
  ///
  /// Side effects:
  /// - Cancels active timer and sets running state to false
  /// - Resets all timing variables to zero
  /// - Clears session data including mode, exercises, and colors
  /// - Cancels all scheduled and ongoing notifications
  /// - Notifies all registered listeners of complete state reset
  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = 0;
    _totalSeconds = 0;
    _currentMode = '';
    _currentEmoji = '';
    _exercises = [];
    _dialogColor = const Color(0xFFC8E6C9);
    _isSilent = false;
    _startTime = null;
    _pauseTime = null;
    _notificationService.cancelTimerNotification();
    // Cancels scheduled notification.
    _notificationService.cancelScheduledTimerCompletion();
    notifyListeners();
  }

  /// Recalculates timer status when the app returns from background.
  ///
  /// Side effects:
  /// - Updates remaining time based on actual elapsed time
  /// - May trigger timer completion if expired during background
  /// - Cancels notifications if timer completed
  /// - Updates timer notification display with current status
  /// - Notifies all registered listeners of updated state
  void resumeFromBackground() {
    if (!_isRunning || _isPaused || _startTime == null) return;
    final now = DateTime.now();
    final elapsed = now.difference(_startTime!).inSeconds;
    final newRemaining = _totalSeconds - elapsed;

    if (newRemaining <= 0) {
      _remainingSeconds = 0;
      _timer?.cancel();
      _isRunning = false;
      _isPaused = false;
      _notificationService.cancelTimerNotification();
      _notificationService.cancelScheduledTimerCompletion();
      notifyListeners();
      onTimerComplete?.call();
    } else {
      _remainingSeconds = newRemaining;
      _updateTimerNotification();
      notifyListeners();
    }
  }
  /// Returns the formatted time string representing minutes and seconds.
  ///
  /// Converts the remaining seconds into a human-readable MM:SS format with zero padding.
  /// Provides consistent time display formatting throughout the application. Always returns
  /// a string in the format "00:00" even when the timer is stopped or not initialized.
  String getFormattedTime() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Disposes of timer resources and cancels all notifications.
  ///
  /// Cleans up the timer instance by canceling active timers and removing scheduled
  /// notifications. Calls the parent dispose method to complete the cleanup process.
  /// Should be called when the timer service is no longer needed.
  @override
  void dispose() {
    _timer?.cancel();
    _notificationService.cancelTimerNotification();
    _notificationService.cancelScheduledTimerCompletion();
    super.dispose();
  }
}
