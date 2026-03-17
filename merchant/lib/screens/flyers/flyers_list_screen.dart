import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_merchant/providers/flyer_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/widgets/flyers/flyer_card_widget.dart';
import 'package:localboost_merchant/screens/flyers/flyer_form_screen.dart';

part 'list/flyers_list_screen_data.dart';
part 'list/flyers_list_screen_view.dart';
part 'list/flyers_list_screen_actions.dart';

/// Merchant flyers list screen with draft/published tabs
class FlyersListScreen extends StatefulWidget {
  const FlyersListScreen({super.key});

  @override
  State<FlyersListScreen> createState() => _FlyersListScreenState();
}

class _FlyersListScreenState extends State<FlyersListScreen>
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
      if (!mounted) {
        return;
      }
      _loadFlyers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildFlyersListScreen();
  }
}
