part of '../merchant_profile_screen.dart';

extension _MerchantProfileScreenView on MerchantProfileScreen {
  Widget _buildMerchantProfileScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SafeArea(
        child: Consumer2<AuthProvider, ShopProvider>(
          builder: (context, authProvider, shopProvider, _) {
            final user = authProvider.user;
            final shopName = shopProvider.merchantAccount?.businessName;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                            child: Text(
                              (user?.name ?? 'M').substring(0, 1).toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Commerçant',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (shopName != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.store, size: 13, color: AppColors.primaryGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        shopName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Paramètres',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<LocaleProvider>(
                    builder: (context, localeProvider, _) {
                      return _SettingsTile(
                        icon: Icons.language,
                        title: 'Langue',
                        subtitle: localeProvider.displayName,
                        onTap: () => _showLanguagePicker(context, localeProvider),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Changer le mot de passe',
                    onTap: () => _showChangePasswordDialog(context, authProvider),
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'À propos',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'LocalBoost Merchant',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2026 LocalBoost',
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Gestion des utilisateurs',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<StaffProvider>(
                    builder: (context, staffProvider, _) {
                      final count = staffProvider.staff.length;
                      return _SettingsTile(
                        icon: Icons.badge_outlined,
                        title: 'Employés (accès scanner)',
                        subtitle: count == 0
                            ? 'Aucun employé ajouté'
                            : '$count employé${count > 1 ? 's' : ''} enregistré${count > 1 ? 's' : ''}',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StaffManagementScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Déconnexion',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider authProvider) {
    final formKey = GlobalKey<FormState>();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    var obscureCurrent = true;
    var obscureNew = true;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Changer le mot de passe', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentCtrl,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe actuel',
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requis';
                    if (v.length < 8) return 'Minimum 8 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirmer le nouveau mot de passe'),
                  validator: (v) => v != newCtrl.text ? 'Les mots de passe ne correspondent pas' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogContext);
                final result = await authProvider.changePassword(
                  currentPassword: currentCtrl.text.trim(),
                  newPassword: newCtrl.text.trim(),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result ? 'Mot de passe modifié !' : 'Erreur lors du changement'),
                  backgroundColor: result ? AppColors.primaryGreen : Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider localeProvider) {
    const languages = [
      ('Français', 'fr'),
      ('English', 'en'),
      ('العربية', 'ar'),
    ];
    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Choisir la langue'),
        children: languages.map(((String name, String code) lang) {
          final selected = localeProvider.locale.languageCode == lang.$2;
          return SimpleDialogOption(
            onPressed: () {
              localeProvider.setLanguage(lang.$2);
              Navigator.pop(dialogContext);
            },
            child: Row(
              children: [
                Expanded(child: Text(lang.$1,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    ))),
                if (selected) const Icon(Icons.check, size: 18),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
