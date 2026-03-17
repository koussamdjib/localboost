import 'package:flutter/foundation.dart';
import 'package:localboost_shared/models/notification_preferences.dart';
import 'package:localboost_shared/services/notification_service.dart';

/// Provider for managing notification preferences and state
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  NotificationPreferences _preferences = const NotificationPreferences();
  bool _isLoading = false;

  NotificationPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;

  /// Initialize and load preferences
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _preferences = await _notificationService.loadPreferences();
    } catch (e) {
      print('Error loading notification preferences: $e');
      _preferences = const NotificationPreferences();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update master enabled toggle
  Future<void> setMasterEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(masterEnabled: enabled);
    await _savePreferences();
  }

  /// Update stamp collection alerts
  Future<void> setStampCollectionAlerts(bool enabled) async {
    _preferences = _preferences.copyWith(stampCollectionAlerts: enabled);
    await _savePreferences();
  }

  /// Update reward completion alerts
  Future<void> setRewardCompletionAlerts(bool enabled) async {
    _preferences = _preferences.copyWith(rewardCompletionAlerts: enabled);
    await _savePreferences();
  }

  /// Update nearby deals alerts
  Future<void> setNearbyDealsAlerts(bool enabled) async {
    _preferences = _preferences.copyWith(nearbyDealsAlerts: enabled);
    await _savePreferences();
  }

  /// Update new flyers alerts
  Future<void> setNewFlyersAlerts(bool enabled) async {
    _preferences = _preferences.copyWith(newFlyersAlerts: enabled);
    await _savePreferences();
  }

  /// Update expiring offers alerts
  Future<void> setExpiringOffersAlerts(bool enabled) async {
    _preferences = _preferences.copyWith(expiringOffersAlerts: enabled);
    await _savePreferences();
  }

  /// Update sound enabled
  Future<void> setSoundEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(soundEnabled: enabled);
    await _savePreferences();
  }

  /// Update vibration enabled
  Future<void> setVibrationEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(vibrationEnabled: enabled);
    await _savePreferences();
  }

  /// Update quiet hours
  Future<void> setQuietHours(String? start, String? end) async {
    _preferences = _preferences.copyWith(
      quietHoursStart: start,
      quietHoursEnd: end,
    );
    await _savePreferences();
  }

  /// Save preferences to storage
  Future<void> _savePreferences() async {
    await _notificationService.savePreferences(_preferences);
    notifyListeners();
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    _preferences = const NotificationPreferences();
    await _savePreferences();
  }
}
