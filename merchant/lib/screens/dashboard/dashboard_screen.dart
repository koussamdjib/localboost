import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_merchant/providers/flyer_provider.dart';
import 'package:localboost_merchant/providers/deal_provider.dart';
import 'package:localboost_merchant/providers/loyalty_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/widgets/dashboard/summary_card.dart';
import 'package:localboost_merchant/widgets/dashboard/quick_actions_section.dart';
import 'package:localboost_merchant/widgets/dashboard/activity_section.dart';
import 'package:localboost_merchant/widgets/shop_selector_dropdown.dart';

part 'parts/dashboard_screen_data.dart';
part 'parts/dashboard_screen_view.dart';
part 'parts/dashboard_screen_summary.dart';

/// Merchant dashboard screen showing operational overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  int? _observedShopId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDashboardData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedId = Provider.of<ShopProvider>(context).selectedShop?.id;
    if (_observedShopId == selectedId) return;
    if (_observedShopId != null) {
      // Shop changed after initial load — reload for new selection.
      _observedShopId = selectedId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadDashboardData();
      });
    } else {
      _observedShopId = selectedId;
    }
  }

  void _setStateSafe(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return _buildDashboardScaffold();
  }
}
