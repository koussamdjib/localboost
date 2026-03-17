/// Status values mirror RedemptionStatus on the backend.
enum RewardRequestStatus { requested, approved, rejected, fulfilled }

RewardRequestStatus? _parseRewardStatus(String? value) {
  if (value == null) return null;
  switch (value) {
    case 'requested':
      return RewardRequestStatus.requested;
    case 'approved':
      return RewardRequestStatus.approved;
    case 'rejected':
      return RewardRequestStatus.rejected;
    case 'fulfilled':
      return RewardRequestStatus.fulfilled;
    default:
      return null;
  }
}

class Enrollment {
  final String id;
  final String userId;
  final String? customerName;
  final String? customerEmail;
  final String shopId;
  final String shopName;
  final String? loyaltyProgramId;
  final String? loyaltyProgramName;
  final int stampsCollected;
  final int stampsRequired;
  final DateTime enrolledAt;
  final DateTime? lastStampAt;
  final bool isCompleted;
  final bool isRedeemed;
  final RewardRequestStatus? rewardStatus;
  final int? rewardRequestId;
  final String qrToken;

  Enrollment({
    required this.id,
    required this.userId,
    this.customerName,
    this.customerEmail,
    required this.shopId,
    required this.shopName,
    this.loyaltyProgramId,
    this.loyaltyProgramName,
    required this.stampsCollected,
    required this.stampsRequired,
    required this.enrolledAt,
    this.lastStampAt,
    this.isCompleted = false,
    this.isRedeemed = false,
    this.rewardStatus,
    this.rewardRequestId,
    this.qrToken = '',
  });

  // Calculate progress percentage
  double get progress =>
      stampsRequired > 0 ? stampsCollected / stampsRequired : 0.0;

  // Check if eligible to request a reward (stamps met, no pending/fulfilled request)
  bool get canRequestReward =>
      stampsCollected >= stampsRequired &&
      !isRedeemed &&
      rewardStatus == null;

  // Legacy alias — kept for backwards compat; prefer canRequestReward for new UI.
  bool get canRedeem => canRequestReward;

  // Days since enrollment
  int get daysSinceEnrollment => DateTime.now().difference(enrolledAt).inDays;

  // Days since last stamp
  int? get daysSinceLastStamp => lastStampAt != null
      ? DateTime.now().difference(lastStampAt!).inDays
      : null;

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      customerName: json['customer_name'] as String?,
      customerEmail: json['customer_email'] as String?,
      shopId: json['shop_id']?.toString() ?? '',
      shopName: (json['shop_name'] as String?) ?? '',
      loyaltyProgramId: json['loyalty_program_id']?.toString(),
      loyaltyProgramName: json['loyalty_program_name'] as String?,
      stampsCollected: (json['stamps_collected'] as int?) ?? 0,
      stampsRequired: (json['stamps_required'] as int?) ?? 1,
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.parse(json['enrolled_at'] as String)
          : DateTime.now(),
      lastStampAt: json['last_stamp_at'] != null
          ? DateTime.parse(json['last_stamp_at'] as String)
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      isRedeemed: json['is_redeemed'] as bool? ?? false,
      rewardStatus:
          _parseRewardStatus(json['reward_status'] as String?),
      rewardRequestId: json['reward_request_id'] as int?,
      qrToken: (json['qr_token'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'shop_id': shopId,
      'shop_name': shopName,
      'stamps_collected': stampsCollected,
      'stamps_required': stampsRequired,
      'enrolled_at': enrolledAt.toIso8601String(),
      'last_stamp_at': lastStampAt?.toIso8601String(),
      'is_completed': isCompleted,
      'is_redeemed': isRedeemed,
      'reward_status': rewardStatus?.name,
      'reward_request_id': rewardRequestId,
      'qr_token': qrToken,
    };
  }

  Enrollment copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerEmail,
    String? shopId,
    String? shopName,
    int? stampsCollected,
    int? stampsRequired,
    DateTime? enrolledAt,
    DateTime? lastStampAt,
    bool? isCompleted,
    bool? isRedeemed,
    RewardRequestStatus? rewardStatus,
    int? rewardRequestId,
    String? qrToken,
    bool clearRewardStatus = false,
  }) {
    return Enrollment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      stampsCollected: stampsCollected ?? this.stampsCollected,
      stampsRequired: stampsRequired ?? this.stampsRequired,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      lastStampAt: lastStampAt ?? this.lastStampAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      rewardStatus: clearRewardStatus ? null : (rewardStatus ?? this.rewardStatus),
      rewardRequestId: clearRewardStatus ? null : (rewardRequestId ?? this.rewardRequestId),
      qrToken: qrToken ?? this.qrToken,
    );
  }
}

