part of '../dashboard_screen.dart';

extension _DashboardScreenView on _DashboardScreenState {
  Widget _buildDashboardScaffold() {
    final dealProvider = context.watch<DealProvider>();
    final loyaltyProvider = context.watch<LoyaltyProvider>();

    // Calculate aggregate stats.
    int totalStamps = 0;
    int totalRedemptions = 0;

    for (final program in loyaltyProvider.activePrograms) {
      totalStamps += program.totalStampsGranted;
      totalRedemptions += program.redemptionCount;
    }

    for (final deal in dealProvider.activeDeals) {
      totalRedemptions += deal.redemptionCount;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tableau de bord',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.charcoalText,
          ),
        ),
        actions: [
          const ShopSelectorDropdown(),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.charcoalText),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      ActivitySection(
                        totalStampsGranted: totalStamps,
                        totalRedemptions: totalRedemptions,
                      ),
                      const SizedBox(height: 24),
                      const QuickActionsSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final shopProvider = context.watch<ShopProvider>();
    final selectedShop = shopProvider.selectedShop;
    final businessName = selectedShop?.name ??
        shopProvider.merchantAccount?.businessName ??
        'Commerçant';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour,',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          businessName,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoalText,
          ),
        ),
      ],
    );
  }
}
