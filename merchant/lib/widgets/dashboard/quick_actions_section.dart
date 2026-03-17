import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_merchant/screens/flyers/flyer_form_screen.dart';
import 'package:localboost_merchant/screens/deals/deal_form_screen.dart';
import 'package:localboost_merchant/screens/loyalty/loyalty_form_screen.dart';
import 'package:localboost_merchant/screens/enrollments/enrollments_list_screen.dart';
import 'package:localboost_merchant/screens/enrollments/pending_rewards_screen.dart';
import 'package:localboost_merchant/screens/analytics/analytics_screen.dart';

part 'quick_actions/quick_actions_section_view.dart';
part 'quick_actions/quick_actions_section_navigation.dart';
part 'quick_actions/quick_action_button.dart';

/// Quick action buttons section for dashboard
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildQuickActionsSection(context);
  }
}
