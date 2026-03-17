part of '../business_hours.dart';

extension BusinessHoursStatus on BusinessHours {
  /// Check if shop is open now
  bool isOpenNow() {
    final now = DateTime.now();
    final dayOfWeek = DayOfWeek.values[now.weekday - 1];
    final daySchedule = schedule[dayOfWeek];

    if (daySchedule == null) return false;

    final currentTime = TimeOfDay.now();
    final currentMinutes = _timeToMinutes(currentTime);
    final openMinutes = _timeToMinutes(daySchedule.openTime);
    final closeMinutes = _timeToMinutes(daySchedule.closeTime);

    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  /// Get opening status text
  String getOpeningStatus() {
    if (isOpenNow()) {
      return 'Ouvert maintenant';
    }

    final now = DateTime.now();
    final dayOfWeek = DayOfWeek.values[now.weekday - 1];
    final todaySchedule = schedule[dayOfWeek];

    if (todaySchedule != null) {
      return 'Fermé • Ouvre à ${_formatScheduleTime(todaySchedule.openTime)}';
    }

    return 'Fermé aujourd\'hui';
  }
}

int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;
