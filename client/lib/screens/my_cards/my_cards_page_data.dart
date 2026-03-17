part of '../my_cards_page.dart';

extension _MyCardsPageData on _MyCardsPageState {
  List<Shop> get _filteredShops {
    final enrollmentProvider =
        Provider.of<EnrollmentProvider>(context, listen: false);
    final allEnrollments = enrollmentProvider.enrollments;
    var filteredEnrollments = allEnrollments;

    bool hasOpenRewardRequest(Enrollment e) =>
        e.rewardStatus == RewardRequestStatus.requested ||
        e.rewardStatus == RewardRequestStatus.approved;

    switch (_selectedFilter) {
      case 'Actifs':
        filteredEnrollments = filteredEnrollments
            .where(
              (e) => !e.isRedeemed &&
                  !e.canRequestReward &&
                  !hasOpenRewardRequest(e),
            )
            .toList(growable: false);
        break;
      case 'Complétés':
        filteredEnrollments = filteredEnrollments
            .where((e) => e.canRequestReward || hasOpenRewardRequest(e))
            .toList(growable: false);
        break;
      case 'Utilisés':
        filteredEnrollments = filteredEnrollments
            .where((e) => e.isRedeemed)
            .toList(growable: false);
        break;
      case 'Tous':
      default:
        break;
    }

    return _toEnrollmentShops(filteredEnrollments);
  }

  List<Shop> _toEnrollmentShops(List<Enrollment> enrollments) {
    return enrollments.map((enrollment) {
      final rewardLabel = switch (enrollment.rewardStatus) {
        RewardRequestStatus.requested => 'Demande en attente',
        RewardRequestStatus.approved => 'Recompense approuvee',
        _ when enrollment.canRequestReward => 'Recompense disponible',
        _ => enrollment.loyaltyProgramName ?? 'Programme fidelite',
      };

      final programName = enrollment.loyaltyProgramName;
      final shopDisplayName = (programName != null && programName.isNotEmpty)
          ? '${enrollment.shopName} — $programName'
          : enrollment.shopName;

      return Shop(
        id: enrollment.shopId,
        enrollmentId: enrollment.id,
        loyaltyProgramId: enrollment.loyaltyProgramId,
        name: shopDisplayName,
        location: 'Djibouti',
        rewardValue: rewardLabel,
        rewardType: 'special_offer',
        dealType: 'Loyalty',
        stamps: enrollment.stampsCollected,
        totalRequired: enrollment.stampsRequired,
        timeLeft: '',
        logoUrl: '',
        latitude: 0,
        longitude: 0,
        history: null,
        isRedeemed: enrollment.isRedeemed,
        imageUrl: '',
      );
    }).toList(growable: false);
  }
}
