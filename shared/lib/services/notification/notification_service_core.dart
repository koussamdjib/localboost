part of '../notification_service.dart';

extension NotificationServiceCoreX on NotificationService {
  /// Initialize the notification service
  Future<void> initialize() async {
    // Load preferences (works on all platforms)
    await loadPreferences();

    // flutter_local_notifications is not supported on web — skip native init.
    if (kIsWeb) return;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions (iOS)
    await _requestPermissions();
  }

  /// Request notification permissions (mainly for iOS)
  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Handle notification tap — in-app routing is handled via NotificationsPage.
  void _onNotificationTapped(NotificationResponse response) {
    // Navigation is handled by the in-app notifications list (_handleTap).
    // Push notification tap routing would require a global navigator key.
  }
}
