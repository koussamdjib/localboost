/// Merchant loyalty program model
class LoyaltyProgram {
  final String id;
  final String shopId;
  final String title;
  final String description;
  final int stampsRequired;
  final String rewardDescription;
  final String? imageUrl;
  final String termsAndConditions;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final ProgramStatus status;
  final int? maxEnrollments;
  
  // Analytics
  final int enrollmentCount;
  final int totalStampsGranted;
  final int redemptionCount;
  final int activeMembers;
  final DateTime createdAt;

  LoyaltyProgram({
    required this.id,
    required this.shopId,
    required this.title,
    required this.description,
    required this.stampsRequired,
    required this.rewardDescription,
    this.imageUrl,
    required this.termsAndConditions,
    this.validFrom,
    this.validUntil,
    required this.status,
    this.maxEnrollments,
    this.enrollmentCount = 0,
    this.totalStampsGranted = 0,
    this.redemptionCount = 0,
    this.activeMembers = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Computed properties
  bool get isActive => status == ProgramStatus.active && !isExpired;
  bool get isDraft => status == ProgramStatus.draft;
  bool get isPaused => status == ProgramStatus.paused;
  bool get canEdit => status != ProgramStatus.archived;
  
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }
  
  bool get canAcceptEnrollments {
    if (!isActive) return false;
    if (maxEnrollments == null) return true;
    return enrollmentCount < maxEnrollments!;
  }
  
  double get redemptionRate => enrollmentCount > 0 ? redemptionCount / enrollmentCount : 0.0;
  double get completionRate => activeMembers > 0 ? redemptionCount / activeMembers : 0.0;
  
  String get validityStatus {
    if (validFrom != null && DateTime.now().isBefore(validFrom!)) {
      return 'Commence le ${_formatDate(validFrom!)}';
    }
    if (validUntil != null) {
      if (isExpired) return 'Expiré';
      final daysLeft = validUntil!.difference(DateTime.now()).inDays;
      if (daysLeft <= 7) return '$daysLeft jours restants';
      return 'Expire le ${_formatDate(validUntil!)}';
    }
    return 'Sans limite';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  LoyaltyProgram copyWith({
    String? id,
    String? shopId,
    String? title,
    String? description,
    int? stampsRequired,
    String? rewardDescription,
    String? imageUrl,
    String? termsAndConditions,
    DateTime? validFrom,
    DateTime? validUntil,
    ProgramStatus? status,
    int? maxEnrollments,
    int? enrollmentCount,
    int? totalStampsGranted,
    int? redemptionCount,
    int? activeMembers,
    DateTime? createdAt,
  }) {
    return LoyaltyProgram(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      title: title ?? this.title,
      description: description ?? this.description,
      stampsRequired: stampsRequired ?? this.stampsRequired,
      rewardDescription: rewardDescription ?? this.rewardDescription,
      imageUrl: imageUrl ?? this.imageUrl,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      maxEnrollments: maxEnrollments ?? this.maxEnrollments,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      totalStampsGranted: totalStampsGranted ?? this.totalStampsGranted,
      redemptionCount: redemptionCount ?? this.redemptionCount,
      activeMembers: activeMembers ?? this.activeMembers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Program status enumeration
enum ProgramStatus { draft, active, paused, archived }

/// Extension for French display names
extension ProgramStatusExtension on ProgramStatus {
  String get displayName {
    switch (this) {
      case ProgramStatus.draft:
        return 'Brouillon';
      case ProgramStatus.active:
        return 'Actif';
      case ProgramStatus.paused:
        return 'En pause';
      case ProgramStatus.archived:
        return 'Archivé';
    }
  }
}
