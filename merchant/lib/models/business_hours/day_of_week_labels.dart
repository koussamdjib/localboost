part of '../business_hours.dart';

extension DayOfWeekLabels on DayOfWeek {
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Lundi';
      case DayOfWeek.tuesday:
        return 'Mardi';
      case DayOfWeek.wednesday:
        return 'Mercredi';
      case DayOfWeek.thursday:
        return 'Jeudi';
      case DayOfWeek.friday:
        return 'Vendredi';
      case DayOfWeek.saturday:
        return 'Samedi';
      case DayOfWeek.sunday:
        return 'Dimanche';
    }
  }

  String get shortName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Lun';
      case DayOfWeek.tuesday:
        return 'Mar';
      case DayOfWeek.wednesday:
        return 'Mer';
      case DayOfWeek.thursday:
        return 'Jeu';
      case DayOfWeek.friday:
        return 'Ven';
      case DayOfWeek.saturday:
        return 'Sam';
      case DayOfWeek.sunday:
        return 'Dim';
    }
  }
}
