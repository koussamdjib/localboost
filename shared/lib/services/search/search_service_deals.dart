part of '../search_service.dart';

Future<List<Shop>> _searchDealsAsyncImpl({
  required SearchFilter filter,
  LatLng? userLocation,
  int? shopId,
}) async {
  if (!_supportsPublicDeals(filter.offerType)) {
    return const <Shop>[];
  }

  try {
    final category = _categoryToApiValue(filter.category);
    final dealsResponse = await SearchService._apiClient.get(
      'deals/',
      queryParameters: <String, dynamic>{
        if (filter.query.trim().isNotEmpty) 'q': filter.query.trim(),
        if (category != null) 'category': category,
        if (shopId != null) 'shop_id': shopId,
      },
    );

    final rawDeals = _extractDealsPayload(dealsResponse.data);
    if (rawDeals.isEmpty) {
      return const <Shop>[];
    }

    final latitude = userLocation?.latitude;
    final longitude = userLocation?.longitude;
    final radiusKm =
        userLocation != null && filter.distance != DistanceRange.all
            ? filter.distance.maxKm
            : null;

    // Check if all deals already carry embedded shop info (shop_name field).
    // When available we can skip the extra shops API call entirely.
    final bool hasEmbeddedShopInfo =
        rawDeals.isNotEmpty && rawDeals.first.containsKey('shop_name');

    final Map<int, ShopDiscoveryShop> shopById;
    if (hasEmbeddedShopInfo) {
      // No extra API call needed — shop name/logo come from the deal JSON.
      shopById = const {};
    } else if (shopId != null) {
      // Efficient single-shop lookup instead of fetching all shops
      final detail = await SearchService._shopEndpoints.getShopDetail(shopId);
      shopById = {shopId: detail.data};
    } else {
      final shopsResponse = await SearchService._shopEndpoints.listShops(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      shopById = <int, ShopDiscoveryShop>{
        for (final shop in shopsResponse.data) shop.id: shop,
      };
    }

    var mappedDeals = rawDeals
        .map((dealJson) => _dealToLegacyShop(dealJson, shopById))
        .whereType<Shop>()
        .toList(growable: false);

    if (filter.offerType == OfferType.flashSale) {
      mappedDeals = mappedDeals
          .where((shop) => shop.dealType == 'Flash Sale')
          .toList(growable: false);
    }

    if (filter.distance != DistanceRange.all && userLocation != null) {
      mappedDeals = mappedDeals.where((shop) {
        final distance = _calculateDistance(
          userLocation,
          LatLng(shop.latitude, shop.longitude),
        );
        return distance <= filter.distance.maxKm;
      }).toList(growable: false);
    }

    final sortedDeals = mappedDeals.toList(growable: true);
    return _sortShops(sortedDeals, filter.sortBy, userLocation);
  } catch (_) {
    return const <Shop>[];
  }
}

bool _supportsPublicDeals(OfferType offerType) {
  switch (offerType) {
    case OfferType.deal:
    case OfferType.flashSale:
      return true;
    case OfferType.all:
    case OfferType.loyalty:
    case OfferType.flyer:
      return false;
  }
}

List<Map<String, dynamic>> _extractDealsPayload(dynamic payload) {
  final rawItems = <dynamic>[];

  if (payload is List) {
    rawItems.addAll(payload);
  } else if (payload is Map && payload['results'] is List) {
    rawItems.addAll(payload['results'] as List<dynamic>);
  }

  return rawItems
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Shop? _dealToLegacyShop(
  Map<String, dynamic> json,
  Map<int, ShopDiscoveryShop> shopById,
) {
  final dealId = _stringValue(json['id']).trim();
  final shopId = _intValue(json['shop_id']);

  if (dealId.isEmpty || shopId == null) {
    return null;
  }

  // Prefer embedded shop fields (from PublicDealSerializer) over the separate
  // shop lookup so that the second API call can be avoided.
  final shop = shopById[shopId];
  final embeddedName = _stringValue(json['shop_name']).trim();
  final embeddedLogo = _stringValue(json['shop_logo_url']).trim();

  final apiDealType = _stringValue(json['deal_type']).trim().toLowerCase();
  final dealType = _toLegacyDealType(apiDealType);
  final rewardType = _toLegacyRewardType(apiDealType);
  final title = _stringValue(json['title']).trim();
  final description = _stringValue(json['description']).trim();
  final rewardValue = title.isNotEmpty
      ? title
      : (description.isNotEmpty ? description : 'Offre speciale');

  final shopName = embeddedName.isNotEmpty
      ? embeddedName
      : (shop?.name ?? 'Commerce local');
  final shopLogo = embeddedLogo.isNotEmpty
      ? embeddedLogo
      : (shop != null && shop.logoUrl.isNotEmpty ? shop.logoUrl : '');
  final shopCover = shop?.coverImageUrl ?? '';

  final imageUrl = _resolveApiImageUrl(json['image']) ??
      (shopCover.isNotEmpty ? shopCover : (shopLogo.isNotEmpty ? shopLogo
          : 'https://placehold.co/1200x800?text=LocalBoost'));
  final logoUrl = shopLogo.isNotEmpty
      ? shopLogo
      : (shopCover.isNotEmpty ? shopCover
          : 'https://placehold.co/200x200?text=LB');

  final endsAt = _dateTimeValue(json['ends_at']);

  return Shop(
    id: 'deal-$dealId',
    name: shopName,
    stamps: 0,
    totalRequired: 10,
    dealType: dealType,
    timeLeft: _buildDealTimeLeft(endsAt),
    location:
        shop != null && shop.address.isNotEmpty ? shop.address : 'Djibouti',
    rewardValue: rewardValue,
    rewardType: rewardType,
    imageUrl: imageUrl,
    logoUrl: logoUrl,
    latitude: shop?.latitude ?? 0.0,
    longitude: shop?.longitude ?? 0.0,
  );
}

String _toLegacyDealType(String apiDealType) {
  switch (apiDealType) {
    case 'percentage':
      return 'Flash Sale';
    case 'amount':
    case 'stamp':
    default:
      return 'Deal';
  }
}

String _toLegacyRewardType(String apiDealType) {
  switch (apiDealType) {
    case 'stamp':
      return 'special_offer';
    case 'percentage':
    case 'amount':
    default:
      return 'discount';
  }
}

String _buildDealTimeLeft(DateTime? endsAt) {
  if (endsAt == null) {
    return '';
  }

  final now = DateTime.now().toUtc();
  final remaining = endsAt.difference(now);
  if (remaining.isNegative) {
    return '';
  }

  if (remaining.inHours < 24) {
    final hours = remaining.inHours <= 0 ? 1 : remaining.inHours;
    return '${hours}h';
  }

  final days = remaining.inDays <= 0 ? 1 : remaining.inDays;
  return '$days days';
}

String? _resolveApiImageUrl(dynamic imageValue) {
  final imagePath = _stringValue(imageValue).trim();
  if (imagePath.isEmpty) {
    return null;
  }
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }

  final baseUri = Uri.parse(ApiConfig.normalizedBaseUrl);
  if (imagePath.startsWith('/')) {
    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: imagePath,
    ).toString();
  }

  return baseUri.resolve(imagePath).toString();
}

String _stringValue(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

int? _intValue(dynamic value) {
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

DateTime? _dateTimeValue(dynamic value) {
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim())?.toUtc();
  }
  return null;
}
