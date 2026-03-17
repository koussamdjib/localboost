import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/locale_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/providers/staff_provider.dart';
import 'package:localboost_merchant/screens/profile/staff_management_screen.dart';

part 'parts/merchant_profile_screen_view.dart';
part 'parts/merchant_profile_screen_settings_tile.dart';

/// Merchant profile screen with account settings
class MerchantProfileScreen extends StatelessWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildMerchantProfileScreen(context);
  }
}
