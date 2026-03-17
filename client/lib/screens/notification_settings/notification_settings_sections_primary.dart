part of '../notification_settings_page.dart';

extension _NotificationSettingsSectionsPrimary on NotificationSettingsPage {
  Widget _buildMasterSection(dynamic prefs, NotificationProvider provider) {
    return _buildSection(
      title: 'Contrôle Principal',
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_active,
          title: 'Activer les notifications',
          subtitle: prefs.masterEnabled
              ? 'Toutes les notifications sont activées'
              : 'Toutes les notifications sont désactivées',
          value: prefs.masterEnabled,
          onChanged: provider.setMasterEnabled,
        ),
      ],
    );
  }

  Widget _buildNotificationTypesSection(
    dynamic prefs,
    NotificationProvider provider,
  ) {
    return _buildSection(
      title: 'Types de notifications',
      subtitle: prefs.masterEnabled
          ? null
          : 'Activez d\'abord les notifications ci-dessus',
      children: [
        _buildSwitchTile(
          icon: Icons.check_circle_outline,
          title: 'Collecte de timbres',
          subtitle: 'Alertes lors de la collecte de timbres',
          value: prefs.stampCollectionAlerts,
          onChanged:
              prefs.masterEnabled ? provider.setStampCollectionAlerts : null,
        ),
        const Divider(height: 1, indent: 60),
        _buildSwitchTile(
          icon: Icons.card_giftcard,
          title: 'Récompenses débloquées',
          subtitle: 'Quand votre carte de fidélité est complète',
          value: prefs.rewardCompletionAlerts,
          onChanged:
              prefs.masterEnabled ? provider.setRewardCompletionAlerts : null,
        ),
        const Divider(height: 1, indent: 60),
        _buildSwitchTile(
          icon: Icons.location_on,
          title: 'Offres à proximité',
          subtitle: 'Nouvelles offres près de vous',
          value: prefs.nearbyDealsAlerts,
          onChanged: prefs.masterEnabled ? provider.setNearbyDealsAlerts : null,
          trailing: _buildBadge('Bientôt', AppColors.accentBlue),
        ),
        const Divider(height: 1, indent: 60),
        _buildSwitchTile(
          icon: Icons.description,
          title: 'Nouveaux prospectus',
          subtitle: 'Nouveaux catalogues des commerçants',
          value: prefs.newFlyersAlerts,
          onChanged: prefs.masterEnabled ? provider.setNewFlyersAlerts : null,
        ),
        const Divider(height: 1, indent: 60),
        _buildSwitchTile(
          icon: Icons.access_time,
          title: 'Offres expirant bientôt',
          subtitle: 'Rappels avant expiration d\'offres',
          value: prefs.expiringOffersAlerts,
          onChanged:
              prefs.masterEnabled ? provider.setExpiringOffersAlerts : null,
          trailing: _buildBadge('Backend requis', AppColors.urgencyOrange),
        ),
      ],
    );
  }
}
