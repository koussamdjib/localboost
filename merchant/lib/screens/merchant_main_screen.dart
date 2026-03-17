import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/providers/staff_provider.dart';
import 'package:localboost_merchant/screens/analytics/analytics_screen.dart';
import 'package:localboost_merchant/screens/campaigns/campaigns_screen.dart';
import 'package:localboost_merchant/screens/dashboard/dashboard_screen.dart';
import 'package:localboost_merchant/screens/profile/merchant_profile_screen.dart';
import 'package:localboost_merchant/screens/scanner/merchant_scanner_screen.dart';
import 'package:localboost_merchant/screens/shops/my_shops_screen.dart';

part 'main/merchant_main_screen_scanner_button.dart';
part 'main/merchant_main_screen_bottom_nav.dart';
part 'main/merchant_main_screen_nav_item.dart';

/// Merchant main screen with bottom navigation
class MerchantMainScreen extends StatefulWidget {
  const MerchantMainScreen({super.key});

  @override
  State<MerchantMainScreen> createState() => _MerchantMainScreenState();
}

class _MerchantMainScreenState extends State<MerchantMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const CampaignsScreen(),
    const MyShopsScreen(),
    const AnalyticsScreen(),
    const MerchantProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _initialLoad();
    });
  }

  Future<void> _initialLoad() async {
    final shopProvider = context.read<ShopProvider>();
    await shopProvider.loadMyShops();
    if (!mounted) return;
    final shopId = shopProvider.merchantAccount?.shopId;
    if (shopId != null) {
      context.read<EnrollmentProvider>().loadShopEnrollments(shopId);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onScannerPressed() {
    final shopProvider = context.read<ShopProvider>();
    final staffProvider = context.read<StaffProvider>();

    if (shopProvider.merchantAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune boutique selectionnee')),
      );
      return;
    }

    // If staff members are registered, offer owner vs. staff access.
    if (staffProvider.staff.isNotEmpty) {
      _showScannerAccessDialog(shopProvider, staffProvider);
    } else {
      _openScanner(shopProvider.merchantAccount!.shopId,
          shopProvider.merchantAccount!.businessName);
    }
  }

  void _openScanner(String shopId, String shopName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchantScannerScreen(
          shopId: shopId,
          shopName: shopName,
        ),
      ),
    ).then((_) {
      // Refresh enrollment data after scanner session ends.
      if (mounted) {
        context.read<EnrollmentProvider>().loadShopEnrollments(shopId);
      }
    });
  }

  Future<void> _showScannerAccessDialog(
    ShopProvider shopProvider,
    StaffProvider staffProvider,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accès scanner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: AppColors.primaryGreen),
              title: const Text('Accès propriétaire'),
              subtitle: const Text('Accès complet'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(ctx);
                _openScanner(
                  shopProvider.merchantAccount!.shopId,
                  shopProvider.merchantAccount!.businessName,
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.badge_outlined, color: Colors.blue),
              title: const Text('Mode employé'),
              subtitle: const Text('Saisir le code PIN'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(ctx);
                _showStaffPinDialog(shopProvider, staffProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStaffPinDialog(
    ShopProvider shopProvider,
    StaffProvider staffProvider,
  ) async {
    final pinCtrl = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: const Text('Code PIN employé'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pinCtrl,
                  decoration: InputDecoration(
                    labelText: 'Code PIN (4 chiffres)',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    errorText: error,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () {
                  final member = staffProvider.validatePin(pinCtrl.text.trim());
                  if (member != null) {
                    Navigator.pop(ctx);
                    _openScanner(
                      shopProvider.merchantAccount!.shopId,
                      '${shopProvider.merchantAccount!.businessName} — ${member.name}',
                    );
                  } else {
                    setStateDialog(() => error = 'Code PIN incorrect');
                  }
                },
                child: const Text('Valider'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingRewards = context
        .watch<EnrollmentProvider>()
        .enrollments
        .where((e) =>
            e.rewardStatus == RewardRequestStatus.requested ||
            e.rewardStatus == RewardRequestStatus.approved)
        .length;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _MerchantBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        pendingRewards: pendingRewards,
      ),
      floatingActionButton: _ScannerButton(onPressed: _onScannerPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
