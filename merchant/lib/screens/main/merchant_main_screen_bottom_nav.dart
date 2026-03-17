part of '../merchant_main_screen.dart';

/// Merchant bottom navigation bar
class _MerchantBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final int pendingRewards;

  const _MerchantBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
    this.pendingRewards = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        height: 82,
        notchMargin: 6,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _NavBarItem(
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                label: 'Accueil',
                isSelected: selectedIndex == 0,
                badgeCount: pendingRewards,
                onTap: () => onItemTapped(0),
              ),
            ),
            Expanded(
              child: _NavBarItem(
                icon: Icons.campaign_outlined,
                selectedIcon: Icons.campaign,
                label: 'Campagnes',
                isSelected: selectedIndex == 1,
                onTap: () => onItemTapped(1),
              ),
            ),
            const SizedBox(width: 60), // Space for FAB
            Expanded(
              child: _NavBarItem(
                icon: Icons.store_outlined,
                selectedIcon: Icons.store,
                label: 'Boutiques',
                isSelected: selectedIndex == 2,
                onTap: () => onItemTapped(2),
              ),
            ),
            Expanded(
              child: _NavBarItem(
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                label: 'Analytiques',
                isSelected: selectedIndex == 3,
                onTap: () => onItemTapped(3),
              ),
            ),
            Expanded(
              child: _NavBarItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profil',
                isSelected: selectedIndex == 4,
                onTap: () => onItemTapped(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
