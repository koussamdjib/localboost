part of '../edit_profile_page.dart';

extension _EditProfilePageSave on _EditProfilePageState {
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      ),
    );

    try {
      var success = false;

      if (_isEmailChanged) {
        Navigator.pop(context);
        final password = await _showPasswordDialog(
          'Changement d\'email',
          'Pour changer votre email, veuillez entrer votre mot de passe actuel.',
        );

        if (password == null) {
          return;
        }

        if (!mounted) {
          return;
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            ),
          ),
        );

        success = await authProvider.updateEmail(
          newEmail: _emailController.text.trim(),
          password: password,
        );
      }

      if (_nameController.text != user.name ||
          _phoneController.text != (user.phoneNumber ?? '')) {
        success = await authProvider.updateProfile(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );
      }

      // Save city/country to customer profile endpoint
      final city = _cityController.text.trim();
      final country = _countryController.text.trim();
      try {
        await ApiClient.instance.patch('customers/me/', data: {
          'city': city,
          'country': country,
        });
        success = true;
      } catch (_) {}

      if (mounted) {
        Navigator.pop(context);

        if (success || !_hasChanges) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profil mis à jour avec succès',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error ?? 'Erreur de mise à jour',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.urgencyOrange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.urgencyOrange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
