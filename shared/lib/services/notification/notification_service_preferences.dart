part of '../notification_service.dart';

extension NotificationServicePreferencesX on NotificationService {
  /// Load notification preferences
  Future<NotificationPreferences> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _preferences = NotificationPreferences.fromJson(json);
      } else {
        _preferences = const NotificationPreferences();
      }

      return _preferences!;
    } catch (e) {
      _preferences = const NotificationPreferences();
      return _preferences!;
    }
  }

  /// Save notification preferences
  Future<void> savePreferences(NotificationPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(preferences.toJson());
      await prefs.setString(_prefsKey, jsonString);
      _preferences = preferences;
    } catch (e) {
      print('Error saving notification preferences: $e');
    }
  }

  /// Check if notification should be shown based on preferences
  bool _shouldShowNotification(NotificationType type) {
    if (_preferences == null || !_preferences!.masterEnabled) {
      return false;
    }

    if (_preferences!.isInQuietHours) {
      return false;
    }

    switch (type) {
      case NotificationType.stampCollected:
        return _preferences!.stampCollectionAlerts;
      case NotificationType.rewardCompleted:
        return _preferences!.rewardCompletionAlerts;
      case NotificationType.nearbyDeal:
        return _preferences!.nearbyDealsAlerts;
      case NotificationType.newFlyer:
        return _preferences!.newFlyersAlerts;
      case NotificationType.expiringOffer:
        return _preferences!.expiringOffersAlerts;
    }
  }
}
