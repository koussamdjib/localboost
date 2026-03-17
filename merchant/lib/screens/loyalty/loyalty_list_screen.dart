import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_merchant/providers/loyalty_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/widgets/loyalty/loyalty_program_card.dart';
import 'package:localboost_merchant/screens/loyalty/loyalty_form_screen.dart';
import 'package:localboost_merchant/screens/loyalty/detail/loyalty_detail_screen.dart';

part 'list/loyalty_list_screen_data.dart';
part 'list/loyalty_list_screen_view.dart';
part 'list/loyalty_list_screen_actions.dart';

/// Merchant loyalty programs list screen with tabs
class LoyaltyListScreen extends StatefulWidget {
  const LoyaltyListScreen({super.key});

  @override
  State<LoyaltyListScreen> createState() => _LoyaltyListScreenState();
}

class _LoyaltyListScreenState extends State<LoyaltyListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _observedShopId;
  bool _hasTrackedShopSelection = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final selectedShopId = Provider.of<ShopProvider>(context).selectedShop?.id;
    if (_hasTrackedShopSelection && _observedShopId == selectedShopId) {
      return;
    }

    _hasTrackedShopSelection = true;
    _observedShopId = selectedShopId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPrograms();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLoyaltyListScreen();
  }
}
