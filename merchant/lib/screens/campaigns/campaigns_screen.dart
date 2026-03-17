import 'package:flutter/material.dart';
import 'package:localboost_merchant/screens/flyers/flyers_list_screen.dart';
import 'package:localboost_merchant/screens/deals/deals_list_screen.dart';
import 'package:localboost_merchant/screens/loyalty/loyalty_list_screen.dart';
import 'package:localboost_merchant/widgets/shop_selector_dropdown.dart';

/// Merchant campaigns screen (flyers, deals, loyalty)
class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campagnes'),
        actions: const [ShopSelectorDropdown(), SizedBox(width: 8)],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Circulaires', icon: Icon(Icons.picture_as_pdf, size: 20)),
            Tab(text: 'Promotions', icon: Icon(Icons.local_offer, size: 20)),
            Tab(text: 'Fidélité', icon: Icon(Icons.card_giftcard, size: 20)),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: const [
            FlyersListScreen(),
            DealsListScreen(),
            LoyaltyListScreen(),
          ],
        ),
      ),
    );
  }
}
