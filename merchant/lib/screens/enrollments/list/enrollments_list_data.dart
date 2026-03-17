part of '../enrollments_list_screen.dart';

extension _EnrollmentsListData on _EnrollmentsListScreenState {
  Future<void> _loadEnrollments() async {
    _setStateSafe(() => _isLoading = true);

    final shopProvider = context.read<ShopProvider>();
    final merchantAccount = shopProvider.merchantAccount;
    if (merchantAccount != null) {
      await context
          .read<EnrollmentProvider>()
          .loadShopEnrollments(merchantAccount.shopId);
    }

    _setStateSafe(() => _isLoading = false);
  }

  List<Enrollment> _filterEnrollments(List<Enrollment> enrollments) {
    var filtered = enrollments;

    // Filter by merchant's shop.
    final shopProvider = context.read<ShopProvider>();
    if (shopProvider.merchantAccount != null) {
      final shopId = shopProvider.merchantAccount!.shopId;
      filtered = filtered.where((e) => e.shopId == shopId).toList();
    }

    // Filter by status.
    switch (_selectedFilter) {
      case EnrollmentFilter.active:
        filtered = filtered
            .where((e) =>
                !e.isRedeemed &&
                e.stampsCollected < e.stampsRequired &&
                e.rewardStatus == null)
            .toList();
        break;
      case EnrollmentFilter.completed:
        filtered = filtered
            .where((e) =>
                !e.isRedeemed &&
                (e.canRequestReward ||
                    e.rewardStatus == RewardRequestStatus.requested ||
                    e.rewardStatus == RewardRequestStatus.approved))
            .toList();
        break;
      case EnrollmentFilter.redeemed:
        filtered = filtered.where((e) => e.isRedeemed).toList();
        break;
      case EnrollmentFilter.all:
        break;
    }

    // Filter by search query.
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        return e.userId.toLowerCase().contains(q) ||
            (e.customerName?.toLowerCase().contains(q) ?? false) ||
            (e.customerEmail?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Sort by most recent.
    filtered.sort((a, b) => b.enrolledAt.compareTo(a.enrolledAt));
    return filtered;
  }
}
