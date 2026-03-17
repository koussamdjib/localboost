import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:localboost_shared/models/notification_preferences.dart';

part 'notification/notification_service_core.dart';
part 'notification/notification_service_preferences.dart';
part 'notification/notification_service_messages.dart';
part 'notification/notification_service_delivery.dart';
part 'notification/notification_service_types.dart';

/// Local notification service using flutter_local_notifications
///
/// PHASE 1 (Implementation Now):
/// - Local notifications for app events (stamp collection, rewards)
/// - Granular preferences management
/// - Quiet hours support
///
/// PHASE 2 (Requires Backend/FCM):
/// - Push notifications via Firebase Cloud Messaging
/// - Server-triggered notifications (nearby deals, expiring offers)
/// - Background notification handling
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final String _prefsKey = 'notification_preferences';
  NotificationPreferences? _preferences;

  /// Get current preferences
  NotificationPreferences get preferences =>
      _preferences ?? const NotificationPreferences();
}
