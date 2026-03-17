part of '../notification_service.dart';

extension NotificationServiceDeliveryX on NotificationService {
  /// Internal method to show notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final soundEnabled = _preferences?.soundEnabled ?? true;
    final vibrationEnabled = _preferences?.vibrationEnabled ?? true;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'localboost_channel', // Channel ID
      'LocalBoost Notifications', // Channel name
      channelDescription: 'Notifications pour offres, timbres et récompenses',
      importance: Importance.high,
      priority: Priority.high,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
      icon: '@mipmap/ic_launcher',
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: soundEnabled,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
