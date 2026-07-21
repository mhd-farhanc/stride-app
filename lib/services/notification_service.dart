import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wrapper for local notifications used for step reminders and daily summaries.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap — just open the app (default behavior).
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
    return true;
  }

  /// Show an instant notification (for step reminders).
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'step_reminders',
      'Step Reminders',
      channelDescription: 'Reminders to stay active',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  /// Schedule a daily summary notification.
  /// Note: Full scheduling with timezone support requires the `timezone` package.
  /// This simplified version fires once at the target time.
  Future<void> scheduleDailySummary({
    required int id,
    required DateTime scheduledDate,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_summary',
      'Daily Summary',
      channelDescription: 'End-of-day step summary',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      'Stride Daily Summary',
      body,
      details,
    );
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
