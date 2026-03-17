import 'package:flutter/material.dart';

part 'business_hours/day_of_week_labels.dart';
part 'business_hours/day_schedule_methods.dart';
part 'business_hours/business_hours_status.dart';
part 'business_hours/business_hours_serialization.dart';

/// Day of week enum
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;
}

/// Schedule for a single day
class DaySchedule {
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const DaySchedule({
    required this.openTime,
    required this.closeTime,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      openTime: TimeOfDay(
        hour: json['openHour'] as int,
        minute: json['openMinute'] as int,
      ),
      closeTime: TimeOfDay(
        hour: json['closeHour'] as int,
        minute: json['closeMinute'] as int,
      ),
    );
  }
}

/// Business hours configuration
class BusinessHours {
  final Map<DayOfWeek, DaySchedule?> schedule;

  const BusinessHours({required this.schedule});

  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    final Map<DayOfWeek, DaySchedule?> parsedSchedule = {};

    for (var day in DayOfWeek.values) {
      final dayData = json[day.name];
      if (dayData != null) {
        parsedSchedule[day] =
            DaySchedule.fromJson(dayData as Map<String, dynamic>);
      } else {
        parsedSchedule[day] = null;
      }
    }

    return BusinessHours(schedule: parsedSchedule);
  }

  /// Default business hours (9 AM - 6 PM, Monday-Saturday)
  factory BusinessHours.defaultHours() {
    return const BusinessHours(
      schedule: {
        DayOfWeek.monday: DaySchedule(
          openTime: TimeOfDay(hour: 9, minute: 0),
          closeTime: TimeOfDay(hour: 18, minute: 0),
        ),
        DayOfWeek.tuesday: DaySchedule(
          openTime: TimeOfDay(hour: 9, minute: 0),
          closeTime: TimeOfDay(hour: 18, minute: 0),
        ),
        DayOfWeek.wednesday: DaySchedule(
          openTime: TimeOfDay(hour: 9, minute: 0),
          closeTime: TimeOfDay(hour: 18, minute: 0),
        ),
        DayOfWeek.thursday: DaySchedule(
          openTime: TimeOfDay(hour: 9, minute: 0),
          closeTime: TimeOfDay(hour: 18, minute: 0),
        ),
        DayOfWeek.friday: DaySchedule(
          openTime: TimeOfDay(hour: 9, minute: 0),
          closeTime: TimeOfDay(hour: 18, minute: 0),
        ),
        DayOfWeek.saturday: DaySchedule(
          openTime: TimeOfDay(hour: 9, minute: 0),
          closeTime: TimeOfDay(hour: 14, minute: 0),
        ),
        DayOfWeek.sunday: null, // Closed on Sunday
      },
    );
  }
}
