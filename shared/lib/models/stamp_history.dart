/// Individual stamp collection event for loyalty programs
class StampHistory {
  final DateTime collectedAt;
  final String merchantNote;
  final String? location;
  final int? stampsAdded;

  StampHistory({
    required this.collectedAt,
    required this.merchantNote,
    this.location,
    this.stampsAdded,
  });

  factory StampHistory.fromJson(Map<String, dynamic> json) {
    return StampHistory(
      collectedAt: DateTime.parse(json['collected_at'] as String),
      merchantNote: (json['merchant_note'] as String?)?.trim().isNotEmpty == true
          ? (json['merchant_note'] as String).trim()
          : 'Timbre ajouté',
      location: _stringOrNull(json['location']),
      stampsAdded: _intOrNull(json['stamps_added']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collected_at': collectedAt.toIso8601String(),
      'merchant_note': merchantNote,
      'location': location,
      'stamps_added': stampsAdded,
    };
  }

  /// Helper to format the date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(collectedAt);

    if (difference.inDays == 0) {
      return "Aujourd'hui à ${collectedAt.hour.toString().padLeft(2, '0')}:${collectedAt.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Hier à ${collectedAt.hour.toString().padLeft(2, '0')}:${collectedAt.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "Il y a $weeks semaine${weeks > 1 ? 's' : ''}";
    } else {
      final months = (difference.inDays / 30).floor();
      return "Il y a $months mois";
    }
  }

  /// Full formatted date for detailed view
  String get fullFormattedDate {
    final months = [
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sep',
      'oct',
      'nov',
      'déc'
    ];
    return "${collectedAt.day} ${months[collectedAt.month - 1]} ${collectedAt.year} à ${collectedAt.hour.toString().padLeft(2, '0')}:${collectedAt.minute.toString().padLeft(2, '0')}";
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  static int? _intOrNull(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
