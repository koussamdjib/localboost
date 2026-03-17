part of '../profile_page.dart';

extension _ProfilePageDeleteAccountConfirm on _ProfilePageState {
  Future<void> _confirmDeleteAccount() async {
    final passwordController = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder: (context) =>
          _buildDeletePasswordDialog(context, passwordController),
    );

    passwordController.dispose();
    if (password == null || password.isEmpty) return;

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    _showBlockingLoader(
      indicatorColor: Colors.red,
      message: 'Suppression en cours...',
    );

    final success = await authProvider.deleteAccount(password);

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (success) {
      _showFloatingMessage(
          'Compte supprimé. Au revoir !', AppColors.charcoalText);
    } else {
      _showFloatingMessage(
        authProvider.error ?? 'Erreur de suppression du compte',
        AppColors.urgencyOrange,
      );
    }
  }

  Widget _buildDeletePasswordDialog(
    BuildContext dialogContext,
    TextEditingController passwordController,
  ) {
    return AlertDialog(
      title: Text(
        'Confirmation finale',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pour confirmer la suppression, entrez votre mot de passe :',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            'Annuler',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.pop(dialogContext, passwordController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Supprimer définitivement',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
