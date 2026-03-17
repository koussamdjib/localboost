part 'flyer/flyer_display_names.dart';

/// File type for promotional flyers
enum FlyerType {
  image,
  pdf,
}

/// Flyer publication status
enum FlyerStatus {
  draft,
  published,
  paused,
  expired,
}

/// Category of the store/flyer
enum FlyerCategory {
  supermarket,
  electronics,
  pharmacy,
  bakery,
  sports,
  restaurant,
  fashion,
  other,
}

/// Product within a flyer
class FlyerProduct {
  final String name;
  final String? oldPrice;
  final String newPrice;
  final String? discount;
  final String imageUrl;

  FlyerProduct({
    required this.name,
    this.oldPrice,
    required this.newPrice,
    this.discount,
    required this.imageUrl,
  });
}

/// Multi-product promotional flyer
class Flyer {
  final String id;
  final String storeName;
  final String title;
  final String validUntil;
  final List<FlyerProduct>? products; // Optional for merchant flyers
  final String storeLogoUrl;
  final FlyerType fileType;
  final FlyerCategory category;
  final DateTime publishedDate;
  final double latitude;
  final double longitude;

  // Merchant-specific fields (optional for backward compatibility)
  final String? shopId;
  final String? description;
  final String? fileUrl; // Actual flyer document URL
  final String? thumbnailUrl; // Cover image
  final FlyerStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? viewCount;
  final int? shareCount;
  final DateTime? createdAt;

  Flyer({
    required this.id,
    required this.storeName,
    required this.title,
    required this.validUntil,
    this.products,
    required this.storeLogoUrl,
    required this.fileType,
    required this.category,
    required this.publishedDate,
    required this.latitude,
    required this.longitude,
    this.shopId,
    this.description,
    this.fileUrl,
    this.thumbnailUrl,
    this.status,
    this.startDate,
    this.endDate,
    this.viewCount,
    this.shareCount,
    this.createdAt,
  });

  bool get isPublished => status == FlyerStatus.published;
  bool get isDraft => status == FlyerStatus.draft;
  bool get canEdit => status != FlyerStatus.expired;

  Flyer copyWith({
    String? id,
    String? storeName,
    String? title,
    String? validUntil,
    List<FlyerProduct>? products,
    String? storeLogoUrl,
    FlyerType? fileType,
    FlyerCategory? category,
    DateTime? publishedDate,
    double? latitude,
    double? longitude,
    String? shopId,
    String? description,
    String? fileUrl,
    String? thumbnailUrl,
    FlyerStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? viewCount,
    int? shareCount,
    DateTime? createdAt,
  }) {
    return Flyer(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      title: title ?? this.title,
      validUntil: validUntil ?? this.validUntil,
      products: products ?? this.products,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      fileType: fileType ?? this.fileType,
      category: category ?? this.category,
      publishedDate: publishedDate ?? this.publishedDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      shopId: shopId ?? this.shopId,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Flyer.fromJson(Map<String, dynamic> json) {
    final startDate = _parseDateTime(json['starts_at'] ?? json['start_date']);
    final endDate = _parseDateTime(json['ends_at'] ?? json['end_date']);
    final createdAt = _parseDateTime(json['created_at']);
    final publishedDate =
        _parseDateTime(json['published_at'] ?? json['published_date']) ??
            createdAt ??
            DateTime.now();

    return Flyer(
      id: _toStringValue(json['id']),
      shopId: _toNullableString(json['shop_id']),
      storeName: _firstNonEmptyString([
            json['store_name'],
            json['storeName'],
            json['shop_name'],
          ]) ??
          '',
      title: _toStringValue(json['title']),
      validUntil: _firstNonEmptyString([
            json['valid_until'],
          ]) ??
          _buildValidUntil(endDate),
      products: _parseProducts(json['products']),
      storeLogoUrl: _firstNonEmptyString([
            json['store_logo_url'],
            json['storeLogoUrl'],
          ]) ??
          '',
      fileType: _flyerTypeFromRaw(
        _firstNonEmptyString([
              json['file_type'],
              json['fileType'],
              json['file_format'],
            ]) ??
            '',
      ),
      category: _flyerCategoryFromRaw(
        _firstNonEmptyString([
              json['category'],
            ]) ??
            '',
      ),
      publishedDate: publishedDate,
      latitude: _toDoubleValue(json['latitude']),
      longitude: _toDoubleValue(json['longitude']),
      description: _blankToNull(_toNullableString(json['description'])),
      fileUrl: _blankToNull(_toNullableString(json['file_url'])),
      thumbnailUrl: _blankToNull(_toNullableString(json['thumbnail_url'])),
      status: _flyerStatusFromRaw(
        _toNullableString(json['status']),
        endDate: endDate,
      ),
      startDate: startDate,
      endDate: endDate,
      viewCount: _toIntValue(json['view_count']),
      shareCount: _toIntValue(json['share_count']),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMerchantPayload() {
    return <String, dynamic>{
      'title': title,
      'description': description ?? '',
      'file_type': fileType.name,
      'status': _flyerStatusToApi(status),
      'starts_at': startDate?.toUtc().toIso8601String(),
      'ends_at': endDate?.toUtc().toIso8601String(),
      'file_url': fileUrl ?? '',
      'thumbnail_url': thumbnailUrl ?? '',
    };
  }
}

FlyerType _flyerTypeFromRaw(String rawValue) {
  switch (rawValue.trim().toLowerCase()) {
    case 'pdf':
      return FlyerType.pdf;
    case 'image':
    default:
      return FlyerType.image;
  }
}

FlyerCategory _flyerCategoryFromRaw(String rawValue) {
  switch (rawValue.trim().toLowerCase()) {
    case 'supermarket':
      return FlyerCategory.supermarket;
    case 'electronics':
      return FlyerCategory.electronics;
    case 'pharmacy':
      return FlyerCategory.pharmacy;
    case 'bakery':
      return FlyerCategory.bakery;
    case 'sports':
      return FlyerCategory.sports;
    case 'restaurant':
      return FlyerCategory.restaurant;
    case 'fashion':
      return FlyerCategory.fashion;
    case 'other':
    default:
      return FlyerCategory.other;
  }
}

FlyerStatus? _flyerStatusFromRaw(String? rawValue, {DateTime? endDate}) {
  if (endDate != null && endDate.isBefore(DateTime.now())) {
    return FlyerStatus.expired;
  }

  switch ((rawValue ?? '').trim().toLowerCase()) {
    case 'draft':
      return FlyerStatus.draft;
    case 'published':
      return FlyerStatus.published;
    case 'paused':
      return FlyerStatus.paused;
    case 'expired':
      return FlyerStatus.expired;
    default:
      return null;
  }
}

String _flyerStatusToApi(FlyerStatus? status) {
  switch (status) {
    case FlyerStatus.published:
      return 'published';
    case FlyerStatus.paused:
      return 'paused';
    case FlyerStatus.expired:
      return 'expired';
    case FlyerStatus.draft:
    case null:
      return 'draft';
  }
}

List<FlyerProduct>? _parseProducts(dynamic rawProducts) {
  if (rawProducts is! List) {
    return null;
  }

  final products = rawProducts
      .whereType<Map>()
      .map((item) {
        final json = Map<String, dynamic>.from(item);
        return FlyerProduct(
          name: _toStringValue(json['name']),
          oldPrice: _blankToNull(_toNullableString(json['old_price'])),
          newPrice: _toStringValue(json['new_price']),
          discount: _blankToNull(_toNullableString(json['discount'])),
          imageUrl: _toStringValue(json['image_url']),
        );
      })
      .toList(growable: false);

  return products.isEmpty ? null : products;
}

DateTime? _parseDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}

String _toStringValue(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

String? _toNullableString(dynamic value) {
  if (value == null) {
    return null;
  }
  final normalized = value.toString();
  return normalized;
}

String? _firstNonEmptyString(List<dynamic> values) {
  for (final value in values) {
    final normalized = _toNullableString(value)?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
  }
  return null;
}

String? _blankToNull(String? value) {
  if (value == null) {
    return null;
  }
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return null;
  }
  return normalized;
}

int? _toIntValue(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

double _toDoubleValue(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

String _buildValidUntil(DateTime? endDate) {
  if (endDate == null) {
    return 'Validité non précisée';
  }

  final localEndDate = endDate.toLocal();
  final day = localEndDate.day.toString().padLeft(2, '0');
  final month = localEndDate.month.toString().padLeft(2, '0');
  final year = localEndDate.year.toString().padLeft(4, '0');
  return 'Valable jusqu\'au $day/$month/$year';
}
