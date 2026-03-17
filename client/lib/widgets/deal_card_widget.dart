import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_client/screens/join_stamp_card_page.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_shared/core/utils/share_helper.dart';

part 'deal_card/deal_card_widget_build.dart';
part 'deal_card/deal_card_widget_content.dart';
part 'deal_card/deal_card_widget_progress.dart';
part 'deal_card/deal_card_widget_enrollment.dart';
part 'deal_card/deal_card_widget_badges.dart';

class DealCardWidget extends StatelessWidget {
  final Shop shop;
  final Function(Shop) onTap;

  /// When true the card fills the full available width (list mode).
  /// When false it uses a fixed carousel width (75% of screen, clamped).
  final bool isListItem;

  const DealCardWidget({
    super.key,
    required this.shop,
    required this.onTap,
    this.isListItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDealCard(context);
  }
}
