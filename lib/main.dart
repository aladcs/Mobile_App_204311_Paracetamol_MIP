/*
 * File: main.dart
 * Feature : Core Feature
 * Description: The entry point of the Move in Peace application.
 *
 * Responsibilities:
 * - Initialize app services and dependencies
 * - Configure global app settings and theme
 * - Handle app lifecycle state changes
 * - Manage timer completion notifications and navigation
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/analysis_screen.dart';
import 'services/timer_service.dart';
import 'services/notification_service.dart';
import 'services/stretch_mode_service.dart';
import 'widgets/timer_completion_dialog.dart';

/// Initializes the application and starts the Flutter framework.
///
/// This function performs app initialization and service setup operations which may take time to complete.
/// Throws an exception if critical services fail to initialize or Flutter binding setup fails.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await StretchModeService().loadStretchModes();
  runApp(MoveInPeaceApp());
}

/// The [MoveInPeaceApp] class represents the root widget of the Move in Peace application.
///
/// Fields:
/// - timerService: The global service managing the application timer
///
/// Usage:
/// - Initialize app services and dependencies
/// - Configure global app settings and theme
/// - Handle app lifecycle state changes
/// - Manage timer completion notifications and navigation
class MoveInPeaceApp extends StatefulWidget {
  /// The global service managing the application timer.
  final TimerService timerService = TimerService();

  /// Creates a [MoveInPeaceApp] with optional configuration.
  ///
  /// This constructor initializes the root application widget with default settings
  /// for theme configuration, navigation setup, and timer service integration.
  MoveInPeaceApp({super.key});

  @override
  State<MoveInPeaceApp> createState() => _MoveInPeaceAppState();
}

class _MoveInPeaceAppState extends State<MoveInPeaceApp> with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _completionNotified = false;

  @override
  void initState() {
    super.initState();
    widget.timerService.addListener(_onTimerUpdate);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    widget.timerService.removeListener(_onTimerUpdate);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // Resumes timer when the app returns to the foreground.
      widget.timerService.resumeFromBackground();
    }
  }

  void _onTimerUpdate() {
    final ts = widget.timerService;
    if (ts.isRunning) {
      _completionNotified = false;
      return;
    }
    // Automatically shows a notification when the timer naturally reaches zero.
    if (ts.remainingSeconds == 0 && ts.totalSeconds > 0 && !_completionNotified) {
      _completionNotified = true;
      _showTimerCompletionNotification();
    }
  }

  String _timeMessageForMode(String mode, int elapsedMinutes) {
    if (mode.contains('Study')) {
      return 'Take a break! You\'ve been studying for $elapsedMinutes minutes';
    }
    if (mode.contains('Work')) {
      return 'Time to stretch! You\'ve been working for $elapsedMinutes minutes';
    }
    if (mode.contains('Meeting')) {
      return 'Time to move! You\'ve been in meetings for $elapsedMinutes minutes';
    }
    return 'Time to move! You\'ve been active for $elapsedMinutes minutes';
  }

  String _normalizeMode(String mode) {
    return mode.replaceAll(' Mode', '').trim();
  }
  void _showTimerCompletionNotification() {
    final ts = widget.timerService;
    final elapsedMinutes = (ts.totalSeconds / 60).round();
    final timeMessage = _timeMessageForMode(ts.currentMode, elapsedMinutes);
    final normalizedMode = _normalizeMode(ts.currentMode);
    final recommendedExerciseObjects =
        StretchModeService().getRandomExerciseObjects(
      normalizedMode,
      count: 2,
    );
    List<String> exercises = recommendedExerciseObjects.map((e) => e.title).toList();
    if (exercises.isEmpty) {
      exercises = ts.exercises;
    }
    _notificationService.showNotification(
      title: ts.currentMode,
      body: '$timeMessage\nRecommended: ${exercises.join(", ")}',
      emoji: ts.currentEmoji,
      exercises: exercises,
      isSilent: ts.isSilent,
    );
    final ctx = _navigatorKey.currentContext;
    if (ctx != null) {
      TimerCompletionDialog.show(
        ctx,
        mode: ts.currentMode,
        emoji: ts.currentEmoji,
        message: timeMessage,
        exercises: exercises,
        dialogColor: ts.dialogColor,
        isSilent: ts.isSilent,
        onClose: null,
        recommendedExercises: recommendedExerciseObjects.isEmpty
            ? null
            : recommendedExerciseObjects,
        onGoToAnalysis: recommendedExerciseObjects.isEmpty
            ? null
            : (recommended) {
                Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => AnalysisScreen(
                      recommendedExercises: recommended,
                    ),
                  ),
                  (route) => false, 
                );
              },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Move in Peace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFD3D3D3),
      ),
      home: HomeScreen(timerService: widget.timerService),
    );
  }
}