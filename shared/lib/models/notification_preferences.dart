/// Granular notification preferences model
class NotificationPreferences {
  final bool masterEnabled; // Master toggle for all notifications
  final bool stampCollectionAlerts; // When user collects a stamp
  final bool rewardCompletionAlerts; // When loyalty card is completed
  final bool nearbyDealsAlerts; // New deals near user location
  final bool newFlyersAlerts; // New flyers from merchants
  final bool expiringOffersAlerts; // Offers expiring soon (requires backend)

  // Advanced preferences (for future use)
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String? quietHoursStart; // e.g., "22:00"
  final String? quietHoursEnd; // e.g., "08:00"

  const NotificationPreferences({
    this.masterEnabled = true,
    this.stampCollectionAlerts = true,
    this.rewardCompletionAlerts = true,
    this.nearbyDealsAlerts = true,
    this.newFlyersAlerts = true,
    this.expiringOffersAlerts = false, // Disabled by default (requires backend)
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  /// Check if notifications are allowed at all
  bool get isAnyEnabled =>
      masterEnabled &&
      (stampCollectionAlerts ||
          rewardCompletionAlerts ||
          nearbyDealsAlerts ||
          newFlyersAlerts ||
          expiringOffersAlerts);

  /// Check if currently in quiet hours
  bool get isInQuietHours {
    if (quietHoursStart == null || quietHoursEnd == null) return false;

    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

      final startParts = quietHoursStart!.split(':');
      final endParts = quietHoursEnd!.split(':');

      final start = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
      final end = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );

      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;

      if (startMinutes < endMinutes) {
        // Same day range (e.g., 08:00 - 22:00)
        return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
      } else {
        // Overnight range (e.g., 22:00 - 08:00)
        return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
      }
    } catch (e) {
      return false;
    }
  }

  /// Create from JSON (SharedPreferences)
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      masterEnabled: json['masterEnabled'] as bool? ?? true,
      stampCollectionAlerts: json['stampCollectionAlerts'] as bool? ?? true,
      rewardCompletionAlerts: json['rewardCompletionAlerts'] as bool? ?? true,
      nearbyDealsAlerts: json['nearbyDealsAlerts'] as bool? ?? true,
      newFlyersAlerts: json['newFlyersAlerts'] as bool? ?? true,
      expiringOffersAlerts: json['expiringOffersAlerts'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'masterEnabled': masterEnabled,
      'stampCollectionAlerts': stampCollectionAlerts,
      'rewardCompletionAlerts': rewardCompletionAlerts,
      'nearbyDealsAlerts': nearbyDealsAlerts,
      'newFlyersAlerts': newFlyersAlerts,
      'expiringOffersAlerts': expiringOffersAlerts,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  /// Create a copy with updated fields
  NotificationPreferences copyWith({
    bool? masterEnabled,
    bool? stampCollectionAlerts,
    bool? rewardCompletionAlerts,
    bool? nearbyDealsAlerts,
    bool? newFlyersAlerts,
    bool? expiringOffersAlerts,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationPreferences(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      stampCollectionAlerts:
          stampCollectionAlerts ?? this.stampCollectionAlerts,
      rewardCompletionAlerts:
          rewardCompletionAlerts ?? this.rewardCompletionAlerts,
      nearbyDealsAlerts: nearbyDealsAlerts ?? this.nearbyDealsAlerts,
      newFlyersAlerts: newFlyersAlerts ?? this.newFlyersAlerts,
      expiringOffersAlerts: expiringOffersAlerts ?? this.expiringOffersAlerts,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

/// TimeOfDay helper for quiet hours (avoiding Flutter imports in model)
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});
}
