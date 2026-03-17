part of '../notification_settings_page.dart';

extension _NotificationSettingsContent on NotificationSettingsPage {
  Widget _buildSettingsContent(
    BuildContext context,
    NotificationProvider notificationProvider,
  ) {
    final prefs = notificationProvider.preferences;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildMasterSection(prefs, notificationProvider),
          const SizedBox(height: 16),
          _buildNotificationTypesSection(prefs, notificationProvider),
          const SizedBox(height: 16),
          _buildSoundAndVibrationSection(prefs, notificationProvider),
          const SizedBox(height: 16),
          _buildQuietHoursSection(context, prefs),
          const SizedBox(height: 24),
          _buildResetButton(context, notificationProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResetButton(
    BuildContext context,
    NotificationProvider notificationProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () => _showResetDialog(context, notificationProvider),
        child: Text(
          'Réinitialiser aux valeurs par défaut',
          style: GoogleFonts.poppins(
            color: AppColors.urgencyOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
