// Search and filter models

/// Category filter options
enum ShopCategory {
  all('Tous'),
  restaurant('Restaurant'),
  cafe('Café'),
  retail('Commerce'),
  electronics('Électronique'),
  pharmacy('Pharmacie'),
  bakery('Boulangerie'),
  supermarket('Supermarché'),
  beauty('Beauté'),
  other('Autre');

  final String displayName;
  const ShopCategory(this.displayName);
}

/// Offer type filter
enum OfferType {
  all('Tous les types'),
  deal('Offres'),
  loyalty('Fidélité'),
  flashSale('Vente éclair'),
  flyer('Prospectus');

  final String displayName;
  const OfferType(this.displayName);
}

/// Distance range filter
enum DistanceRange {
  all('Toute distance', 999999),
  nearby('< 1 km', 1),
  close('< 3 km', 3),
  medium('< 5 km', 5),
  far('< 10 km', 10);

  final String displayName;
  final double maxKm;
  const DistanceRange(this.displayName, this.maxKm);
}

/// Sort options
enum SortOption {
  nearest('Plus proche'),
  newest('Plus récent'),
  expiringSoon('Expire bientôt'),
  mostStamps('Plus de timbres'),
  alphabetical('Alphabétique');

  final String displayName;
  const SortOption(this.displayName);
}

/// Search filter criteria
class SearchFilter {
  final String query;
  final ShopCategory category;
  final OfferType offerType;
  final DistanceRange distance;
  final SortOption sortBy;

  const SearchFilter({
    this.query = '',
    this.category = ShopCategory.all,
    this.offerType = OfferType.all,
    this.distance = DistanceRange.all,
    this.sortBy = SortOption.nearest,
  });

  SearchFilter copyWith({
    String? query,
    ShopCategory? category,
    OfferType? offerType,
    DistanceRange? distance,
    SortOption? sortBy,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      category: category ?? this.category,
      offerType: offerType ?? this.offerType,
      distance: distance ?? this.distance,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Check if any filters are active (excluding query and nearest sort)
  bool get hasActiveFilters {
    return category != ShopCategory.all ||
        offerType != OfferType.all ||
        distance != DistanceRange.all;
  }

  /// Count of active filters
  int get activeFilterCount {
    int count = 0;
    if (category != ShopCategory.all) count++;
    if (offerType != OfferType.all) count++;
    if (distance != DistanceRange.all) count++;
    return count;
  }
}

/// Search history entry
class SearchHistoryEntry {
  final String id;
  final String query;
  final DateTime timestamp;

  SearchHistoryEntry({
    required this.id,
    required this.query,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SearchHistoryEntry(
      id: json['id'] as String,
      query: json['query'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
