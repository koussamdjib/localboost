import 'package:localboost_shared/models/loyalty_program_summary.dart';

class ShopDiscoveryShop {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String category;
  final String logoUrl;
  final String coverImageUrl;
  final String phoneNumber;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final bool hasActiveDeals;
  final bool hasLoyaltyPrograms;
  final List<LoyaltyProgramSummary> loyaltyPrograms;
  final double? distanceKm;

  ShopDiscoveryShop({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.category,
    required this.logoUrl,
    required this.coverImageUrl,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.hasActiveDeals,
    required this.hasLoyaltyPrograms,
    this.loyaltyPrograms = const [],
    this.distanceKm,
  });

  factory ShopDiscoveryShop.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    final rawPrograms = json['loyalty_programs'];
    final loyaltyPrograms = (rawPrograms is List)
        ? rawPrograms
            .whereType<Map<String, dynamic>>()
            .map(LoyaltyProgramSummary.fromJson)
            .toList(growable: false)
        : const <LoyaltyProgramSummary>[];

    return ShopDiscoveryShop(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      logoUrl: (json['logo_url'] as String?) ?? '',
      coverImageUrl: (json['cover_image_url'] as String?) ?? '',
      phoneNumber: (json['phone_number'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      isActive: (json['is_active'] as bool?) ?? false,
      hasActiveDeals: (json['has_active_deals'] as bool?) ?? false,
      hasLoyaltyPrograms: (json['has_loyalty_programs'] as bool?) ?? false,
      loyaltyPrograms: loyaltyPrograms,
      distanceKm: parseDouble(json['distance_km']),
    );
  }
}
