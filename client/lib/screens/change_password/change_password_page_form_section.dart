part of '../change_password_page.dart';

extension _ChangePasswordPageFormSection on _ChangePasswordPageState {
  Widget _buildSecurityInfo() {
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
          const Icon(
            Icons.security,
            color: AppColors.primaryGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Assurez-vous que votre nouveau mot de passe est fort et unique.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.darkGreen,
              ),
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
          _buildCurrentPasswordInput(),
          const SizedBox(height: 20),
          _buildNewPasswordInput(),
          const SizedBox(height: 20),
          _buildConfirmPasswordInput(),
        ],
      ),
    );
  }

  Widget _buildCurrentPasswordInput() {
    return _buildPasswordField(
      controller: _currentPasswordController,
      label: 'Mot de passe actuel',
      obscureText: _obscureCurrentPassword,
      onToggleVisibility: _toggleCurrentPasswordVisibility,
      validator: _validateCurrentPassword,
    );
  }

  Widget _buildNewPasswordInput() {
    return _buildPasswordField(
      controller: _newPasswordController,
      label: 'Nouveau mot de passe',
      obscureText: _obscureNewPassword,
      onToggleVisibility: _toggleNewPasswordVisibility,
      validator: _validateNewPassword,
    );
  }

  Widget _buildConfirmPasswordInput() {
    return _buildPasswordField(
      controller: _confirmPasswordController,
      label: 'Confirmer le nouveau mot de passe',
      obscureText: _obscureConfirmPassword,
      onToggleVisibility: _toggleConfirmPasswordVisibility,
      validator: _validateConfirmPassword,
    );
  }

  void _toggleCurrentPasswordVisibility() {
    _setCurrentPasswordObscured(!_obscureCurrentPassword);
  }

  void _toggleNewPasswordVisibility() {
    _setNewPasswordObscured(!_obscureNewPassword);
  }

  void _toggleConfirmPasswordVisibility() {
    _setConfirmPasswordObscured(!_obscureConfirmPassword);
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe actuel';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un nouveau mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    if (value == _currentPasswordController.text) {
      return 'Le nouveau mot de passe doit être différent';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre nouveau mot de passe';
    }
    if (value != _newPasswordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
}
