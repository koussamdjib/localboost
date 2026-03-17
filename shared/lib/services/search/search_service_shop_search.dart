part of '../search_service.dart';

Future<List<Shop>> _searchShopsAsyncImpl({
  required SearchFilter filter,
  LatLng? userLocation,
}) async {
  try {
    final latitude = userLocation?.latitude;
    final longitude = userLocation?.longitude;
    final radiusKm =
        userLocation != null && filter.distance != DistanceRange.all
            ? filter.distance.maxKm
            : null;
    final category = _categoryToApiValue(filter.category);

    final response = (filter.query.trim().isNotEmpty || category != null)
        ? await SearchService._shopEndpoints.searchShops(
            name: filter.query,
            category: category,
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
          )
        : await SearchService._shopEndpoints.listShops(
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
          );

    final cards = <Shop>[];
    for (final shop in response.data) {
      if (!_matchesDiscoveryOfferType(shop, filter.offerType)) continue;

      final programs = shop.loyaltyPrograms;
      if (shop.hasLoyaltyPrograms && programs.isNotEmpty) {
        // One card per loyalty program so all programs are discoverable.
        final multiProgram = programs.length > 1;
        for (final program in programs) {
          cards.add(_toLegacyShopForProgram(
            shop,
            program,
            userLocation,
            useExpandedId: multiProgram,
          ));
        }
      } else {
        cards.add(_toLegacyShop(shop, userLocation));
      }
    }

    return _sortShops(cards, filter.sortBy, userLocation);
  } catch (_) {
    return const <Shop>[];
  }
}

String? _categoryToApiValue(ShopCategory category) {
  switch (category) {
    case ShopCategory.all:
      return null;
    case ShopCategory.restaurant:
      return 'restaurant';
    case ShopCategory.cafe:
      return 'cafe';
    case ShopCategory.retail:
      return 'retail';
    case ShopCategory.electronics:
      return 'electronics';
    case ShopCategory.pharmacy:
      return 'pharmacy';
    case ShopCategory.bakery:
      return 'bakery';
    case ShopCategory.supermarket:
      return 'supermarket';
    case ShopCategory.beauty:
      return 'beauty';
    case ShopCategory.other:
      return 'other';
  }
}

bool _matchesDiscoveryOfferType(ShopDiscoveryShop shop, OfferType offerType) {
  switch (offerType) {
    case OfferType.deal:
    case OfferType.flashSale:
      return shop.hasActiveDeals;
    case OfferType.loyalty:
      return shop.hasLoyaltyPrograms;
    case OfferType.flyer:
      return false;
    case OfferType.all:
      return true;
  }
}

Shop _toLegacyShop(ShopDiscoveryShop shop, LatLng? userLocation) {
  final hasDeals = shop.hasActiveDeals;
  final hasLoyalty = shop.hasLoyaltyPrograms;
  // Prioritize loyalty classification so enrollment-capable shops expose loyalty UI.
  final dealType = hasLoyalty ? 'Loyalty' : 'Deal';
  final resolvedLatitude = shop.latitude ?? userLocation?.latitude ?? 0.0;
  final resolvedLongitude = shop.longitude ?? userLocation?.longitude ?? 0.0;
  final imageUrl = shop.coverImageUrl.isNotEmpty
      ? shop.coverImageUrl
      : (shop.logoUrl.isNotEmpty
          ? shop.logoUrl
          : 'https://placehold.co/1200x800?text=LocalBoost');
  final logoUrl = shop.logoUrl.isNotEmpty
      ? shop.logoUrl
      : (shop.coverImageUrl.isNotEmpty
          ? shop.coverImageUrl
          : 'https://placehold.co/200x200?text=LB');

  return Shop(
    id: shop.id.toString(),
    name: shop.name,
    stamps: 0,
    totalRequired: 10,
    dealType: dealType,
    timeLeft: hasDeals ? '24h' : '30 days',
    location: shop.address.isNotEmpty ? shop.address : 'Djibouti',
    rewardValue: hasLoyalty ? 'Loyalty reward' : 'Special offer',
    rewardType: hasLoyalty ? 'special_offer' : 'discount',
    imageUrl: imageUrl,
    logoUrl: logoUrl,
    latitude: resolvedLatitude,
    longitude: resolvedLongitude,
  );
}

/// Creates a [Shop] card for a single loyalty program within a shop.
///
/// When [useExpandedId] is true (shop has multiple programs), the card ID is
/// `lp-{programId}` to ensure uniqueness; otherwise it is `{shopId}` for
/// backwards-compatible single-program shops.
Shop _toLegacyShopForProgram(
  ShopDiscoveryShop shop,
  LoyaltyProgramSummary program,
  LatLng? userLocation, {
  bool useExpandedId = false,
}) {
  final resolvedLatitude = shop.latitude ?? userLocation?.latitude ?? 0.0;
  final resolvedLongitude = shop.longitude ?? userLocation?.longitude ?? 0.0;
  final imageUrl = shop.coverImageUrl.isNotEmpty
      ? shop.coverImageUrl
      : (shop.logoUrl.isNotEmpty
          ? shop.logoUrl
          : 'https://placehold.co/1200x800?text=LocalBoost');
  final logoUrl = shop.logoUrl.isNotEmpty
      ? shop.logoUrl
      : (shop.coverImageUrl.isNotEmpty
          ? shop.coverImageUrl
          : 'https://placehold.co/200x200?text=LB');

  final programId = program.id.toString();
  final cardId = useExpandedId ? 'lp-$programId' : shop.id.toString();
  final displayName = useExpandedId
      ? '${shop.name} — ${program.name}'
      : shop.name;

  return Shop(
    id: cardId,
    loyaltyProgramId: programId,
    name: displayName,
    stamps: 0,
    totalRequired: program.stampsRequired,
    dealType: 'Loyalty',
    timeLeft: '30 days',
    location: shop.address.isNotEmpty ? shop.address : 'Djibouti',
    rewardValue: program.rewardLabel.isNotEmpty
        ? program.rewardLabel
        : 'Récompense fidélité',
    rewardType: 'special_offer',
    imageUrl: imageUrl,
    logoUrl: logoUrl,
    latitude: resolvedLatitude,
    longitude: resolvedLongitude,
  );
}
