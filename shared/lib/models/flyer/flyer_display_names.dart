part of '../flyer.dart';

/// Extension to get French display names for categories
extension FlyerCategoryExtension on FlyerCategory {
  String get displayName {
    switch (this) {
      case FlyerCategory.supermarket:
        return 'Supermarché';
      case FlyerCategory.electronics:
        return 'Électronique';
      case FlyerCategory.pharmacy:
        return 'Pharmacie';
      case FlyerCategory.bakery:
        return 'Boulangerie';
      case FlyerCategory.sports:
        return 'Sports';
      case FlyerCategory.restaurant:
        return 'Restaurant';
      case FlyerCategory.fashion:
        return 'Mode';
      case FlyerCategory.other:
        return 'Autre';
    }
  }
}

/// Extension to get French display names for file types
extension FlyerTypeExtension on FlyerType {
  String get displayName {
    switch (this) {
      case FlyerType.image:
        return 'Image';
      case FlyerType.pdf:
        return 'PDF';
    }
  }
}

/// Extension to get French display names for status
extension FlyerStatusExtension on FlyerStatus {
  String get displayName {
    switch (this) {
      case FlyerStatus.draft:
        return 'Brouillon';
      case FlyerStatus.published:
        return 'Publié';
      case FlyerStatus.paused:
        return 'En pause';
      case FlyerStatus.expired:
        return 'Expiré';
    }
  }
}
