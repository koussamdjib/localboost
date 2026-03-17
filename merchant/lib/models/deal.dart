part 'deal/deal_display_names.dart';

/// Merchant deal/offer model
class Deal {
  final String id;
  final String shopId;
  final String title;
  final String description;
  final DealType dealType;
  final int stampsRequired; // For loyalty programs (0 for flash/standard deals)
  final String rewardValue;
  final RewardType rewardType;
  final String? imageUrl;
  final String termsAndConditions;
  final DateTime startDate;
  final DateTime endDate;
  final DealStatus status;
  final int? maxEnrollments;

  // Analytics
  final int enrollmentCount;
  final int stampsGrantedTotal;
  final int redemptionCount;
  final int viewCount;
  final int shareCount;
  final DateTime createdAt;

  Deal({
    required this.id,
    required this.shopId,
    required this.title,
    required this.description,
    required this.dealType,
    this.stampsRequired = 0,
    required this.rewardValue,
    required this.rewardType,
    this.imageUrl,
    required this.termsAndConditions,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.maxEnrollments,
    this.enrollmentCount = 0,
    this.stampsGrantedTotal = 0,
    this.redemptionCount = 0,
    this.viewCount = 0,
    this.shareCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Computed properties
  bool get isActive =>
      status == DealStatus.active &&
      DateTime.now().isBefore(endDate) &&
      DateTime.now().isAfter(startDate);
  bool get isDraft => status == DealStatus.draft;
  bool get isExpired =>
      DateTime.now().isAfter(endDate) || status == DealStatus.expired;
  bool get canEdit => status != DealStatus.expired;
  bool get canEnroll =>
      maxEnrollments == null || enrollmentCount < maxEnrollments!;

  double get redemptionRate =>
      enrollmentCount > 0 ? redemptionCount / enrollmentCount : 0.0;

  String get timeLeft {
    if (isExpired) return 'Expiré';
    final diff = endDate.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}j restants';
    if (diff.inHours > 0) return '${diff.inHours}h restants';
    if (diff.inMinutes > 0) return '${diff.inMinutes}min restants';
    return 'Expire bientôt';
  }

  Deal copyWith({
    String? id,
    String? shopId,
    String? title,
    String? description,
    DealType? dealType,
    int? stampsRequired,
    String? rewardValue,
    RewardType? rewardType,
    String? imageUrl,
    String? termsAndConditions,
    DateTime? startDate,
    DateTime? endDate,
    DealStatus? status,
    int? maxEnrollments,
    int? enrollmentCount,
    int? stampsGrantedTotal,
    int? redemptionCount,
    int? viewCount,
    int? shareCount,
    DateTime? createdAt,
  }) {
    return Deal(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      title: title ?? this.title,
      description: description ?? this.description,
      dealType: dealType ?? this.dealType,
      stampsRequired: stampsRequired ?? this.stampsRequired,
      rewardValue: rewardValue ?? this.rewardValue,
      rewardType: rewardType ?? this.rewardType,
      imageUrl: imageUrl ?? this.imageUrl,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      maxEnrollments: maxEnrollments ?? this.maxEnrollments,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      stampsGrantedTotal: stampsGrantedTotal ?? this.stampsGrantedTotal,
      redemptionCount: redemptionCount ?? this.redemptionCount,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Deal type enumeration
enum DealType { flashSale, loyalty, standard }

/// Deal status enumeration
enum DealStatus { draft, active, expired }

/// Reward type enumeration
enum RewardType { freeItem, discount, money, specialOffer }
