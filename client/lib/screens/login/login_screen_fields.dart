part of '../login_screen.dart';

extension _LoginScreenFields on _LoginScreenState {
  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required Widget prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.charcoalText),
      decoration: _fieldDecoration(
        label: 'Email',
        hint: 'votre@email.com',
        prefix: Icon(Icons.email_outlined, color: Colors.grey.shade500, size: 20),
      ),
      validator: _validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.charcoalText),
      decoration: _fieldDecoration(
        label: 'Mot de passe',
        hint: '••••••••',
        prefix: Icon(Icons.lock_outlined, color: Colors.grey.shade500, size: 20),
        suffix: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey.shade500,
            size: 20,
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
      validator: _validatePassword,
    );
  }

  void _togglePasswordVisibility() {
    _setPasswordObscured(!_obscurePassword);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!value.contains('@')) {
      return 'Email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Minimum 6 caractères';
    }
    return null;
  }
}
