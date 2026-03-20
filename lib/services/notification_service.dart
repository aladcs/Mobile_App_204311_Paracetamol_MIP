/*
 * File: notification_service.dart
 * Feature : Core Feature
 * Description: Manages local notifications and system permissions for stretch reminders.
 *
 * Responsibilities:
 * - Handle local push notifications and system permissions
 * - Manage timer notifications and scheduling
 * - Track notification history and context
 * - Provide pure business logic without UI components
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_history_service.dart';

/// The [NotificationService] class represents a singleton service for managing all notifications.
///
/// Usage:
/// - Handle local push notifications and system permissions
/// - Manage timer notifications and scheduling
/// - Track notification history and context
/// - Provide pure business logic without UI components
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  
  /// Creates a singleton [NotificationService] instance.
  ///
  /// This factory constructor implements the singleton pattern to ensure consistent
  /// notification management throughout the application lifecycle, providing centralized
  /// access to notification functionality and preventing conflicts between multiple
  /// service instances.
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  final NotificationHistoryService _historyService = NotificationHistoryService();
  bool _isInitialized = false;
  /// Initializes the notification system with platform-specific settings.
  ///
  /// This method performs platform initialization and permission setup operations which may take time to complete.
  /// Throws an exception if platform services are unavailable or initialization fails.
  Future<void> initialize() async {
    if (_isInitialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
      },
    );
    _isInitialized = true;
  }
  /// Requests notification permissions from the user.
  ///
  /// This method performs platform permission request operations which may take time to complete.
  /// Throws an exception if permission system is unavailable or request fails.
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    final status = await Permission.notification.request();
    return status.isGranted;
  }
  /// Displays a system notification with the specified content and settings.
  ///
  /// Side effects:
  /// - Shows system notification in device notification panel
  /// - Records notification in history service for tracking
  /// - May request notification permissions from user if not granted
  /// - Triggers notification sound and vibration based on settings
  ///
  /// This method performs notification display operations and permission checks which may take time to complete.
  /// Throws an exception if notification initialization fails or platform services are unavailable.
  Future<void> showNotification({
    required String title,
    required String body,
    String? emoji,
    List<String>? exercises,
    bool isSilent = false,
  }) async {
    await initialize();
    
    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final androidDetails = AndroidNotificationDetails(
      isSilent ? 'stretch_reminder_silent' : 'stretch_reminder',
      isSilent ? 'Stretch Reminders (Silent)' : 'Stretch Reminders',
      channelDescription: 'Notifications for stretch reminders',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: !isSilent,
      styleInformation: BigTextStyleInformation(body),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !isSilent,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      emoji != null ? '$emoji $title' : title,
      body,
      details,
    );

    // บันทึกประวัติการแจ้งเตือน
    _historyService.addNotification(
      mode: title,
      emoji: emoji ?? '🔔',
      message: body,
      exercises: exercises ?? [],
    );
  }
  /// Displays a persistent timer notification with real-time updates.
  ///
  /// Side effects:
  /// - Shows ongoing notification in device notification panel
  /// - Creates non-dismissible notification that persists until cancelled
  /// - Updates notification content with current timer status
  ///
  /// This method performs notification display operations with ongoing status updates which may take time to complete.
  /// Throws an exception if notification permissions are denied or platform services fail.
  Future<void> showTimerNotification({
    required String modeName,
    required String emoji,
    required String timeRemaining,
  }) async {
    await initialize();

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final androidDetails = AndroidNotificationDetails(
      'timer_ongoing',
      'Timer',
      channelDescription: 'Shows remaining time while timer is running',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,        
      onlyAlertOnce: true,  
      playSound: false,
      enableVibration: false,
      showWhen: false,
      autoCancel: false,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.show(
      1, 
      '$emoji $modeName',
      'Time remaining: $timeRemaining',
      details,
    );
  }
  /// Cancels the active timer notification.
  ///
  /// Side effects:
  /// - Removes ongoing timer notification from device notification panel
  /// - Clears notification with ID 1 from system
  ///
  /// This method performs notification cancellation operations which may take time to complete.
  /// Throws an exception if notification system is unavailable or cancellation fails.
  Future<void> cancelTimerNotification() async {
    await _notifications.cancel(1);
  }
  /// Schedules a timer completion notification for future delivery.
  ///
  /// Side effects:
  /// - Schedules notification with ID 2 for future delivery
  /// - Registers notification with system scheduler
  /// - May request notification permissions from user if not granted
  ///
  /// This method performs timezone-aware notification scheduling which may take time to complete.
  /// Throws an exception if scheduling fails or notification permissions are insufficient.
  Future<void> scheduleTimerCompletion({
    required Duration duration,
    required String title,
    required String body,
    required String emoji,
    List<String>? exercises,
    bool isSilent = false,
  }) async {
    await initialize();
    
    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final scheduledDate = DateTime.now().add(duration);

    final androidDetails = AndroidNotificationDetails(
      'timer_completion',
      'Timer Completion',
      channelDescription: 'Notification when timer completes',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: !isSilent,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !isSilent,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.zonedSchedule(
      2, 
      emoji != null ? '$emoji $title' : title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  /// Cancels the scheduled timer completion notification.
  ///
  /// Side effects:
  /// - Removes scheduled notification with ID 2 from system scheduler
  /// - Prevents future notification delivery
  ///
  /// This method performs scheduled notification cancellation operations which may take time to complete.
  /// Throws an exception if notification system is unavailable or cancellation fails.
  Future<void> cancelScheduledTimerCompletion() async {
    await _notifications.cancel(2);
  }
  /// Cancels all active and scheduled notifications.
  ///
  /// Side effects:
  /// - Removes all notifications from device notification panel
  /// - Cancels all scheduled notifications
  /// - Clears notification history from system
  ///
  /// This method performs bulk notification cancellation operations which may take time to complete.
  /// Throws an exception if notification system is unavailable or cancellation fails.
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
