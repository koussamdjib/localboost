part of '../transaction.dart';

extension TransactionDisplay on Transaction {
  /// Format timestamp for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }

  /// Format timestamp as full date
  String get formattedFullDate {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Get description based on transaction type
  String get description {
    switch (type) {
      case TransactionType.stampCollected:
        return stampsAdded == 1
            ? '1 timbre collecté'
            : '$stampsAdded timbres collectés';
      case TransactionType.rewardRedeemed:
        return 'Récompense utilisée: $rewardValue';
      case TransactionType.enrolled:
        return 'Inscription au programme';
      case TransactionType.unenrolled:
        return 'Désinscription du programme';
    }
  }
}
