import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/providers/notification_provider.dart';

part 'notification_settings/notification_settings_content.dart';
part 'notification_settings/notification_settings_sections_primary.dart';
part 'notification_settings/notification_settings_sections_secondary.dart';
part 'notification_settings/notification_settings_section_widgets.dart';
part 'notification_settings/notification_settings_misc_widgets.dart';
part 'notification_settings/notification_settings_reset_dialog.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          return _buildSettingsContent(context, notificationProvider);
        },
      ),
    );
  }
}
