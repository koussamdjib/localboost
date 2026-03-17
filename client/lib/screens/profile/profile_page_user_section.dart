part of '../profile_page.dart';

extension _ProfilePageUserSection on _ProfilePageState {
  Widget _buildUserSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final userName = user?.name ?? 'Utilisateur LocalBoost';
        final userEmail = user?.email ?? 'user@localboost.dj';
        final userInitials = user?.initials ?? 'UL';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
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
            children: [
              _buildUserAvatar(user?.profileImageUrl, userInitials),
              const SizedBox(height: 16),
              _buildUserIdentity(userName, userEmail),
              const SizedBox(height: 20),
              _buildEditProfileButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserIdentity(String userName, String userEmail) {
    return Column(
      children: [
        Text(
          userName,
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EditProfilePage(),
          ),
        );
      },
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: Text(
        'Modifier le profil',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
