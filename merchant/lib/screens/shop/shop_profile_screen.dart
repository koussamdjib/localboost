import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/models/business_hours.dart';
import 'package:localboost_merchant/screens/shop/edit_business_hours_screen.dart';

part 'profile/shop_profile_screen_view.dart';
part 'profile/shop_profile_screen_info_section.dart';
part 'profile/shop_profile_screen_verification_badge.dart';

/// Merchant shop profile view screen
class ShopProfileScreen extends StatelessWidget {
  const ShopProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildShopProfileScreen(context);
  }
}
