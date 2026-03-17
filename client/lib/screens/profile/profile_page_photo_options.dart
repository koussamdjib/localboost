part of '../profile_page.dart';

extension _ProfilePagePhotoOptions on _ProfilePageState {
  void _showPhotoOptions(BuildContext context) {
    final hasPhoto = context.read<AuthProvider>().user?.profileImageUrl != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Photo de profil',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoalText,
              ),
            ),
            const SizedBox(height: 16),
            _buildPhotoActionTile(
              icon: Icons.camera_alt,
              title: 'Prendre une photo',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _buildPhotoActionTile(
              icon: Icons.photo_library,
              title: 'Choisir de la galerie',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            if (hasPhoto) ...[
              const Divider(),
              _buildPhotoActionTile(
                icon: Icons.delete_outline,
                title: 'Supprimer la photo',
                foreground: Colors.red.shade700,
                background: Colors.red.shade50,
                onTap: _deletePhoto,
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? foreground,
    Color? background,
  }) {
    final tileForeground = foreground ?? AppColors.primaryGreen;
    final tileBackground =
        background ?? AppColors.primaryGreen.withValues(alpha: 0.1);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tileBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: tileForeground),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: tileForeground,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
