part of '../profile_page.dart';

extension _ProfilePagePhotoActions on _ProfilePageState {
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return;

    if (!mounted) return;

    var loaderShown = false;

    try {
      final authProvider = context.read<AuthProvider>();
      
      if (mounted) {
        _showBlockingLoader(
          indicatorColor: AppColors.primaryGreen,
          message: 'Téléchargement...',
        );
        loaderShown = true;
      }

      final success = await authProvider.uploadProfilePhoto(File(image.path));

      if (mounted && loaderShown) {
        Navigator.pop(context);
      }

      if (success) {
        _showFloatingMessage(
            '✅ Photo de profil mise à jour', AppColors.primaryGreen);
      } else {
        _showFloatingMessage(
          authProvider.error ?? 'Erreur de téléchargement',
          AppColors.urgencyOrange,
        );
      }
    } catch (e) {
      if (mounted && loaderShown && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showFloatingMessage('Erreur: $e', AppColors.urgencyOrange);
    }
  }

  Future<void> _deletePhoto() async {
    _showBlockingLoader(
      indicatorColor: AppColors.primaryGreen,
      message: 'Suppression...',
    );

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.deleteProfilePhoto();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (success) {
      _showFloatingMessage('Photo de profil supprimée', AppColors.primaryGreen);
    } else {
      _showFloatingMessage(
        authProvider.error ?? 'Erreur de suppression',
        AppColors.urgencyOrange,
      );
    }
  }
}
