part of '../notification_settings_page.dart';

extension _NotificationSettingsSectionsSecondary on NotificationSettingsPage {
  Widget _buildSoundAndVibrationSection(
    dynamic prefs,
    NotificationProvider provider,
  ) {
    return _buildSection(
      title: 'Son et vibration',
      children: [
        _buildSwitchTile(
          icon: Icons.volume_up,
          title: 'Son',
          subtitle: 'Jouer un son pour les notifications',
          value: prefs.soundEnabled,
          onChanged: prefs.masterEnabled ? provider.setSoundEnabled : null,
        ),
        const Divider(height: 1, indent: 60),
        _buildSwitchTile(
          icon: Icons.vibration,
          title: 'Vibration',
          subtitle: 'Vibrer lors des notifications',
          value: prefs.vibrationEnabled,
          onChanged: prefs.masterEnabled ? provider.setVibrationEnabled : null,
        ),
      ],
    );
  }

  Widget _buildQuietHoursSection(BuildContext context, dynamic prefs) {
    return _buildSection(
      title: 'Heures silencieuses',
      subtitle: 'Fonctionnalité à venir',
      children: [
        _buildInfoTile(
          icon: Icons.nightlight_round,
          title: 'Mode silencieux',
          subtitle: prefs.quietHoursStart != null
              ? 'De ${prefs.quietHoursStart} à ${prefs.quietHoursEnd}'
              : 'Non configuré',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Fonctionnalité à venir dans une prochaine mise à jour',
                ),
                backgroundColor: AppColors.accentBlue,
              ),
            );
          },
        ),
      ],
    );
  }
}
