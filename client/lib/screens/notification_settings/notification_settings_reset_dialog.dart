part of '../notification_settings_page.dart';

extension _NotificationSettingsResetDialog on NotificationSettingsPage {
  void _showResetDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Réinitialiser les paramètres',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Voulez-vous réinitialiser tous les paramètres de notification aux valeurs par défaut?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: AppColors.charcoalText),
            ),
          ),
          TextButton(
            onPressed: () async {
              await provider.resetToDefaults();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paramètres réinitialisés'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
            child: Text(
              'Réinitialiser',
              style: GoogleFonts.poppins(color: AppColors.urgencyOrange),
            ),
          ),
        ],
      ),
    );
  }
}
