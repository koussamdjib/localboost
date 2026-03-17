part of '../quick_actions_section.dart';

extension _QuickActionsSectionView on QuickActionsSection {
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoalText,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
            final safeWidth = math.max(0.0, maxWidth);
            final useSingleColumn = safeWidth < 280;
            final itemWidth =
                useSingleColumn ? safeWidth : (safeWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _QuickActionButton(
                    label: 'Circulaire',
                    icon: Icons.collections,
                    color: Colors.blue,
                    onTap: () => _navigateToFlyerForm(context),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _QuickActionButton(
                    label: 'Promotion',
                    icon: Icons.local_offer,
                    color: Colors.orange,
                    onTap: () => _navigateToDealForm(context),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _QuickActionButton(
                    label: 'Fidelite',
                    icon: Icons.loyalty,
                    color: AppColors.primaryGreen,
                    onTap: () => _navigateToLoyaltyForm(context),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _QuickActionButton(
                    label: 'Clients',
                    icon: Icons.people,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => _navigateToEnrollments(context),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Consumer<EnrollmentProvider>(
          builder: (context, enrollmentProvider, _) {
            final pendingCount = enrollmentProvider.enrollments
                .where((e) =>
                    e.rewardStatus == RewardRequestStatus.requested ||
                    e.rewardStatus == RewardRequestStatus.approved)
                .length;
            return SizedBox(
              width: double.infinity,
              child: _QuickActionButton(
                label: pendingCount > 0
                    ? 'Récompenses ($pendingCount en attente)'
                    : 'Récompenses',
                icon: Icons.card_giftcard,
                color: const Color(0xFFEF4444),
                onTap: () => _navigateToPendingRewards(context),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _QuickActionButton(
            label: 'Analytiques',
            icon: Icons.bar_chart,
            color: const Color(0xFF6366F1),
            onTap: () => _navigateToAnalytics(context),
          ),
        ),
      ],
    );
  }
}
