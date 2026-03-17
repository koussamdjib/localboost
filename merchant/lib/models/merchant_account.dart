import 'package:localboost_shared/models/search_filter.dart' show ShopCategory;
import 'package:localboost_merchant/models/business_hours.dart';

/// Merchant account model
class MerchantAccount {
  final String id;
  final String userId; // Link to User.id
  final String businessName;
  final String? description;
  final ShopCategory category;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? logoUrl;
  final String? coverImageUrl;
  final BusinessHours businessHours;
  final DateTime createdAt;
  final bool isVerified;
  final bool isActive;

  MerchantAccount({
    required this.id,
    required this.userId,
    required this.businessName,
    this.description,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.logoUrl,
    this.coverImageUrl,
    required this.businessHours,
    required this.createdAt,
    this.isVerified = false,
    this.isActive = true,
  });

  /// Check if profile is complete
  bool get isProfileComplete =>
      logoUrl != null && description != null && description!.isNotEmpty;

  /// Shop ID getter (uses merchant account ID as shop ID)
  String get shopId => id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessName': businessName,
      'description': description,
      'category': category.name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'businessHours': businessHours.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }

  factory MerchantAccount.fromJson(Map<String, dynamic> json) {
    return MerchantAccount(
      id: json['id'] as String,
      userId: json['userId'] as String,
      businessName: json['businessName'] as String,
      description: json['description'] as String?,
      category: ShopCategory.values.byName(json['category'] as String),
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      phone: json['phone'] as String?,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      businessHours: BusinessHours.fromJson(
        json['businessHours'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  MerchantAccount copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? description,
    ShopCategory? category,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? logoUrl,
    String? coverImageUrl,
    BusinessHours? businessHours,
    DateTime? createdAt,
    bool? isVerified,
    bool? isActive,
  }) {
    return MerchantAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      businessHours: businessHours ?? this.businessHours,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
    );
  }
}
