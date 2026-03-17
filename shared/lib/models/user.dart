part 'user/user_role_display.dart';

/// User role enum
enum UserRole {
  customer,
  merchant;
}

/// User model with authentication and profile data
class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String language; // 'fr', 'en', 'ar'
  final bool notificationsEnabled;
  final UserRole role; // customer or merchant
  final DateTime createdAt;
  final DateTime? lastLogin;

  // User location preferences
  final double? lastLatitude;
  final double? lastLongitude;


  // User stats
  final int totalStamps;
  final int totalRewardsRedeemed;
  final int totalOffersJoined;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImageUrl,
    this.language = 'fr',
    this.notificationsEnabled = true,
    this.role = UserRole.customer,
    required this.createdAt,
    this.lastLogin,
    this.lastLatitude,
    this.lastLongitude,
    this.totalStamps = 0,
    this.totalRewardsRedeemed = 0,
    this.totalOffersJoined = 0,
  });

  /// Get user initials for avatar
  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
  }

  /// Create User from JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    String? firstNonNullString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
        if (value != null) {
          final converted = value.toString();
          if (converted.trim().isNotEmpty) {
            return converted;
          }
        }
      }
      return null;
    }

    int firstInt(List<String> keys, {int fallback = 0}) {
      for (final key in keys) {
        final value = json[key];
        if (value is int) {
          return value;
        }
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return parsed;
          }
        }
      }
      return fallback;
    }

    double? firstDouble(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is double) {
          return value;
        }
        if (value is int) {
          return value.toDouble();
        }
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) {
            return parsed;
          }
        }
      }
      return null;
    }

    DateTime? firstDateTimeNullable(List<String> keys) {
      final raw = firstNonNullString(keys);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      return DateTime.tryParse(raw);
    }

    final firstName = firstNonNullString(['first_name']);
    final lastName = firstNonNullString(['last_name']);
    final derivedName = [firstName, lastName]
        .where((part) => part != null && part.isNotEmpty)
        .join(' ')
        .trim();

    final createdAt = firstDateTimeNullable(['createdAt', 'created_at']) ??
        DateTime.now();
    final roleName =
        (firstNonNullString(['role']) ?? 'customer').toLowerCase();

    return User(
      id: firstNonNullString(['id', 'user_id']) ?? '',
      email: firstNonNullString(['email']) ?? '',
      name: firstNonNullString(['name']) ??
          (derivedName.isNotEmpty
              ? derivedName
              : (firstNonNullString(['username']) ?? 'Utilisateur')),
      phoneNumber: firstNonNullString(['phoneNumber', 'phone_number']),
      profileImageUrl:
          firstNonNullString(['profileImageUrl', 'profile_image_url']),
      language: firstNonNullString(['language']) ?? 'fr',
      notificationsEnabled: json['notificationsEnabled'] as bool? ??
          json['notifications_enabled'] as bool? ??
          true,
      role: roleName == 'merchant' ? UserRole.merchant : UserRole.customer,
      createdAt: createdAt,
      lastLogin: firstDateTimeNullable(['lastLogin', 'last_login']),
      lastLatitude: firstDouble(['lastLatitude', 'last_latitude']),
      lastLongitude: firstDouble(['lastLongitude', 'last_longitude']),
      totalStamps: firstInt(['totalStamps', 'total_stamps']),
      totalRewardsRedeemed: firstInt(
        ['totalRewardsRedeemed', 'total_rewards_redeemed'],
      ),
      totalOffersJoined: firstInt(['totalOffersJoined', 'total_offers_joined']),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'lastLatitude': lastLatitude,
      'lastLongitude': lastLongitude,
      'totalStamps': totalStamps,
      'totalRewardsRedeemed': totalRewardsRedeemed,
      'totalOffersJoined': totalOffersJoined,
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    String? language,
    bool? notificationsEnabled,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    double? lastLatitude,
    double? lastLongitude,
    int? totalStamps,
    int? totalRewardsRedeemed,
    int? totalOffersJoined,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      totalStamps: totalStamps ?? this.totalStamps,
      totalRewardsRedeemed: totalRewardsRedeemed ?? this.totalRewardsRedeemed,
      totalOffersJoined: totalOffersJoined ?? this.totalOffersJoined,
    );
  }
}
