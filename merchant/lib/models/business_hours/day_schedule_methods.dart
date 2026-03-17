part of '../business_hours.dart';

extension DayScheduleMethods on DaySchedule {
  String get formattedHours =>
      '${_formatScheduleTime(openTime)} - ${_formatScheduleTime(closeTime)}';

  Map<String, dynamic> toJson() {
    return {
      'openHour': openTime.hour,
      'openMinute': openTime.minute,
      'closeHour': closeTime.hour,
      'closeMinute': closeTime.minute,
    };
  }
}

String _formatScheduleTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
