part of '../deal.dart';

/// Extension for French display names
extension DealTypeExtension on DealType {
  String get displayName {
    switch (this) {
      case DealType.flashSale:
        return 'Vente Flash';
      case DealType.loyalty:
        return 'Programme Fidélité';
      case DealType.standard:
        return 'Offre Standard';
    }
  }
}

extension DealStatusExtension on DealStatus {
  String get displayName {
    switch (this) {
      case DealStatus.draft:
        return 'Brouillon';
      case DealStatus.active:
        return 'Actif';
      case DealStatus.expired:
        return 'Expiré';
    }
  }
}

extension RewardTypeExtension on RewardType {
  String get displayName {
    switch (this) {
      case RewardType.freeItem:
        return 'Article gratuit';
      case RewardType.discount:
        return 'Réduction';
      case RewardType.money:
        return 'Argent';
      case RewardType.specialOffer:
        return 'Offre spéciale';
    }
  }
}
