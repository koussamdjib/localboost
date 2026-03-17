part of '../edit_profile_page.dart';

extension _EditProfilePageFormSection on _EditProfilePageState {
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Les changements sont enregistrés immédiatement après confirmation.',
              style:
                  GoogleFonts.poppins(fontSize: 13, color: AppColors.darkGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations personnelles',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.charcoalText,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: 'Nom complet',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom est requis';
              }
              if (value.trim().length < 2) {
                return 'Le nom doit contenir au moins 2 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            suffix: _isEmailChanged
                  ? const Icon(
                    Icons.warning_amber,
                    color: AppColors.urgencyOrange,
                    size: 20,
                  )
                : null,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'email est requis';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          if (_isEmailChanged) ...[
            const SizedBox(height: 8),
            Text(
              'ℹ️ Vous devrez confirmer avec votre mot de passe',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.urgencyOrange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Téléphone (optionnel)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                if (value.trim().length < 8) {
                  return 'Numéro de téléphone invalide';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cityController,
            label: 'Ville (optionnel)',
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _countryController,
            label: 'Pays (optionnel)',
            icon: Icons.flag_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Text(
          'Enregistrer les modifications',
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
