part of '../business_hours.dart';

extension BusinessHoursSerialization on BusinessHours {
  Map<String, dynamic> toJson() {
    return {
      for (var entry in schedule.entries) entry.key.name: entry.value?.toJson(),
    };
  }
}
