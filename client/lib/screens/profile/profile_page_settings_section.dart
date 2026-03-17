part of '../profile_page.dart';

extension _ProfilePageSettingsSection on _ProfilePageState {
  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Paramètres',
              style: GoogleFonts.poppins(
                color: AppColors.charcoalText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            icon: Icons.language,
            title: 'Langue',
            subtitle: _selectedLanguage,
            onTap: _showLanguageDialog,
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Gérer vos préférences de notification',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsPage(),
              ),
            ),
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsItem(
            icon: Icons.lock_outline,
            title: 'Changer le mot de passe',
            subtitle: 'Sécurité du compte',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePasswordPage(),
              ),
            ),
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsItem(
            icon: Icons.history,
            title: 'Historique des transactions',
            subtitle: 'Voir vos activités',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionHistoryPage(),
              ),
            ),
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsItem(
            icon: Icons.card_giftcard,
            title: 'Historique des récompenses',
            subtitle: 'Suivre vos demandes de récompense',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RewardHistoryPage(),
              ),
            ),
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsItem(
              icon: Icons.help_outline, title: 'Aide & Support', onTap: () {}),
          const Divider(height: 1, indent: 60),
          _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'À propos de LocalBoost',
              onTap: () {}),
          const Divider(height: 1, indent: 60),
          _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Confidentialité',
              onTap: () {}),
          const Divider(height: 1, indent: 60),
          _buildSettingsItem(
            icon: Icons.delete_forever_outlined,
            title: 'Supprimer le compte',
            titleColor: Colors.red.shade700,
            iconColor: Colors.red.shade700,
            subtitle: 'Action irréversible',
            onTap: _showDeleteAccountDialog,
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Déconnexion',
            titleColor: AppColors.urgencyOrange,
            iconColor: AppColors.urgencyOrange,
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }
}
