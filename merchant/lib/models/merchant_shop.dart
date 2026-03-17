enum MerchantShopStatus {
  draft,
  active,
  suspended,
  archived;

  static MerchantShopStatus fromApi(String value) {
    switch (value.trim().toLowerCase()) {
      case 'active':
        return MerchantShopStatus.active;
      case 'suspended':
        return MerchantShopStatus.suspended;
      case 'archived':
        return MerchantShopStatus.archived;
      case 'draft':
      default:
        return MerchantShopStatus.draft;
    }
  }

  String toApi() => name;

  String get label {
    switch (this) {
      case MerchantShopStatus.draft:
        return 'Draft';
      case MerchantShopStatus.active:
        return 'Active';
      case MerchantShopStatus.suspended:
        return 'Suspended';
      case MerchantShopStatus.archived:
        return 'Archived';
    }
  }
}

class MerchantShop {
  final int id;
  final int merchantProfile;
  final String name;
  final String slug;
  final String description;
  final String category;
  final String phoneNumber;
  final String email;
  final Map<String, dynamic>? businessHours;
  final String address;
  final String addressLine2;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final String logo;
  final String coverImage;
  final MerchantShopStatus status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MerchantShop({
    required this.id,
    required this.merchantProfile,
    required this.name,
    required this.slug,
    required this.description,
    required this.category,
    required this.phoneNumber,
    required this.email,
    this.businessHours,
    required this.address,
    required this.addressLine2,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.logo,
    required this.coverImage,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantShop.fromJson(Map<String, dynamic> json) {
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    final rawBusinessHours = json['business_hours'];
    final businessHours = rawBusinessHours is Map
        ? Map<String, dynamic>.from(rawBusinessHours)
        : null;

    return MerchantShop(
      id: _toInt(json['id']) ?? 0,
      merchantProfile: _toInt(json['merchant_profile']) ?? 0,
      name: (json['name'] ?? '') as String,
      slug: (json['slug'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      phoneNumber: (json['phone_number'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      businessHours: businessHours,
      address: (json['address'] ?? '') as String,
      addressLine2: (json['address_line_2'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      country: (json['country'] ?? '') as String,
      latitude: _toDouble(latitude),
      longitude: _toDouble(longitude),
      logo: (json['logo'] ?? '') as String,
      coverImage: (json['cover_image'] ?? '') as String,
      status: MerchantShopStatus.fromApi((json['status'] ?? 'draft') as String),
      isActive: (json['is_active'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['created_at'] ?? '') as String) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '') as String) ?? DateTime.now(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
