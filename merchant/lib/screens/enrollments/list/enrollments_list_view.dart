part of '../enrollments_list_screen.dart';

extension _EnrollmentsListView on _EnrollmentsListScreenState {
  Widget _buildEnrollmentsScreen() {
    final enrollmentProvider = context.watch<EnrollmentProvider>();
    final shopProvider = context.watch<ShopProvider>();

    if (shopProvider.merchantAccount == null) {
      return _buildNoMerchantAccount();
    }

    final allEnrollments = enrollmentProvider.enrollments
        .where((e) => e.shopId == shopProvider.merchantAccount!.shopId)
        .toList();

    final activeCount =
        allEnrollments.where((e) => !e.isRedeemed && !e.canRequestReward && e.rewardStatus == null).length;
    final completedCount = allEnrollments
        .where((e) =>
            !e.isRedeemed &&
            (e.canRequestReward ||
                e.rewardStatus == RewardRequestStatus.requested ||
                e.rewardStatus == RewardRequestStatus.approved))
        .length;
    final redeemedCount = allEnrollments.where((e) => e.isRedeemed).length;

    final filteredEnrollments = _filterEnrollments(allEnrollments);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Clients inscrits',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.charcoalText),
            onPressed: _loadEnrollments,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadEnrollments,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchBar(),
                  EnrollmentFilters(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (filter) {
                      _setStateSafe(() => _selectedFilter = filter);
                    },
                    allCount: allEnrollments.length,
                    activeCount: activeCount,
                    completedCount: completedCount,
                    redeemedCount: redeemedCount,
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (enrollmentProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 32,
                      ),
                      child: Text(
                        enrollmentProvider.error!,
                        style: GoogleFonts.poppins(
                          color: Colors.red.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    _buildEnrollmentsList(filteredEnrollments, embedded: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => _setStateSafe(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Rechercher par nom ou email...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildEnrollmentsList(List<Enrollment> enrollments,
      {bool embedded = false}) {
    if (enrollments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = enrollments[index];
        final hasActiveRequest =
            enrollment.rewardStatus == RewardRequestStatus.requested ||
            enrollment.rewardStatus == RewardRequestStatus.approved;
        return EnrollmentCard(
          enrollment: enrollment,
          onTap: () => _navigateToDetails(enrollment),
          onApproveRedemption: hasActiveRequest && !enrollment.isRedeemed
              ? () => _handleMerchantRewardAction(enrollment)
              : null,
        );
      },
    );
  }
}
