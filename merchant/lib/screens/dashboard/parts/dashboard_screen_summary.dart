part of '../dashboard_screen.dart';

extension _DashboardScreenSummary on _DashboardScreenState {
  Widget _buildSummaryCards() {
    final flyerProvider = context.watch<FlyerProvider>();
    final dealProvider = context.watch<DealProvider>();
    final loyaltyProvider = context.watch<LoyaltyProvider>();

    final activeFlyersCount = flyerProvider.publishedFlyers.length;
    final activeDealsCount = dealProvider.activeDeals.length;
    final activeProgramsCount = loyaltyProvider.activePrograms.length;

    // Calculate total stamps from all active programs.
    int totalStamps = 0;
    for (final program in loyaltyProvider.activePrograms) {
      totalStamps += program.totalStampsGranted;
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                label: 'Circulaires actives',
                value: activeFlyersCount.toString(),
                icon: Icons.collections,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                label: 'Promotions actives',
                value: activeDealsCount.toString(),
                icon: Icons.local_offer,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                label: 'Programmes fidélité',
                value: activeProgramsCount.toString(),
                icon: Icons.loyalty,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                label: 'Timbres accordés',
                value: totalStamps.toString(),
                icon: Icons.add_circle,
                color: AppColors.successGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
