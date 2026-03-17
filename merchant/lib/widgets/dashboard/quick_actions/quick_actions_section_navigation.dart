part of '../quick_actions_section.dart';

extension _QuickActionsSectionNavigation on QuickActionsSection {
  void _navigateToFlyerForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FlyerFormScreen(),
      ),
    );
  }

  void _navigateToDealForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DealFormScreen(),
      ),
    );
  }

  void _navigateToLoyaltyForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoyaltyFormScreen(),
      ),
    );
  }

  void _navigateToEnrollments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnrollmentsListScreen(),
      ),
    );
  }

  void _navigateToPendingRewards(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PendingRewardsScreen(),
      ),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyticsScreen(),
      ),
    );
  }
}
